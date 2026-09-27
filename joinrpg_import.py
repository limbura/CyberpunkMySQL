#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""JoinRPG (проект 1631) -> cyberwall.main. Python 3.10+.

Установка: py -m pip install mysql-connector-python
Запуск с предпросмотром и предложением применить: py joinrpg_import.py
Один персонаж: py joinrpg_import.py --character-id 12345

IP, порт и пользователь MySQL запрашиваются при запуске. Enter выбирает
127.0.0.1, 3306 и master соответственно. Пароли также запрашиваются.
Email и пароли можно задать переменными окружения JOINRPG_EMAIL,
JOINRPG_PASSWORD и CYBERWALL_MYSQL_PASSWORD.
Для входа в JoinRPG нужна учетная запись с мастерскими правами на проект 1631.

Требуется столбец main.joinrpg_id INT UNSIGNED NULL с UNIQUE-индексом.
ID выдают существующие mainBeforeInsert/generateId/mainAfterInsert.
Скрипт не создает таблицы, процедуры и триггеры.

Каждый запуск читает полный список персонажей; это ручной импорт, не демон.
Обрабатываются активные персонажи с принятой заявкой (playerInfo != null).
Пропуски и ошибки не удаляют существующие записи и не очищают их поля.
Новая строка: joinrpg_id, name, password, occupancy=''; остальное задает БД.
Существующая строка: обновляются только name и password.
Привязка только по joinrpg_id, совпадение имен не используется.
Пароль: оставить ASCII-цифры 0..9, сохранив ведущие нули и порядок цифр.
Это обработка строки API, не восстановление и не проверка календарной даты.

Предпросмотр не выполняет INSERT/UPDATE и не расходует ID через триггеры.
После предпросмотра скрипт предлагает применить изменения: да/нет, Enter = нет.
Если изменений нет, подтверждение не запрашивается. При применении используется
уже загруженный набор данных JoinRPG; запись MySQL повторно проверяется перед
INSERT/UPDATE. Каждая запись фиксируется отдельно. При SQL-ошибке текущая
транзакция откатывается и запуск останавливается; ранее сохраненное остается.
Повторный запуск безопасен по joinrpg_id. Два экземпляра этого скрипта
не применяют изменения одновременно благодаря MySQL GET_LOCK.
При разрыве соединения во время COMMIT результат может быть неизвестен:
повторный запуск сверит фактическое состояние БД.

Источники: https://joinrpg.ru/openapi/v1.json
https://docs.joinrpg.ru/api/api-docs.html
https://docs.joinrpg.ru/api/integration.html
"""

import argparse
from collections import Counter, defaultdict
import getpass
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass


# Значения по умолчанию для интерактивного подключения к MySQL.
MYSQL_HOST = "127.0.0.1"
MYSQL_PORT = 3306
MYSQL_USER = "master"
MYSQL_DATABASE = "cyberwall"
JOINRPG_EMAIL = os.getenv("JOINRPG_EMAIL", "")
PROJECT_ID = 1631
NAME_PROGRAMMATIC_ID = "1"
PASSWORD_PROGRAMMATIC_ID = "4"
API_BASE = "https://joinrpg.ru"
LOCK_NAME = "cyberwall.main.joinrpg_import"
TAB_SIZE = 8  # Шаг табуляции в консоли (обычно 8 позиций).


def record_columns(action, record):
	# Управляющие символы внутри имени не должны нарушать строки и колонки.
	name = re.sub(r"[\t\r\n]", " ", record.name)
	return (f"{action}:", f"joinrpg_id {record.joinrpg_id}",
		f"name {name}", f"password {record.password}")


def output_column_widths(records):
	# Каждая следующая колонка начинается с общей позиции табуляции.
	max_lengths = [len("БЕЗ ИЗМЕНЕНИЙ:"), 0, 0]
	for record in records:
		for index, text in enumerate(record_columns("БЕЗ ИЗМЕНЕНИЙ", record)[:3]):
			max_lengths[index] = max(max_lengths[index], len(text))
	return tuple((length // TAB_SIZE + 1) * TAB_SIZE for length in max_lengths)


def format_record(action, record, widths):
	columns = record_columns(action, record)
	return "".join(text + "\t" * ((width - len(text) + TAB_SIZE - 1) // TAB_SIZE)
		for text, width in zip(columns[:3], widths)) + columns[3]


class ImportProblem(Exception):
	pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
	def redirect_request(self, req, fp, code, msg, headers, newurl):
		return None


class JoinRpg:
	def __init__(self, email, password):
		self.email = email
		self.password = password
		self.token = None
		self.opener = urllib.request.build_opener(NoRedirect())

	def login(self):
		payload = urllib.parse.urlencode({
			"grant_type": "password", "username": self.email,
			"password": self.password,
		}).encode("utf-8")
		result = self.request("/x-api/token", payload)
		token = result.get("access_token") if isinstance(result, dict) else None
		if not isinstance(token, str) or not token:
			raise ImportProblem("JoinRPG не вернул access_token.")
		self.token = token

	def request(self, path, data=None):
		# Все URL формируются скриптом; перенаправления с учетными данными запрещены.
		for attempt in range(3):
			headers = {"Accept": "application/json", "User-Agent": "CyberwallImport/1.0"}
			if data is not None:
				headers["Content-Type"] = "application/x-www-form-urlencoded"
			elif self.token:
				headers["Authorization"] = "Bearer " + self.token
			req = urllib.request.Request(API_BASE + path, data=data, headers=headers)
			try:
				with self.opener.open(req, timeout=30) as response:
					return json.load(response)
			except urllib.error.HTTPError as exc:
				code = exc.code
				exc.close()
				if data is None and code == 401 and attempt == 0:
					self.login()
					continue
				if data is None and code in (429, 500, 502, 503, 504) and attempt < 2:
					time.sleep(2 ** (attempt + 1))
					continue
				raise ImportProblem(
					f"JoinRPG: HTTP {code} при запросе {path}. "
					"Для 401 проверь логин/пароль; для 403 — мастерские права."
				) from None
			except (urllib.error.URLError, TimeoutError, OSError):
				if data is None and attempt < 2:
					time.sleep(2 ** (attempt + 1))
					continue
				raise ImportProblem("Не удалось подключиться к JoinRPG по HTTPS.") from None
			except (ValueError, UnicodeError):
				raise ImportProblem("JoinRPG вернул некорректный JSON.") from None
		raise ImportProblem("Исчерпаны попытки запроса JoinRPG.")


def positive_id(value):
	if isinstance(value, bool) or not re.fullmatch(r"[0-9]+", str(value)):
		raise ImportProblem("API вернул некорректный идентификатор.")
	result = int(value)
	if not 0 < result <= 2147483647:
		raise ImportProblem("Идентификатор вне диапазона JoinRPG int32.")
	return result


def resolve_field_ids(metadata):
	if not isinstance(metadata, dict) or not isinstance(metadata.get("fields"), list):
		raise ImportProblem("Неверный формат метаданных JoinRPG.")
	result = {}
	for code in (NAME_PROGRAMMATIC_ID, PASSWORD_PROGRAMMATIC_ID):
		matches = [f for f in metadata["fields"]
			if str(f.get("programmaticValue", "")).strip() == code
			and f.get("isActive") is True]
		if len(matches) != 1:
			raise ImportProblem(
				f"Программный ID {code}: найдено активных полей {len(matches)}, нужно ровно 1. "
				"Проверь программный ID и доступность поля для учетной записи."
			)
		result[code] = positive_id(matches[0]["projectFieldId"])
	return result


def clean_password(value):
	# Никаких float/Decimal: точка удаляется вместе с другими нецифровыми символами.
	if not isinstance(value, str):
		raise ImportProblem("Дата рождения отсутствует или API вернул ее не строкой.")
	result = re.sub(r"[^0-9]", "", value)
	if not result:
		raise ImportProblem("Дата рождения не содержит цифр.")
	# Храним строку: ведущие нули являются частью игрового пароля.
	if len(result) > 255:
		raise ImportProblem("Пароль после очистки длиннее 255 символов.")
	return result


@dataclass(frozen=True)
class Record:
	joinrpg_id: int
	name: str
	password: str


def parse_character(character, field_ids):
	if not isinstance(character, dict):
		raise ImportProblem("Неверный формат данных персонажа.")
	character_id = positive_id(character.get("characterId"))
	if character.get("isActive") is not True:
		return None, "персонаж неактивен"
	if character.get("playerInfo") is None:
		return None, "заявка не принята"
	fields = character.get("fields")
	if not isinstance(fields, list):
		raise ImportProblem("API не вернул массив fields.")
	values = {}
	for field in fields:
		field_id = positive_id(field.get("projectFieldId"))
		if field_id in values:
			raise ImportProblem("В ответе API повторяется ID поля.")
		values[field_id] = field.get("value")
	name = values.get(field_ids[NAME_PROGRAMMATIC_ID])
	if not isinstance(name, str) or not name.strip():
		raise ImportProblem("Поле имени (программный ID 1) отсутствует или пустое.")
	name = name.strip()
	if len(name) > 255:
		raise ImportProblem("Имя длиннее 255 символов.")
	password = clean_password(values.get(field_ids[PASSWORD_PROGRAMMATIC_ID]))
	return Record(character_id, name, password), None


def load_records(api, selected_id):
	prefix = f"/x-game-api/{PROJECT_ID}"
	field_ids = resolve_field_ids(api.request(prefix + "/metadata/fields"))
	print("Найдены поля: " + ", ".join(
		f"программный ID {code} -> projectFieldId {field_id}"
		for code, field_id in field_ids.items()))
	if selected_id is not None:
		ids = [positive_id(selected_id)]
	else:
		headers = api.request(prefix + "/characters")
		if not isinstance(headers, list):
			raise ImportProblem("API не вернул список персонажей.")
		ids = sorted({positive_id(h.get("characterId")) for h in headers
			if h.get("isActive") is True})
	print(f"Персонажей для проверки: {len(ids)}")
	records = []
	errors = 0
	for number, character_id in enumerate(ids, 1):
		character = api.request(prefix + f"/characters/{character_id}")
		if not isinstance(character, dict) or positive_id(character.get("characterId")) != character_id:
			raise ImportProblem("API вернул другой characterId вместо запрошенного.")
		character_name = character.get("characterName")
		if not isinstance(character_name, str) or not character_name.strip():
			character_name = "имя не указано"
		character_label = f"{character_name.strip()!r} (JoinRPG {character_id})"
		try:
			record, reason = parse_character(character, field_ids)
			if record is None:
				print(f"ПРОПУСК {character_label}: {reason}")
			else:
				records.append(record)
		except ImportProblem as exc:
			errors += 1
			print(f"ОШИБКА ДАННЫХ {character_label}: {exc}")
		if number % 20 == 0:
			print(f"Прочитано {number}/{len(ids)}")
	return records, errors


def verify_schema(cursor):
	cursor.execute("SHOW COLUMNS FROM `main`")
	columns = {row["Field"]: row for row in cursor.fetchall()}
	required = {"card_id", "id", "joinrpg_id", "name", "password", "occupancy"}
	if required - columns.keys():
		raise ImportProblem("В main нет столбцов: " + ", ".join(sorted(required - columns.keys())))
	cursor.execute("SHOW INDEX FROM `main`")
	indexes = defaultdict(list)
	for row in cursor.fetchall():
		if row["Non_unique"] == 0:
			indexes[row["Key_name"]].append(row["Column_name"])
	if ["joinrpg_id"] not in indexes.values():
		raise ImportProblem("Для main.joinrpg_id нужен отдельный UNIQUE-индекс.")
	cursor.execute("SELECT @@SESSION.sql_mode AS mode")
	mode = cursor.fetchone()["mode"] or ""
	if not ({"STRICT_TRANS_TABLES", "STRICT_ALL_TABLES"} & set(mode.split(","))):
		raise ImportProblem("Нужен строгий SQL-режим, чтобы MySQL не обрезал данные молча.")


def sync_record(cursor, record, apply):
	cursor.execute(
		"SELECT `card_id`, `name`, `password` FROM `main` WHERE `joinrpg_id` = %s"
		+ (" FOR UPDATE" if apply else ""), (record.joinrpg_id,))
	old = cursor.fetchone()
	if old is None:
		if apply:
			# Обычный INSERT: id и card_id назначают существующие механизмы БД.
			cursor.execute(
				"INSERT INTO `main` (`joinrpg_id`, `name`, `password`, `occupancy`) "
				"VALUES (%s, %s, %s, %s)",
				(record.joinrpg_id, record.name, record.password, ""))
		return "СОЗДАНИЕ", "name, password; occupancy=''"
	changed = [key for key in ("name", "password") if old[key] != getattr(record, key)]
	if not changed:
		return "БЕЗ ИЗМЕНЕНИЙ", ""
	if apply:
		# Не используем INSERT ON DUPLICATE KEY UPDATE: он запускает BEFORE INSERT
		# даже для существующей записи и может зря расходовать ID через generateId.
		cursor.execute(
			"UPDATE `main` SET `name` = %s, `password` = %s "
			"WHERE `card_id` = %s AND `joinrpg_id` = %s",
			(record.name, record.password, old["card_id"], record.joinrpg_id))
	return "ОБНОВЛЕНИЕ", ", ".join(changed)


def prompt_mysql_connection():
	print("\nПодключение к MySQL. Нажми Enter, чтобы использовать значение в скобках.")
	host = input(f"IP БД [{MYSQL_HOST}]: ").strip() or MYSQL_HOST
	while True:
		port_text = input(f"Порт БД [{MYSQL_PORT}]: ").strip() or str(MYSQL_PORT)
		if re.fullmatch(r"[0-9]{1,5}", port_text) and 1 <= int(port_text) <= 65535:
			port = int(port_text)
			break
		print("Некорректный порт: введи целое число от 1 до 65535.")
	user = input(f"Пользователь БД [{MYSQL_USER}]: ").strip() or MYSQL_USER
	return host, port, user


def confirm_apply():
	while True:
		answer = input("\nПрименить показанные изменения в БД? [y/n]: ").strip().lower()
		if answer in ("да", "д", "yes", "y", "YES", "Yes", "Y"):
			return True
		if answer in ("", "нет", "н", "no", "n", "NO", "No", "N"):
			return False
		print("Введи «да» или «нет». Enter — не применять изменения.")


def run():
	parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument("--character-id", type=int, help="Обработать только одного персонажа")
	args = parser.parse_args()
	try:
		import mysql.connector
	except ImportError:
		raise ImportProblem("Установи зависимость: py -m pip install mysql-connector-python") from None
	print("РЕЖИМ: ПРЕДПРОСМОТР, ЗАТЕМ ПОДТВЕРЖДЕНИЕ ЗАПИСИ")
	print(f"Для входа в JoinRPG используй учетную запись с мастерскими правами на игру {PROJECT_ID}.")
	email = JOINRPG_EMAIL.strip() or input("Email JoinRPG: ").strip()
	password = os.getenv("JOINRPG_PASSWORD")
	if password is None:
		password = getpass.getpass("Пароль JoinRPG: ")
	api = JoinRpg(email, password)
	api.login()
	records, data_errors = load_records(api, args.character_id)
	if not records:
		print("Нет записей, пригодных для импорта. MySQL не изменен.")
		return 2 if data_errors else 0
	db_host, db_port, db_user = prompt_mysql_connection()
	db_password = os.getenv("CYBERWALL_MYSQL_PASSWORD")
	if db_password is None:
		db_password = getpass.getpass(f"Пароль MySQL ({db_user}@{db_host}:{db_port}): ")
	connection = None
	try:
		connection = mysql.connector.connect(
			host=db_host, port=db_port, user=db_user,
			password=db_password, database=MYSQL_DATABASE, charset="utf8mb4",
			connection_timeout=15, autocommit=False, raise_on_warnings=True)
		cursor = connection.cursor(dictionary=True, buffered=True)
		try:
			verify_schema(cursor)
			connection.rollback()
			column_widths = output_column_widths(records)
			pending_records = []
			for apply in (False, True):
				if apply:
					if not pending_records:
						print("Изменений для применения нет.")
						break
					if not confirm_apply():
						print("Изменения не применены. Запись в БД не выполнялась.")
						break
					# Во время ожидания ответа нет транзакции с блокировками строк.
					cursor.execute("SELECT GET_LOCK(%s, 0) AS acquired", (LOCK_NAME,))
					if cursor.fetchone()["acquired"] != 1:
						raise ImportProblem("Другой экземпляр импорта уже применяет изменения.")
					connection.rollback()
					print("\nПРИМЕНЕНИЕ ИЗМЕНЕНИЙ:")
				else:
					print("\nПЛАН ИЗМЕНЕНИЙ (запись в БД еще не выполняется):")
				counts = Counter()
				for record in (pending_records if apply else records):
					try:
						action, _detail = sync_record(cursor, record, apply)
						if apply:
							connection.commit()
						else:
							connection.rollback()
							if action != "БЕЗ ИЗМЕНЕНИЙ":
								pending_records.append(record)
						counts[action] += 1
						# Показываем очищенный игровой пароль, подготовленный для MySQL.
						print(format_record(action, record, column_widths))
					except mysql.connector.Error as exc:
						try:
							connection.rollback()
						except mysql.connector.Error:
							pass
						raise ImportProblem(
							f"MySQL: ошибка {exc.errno}, SQLSTATE {exc.sqlstate}, "
							f"персонаж {record.name!r} (JoinRPG {record.joinrpg_id}). Импорт остановлен. "
							"Ранее подтвержденные записи сохранены. "
							"При потере соединения на COMMIT результат уточнит повторный запуск."
						) from None
				print(("ИТОГО ПРИМЕНЕНО: " if apply else "ИТОГО ПЛАН: ")
					+ ", ".join(f"{k}: {v}" for k, v in counts.items()))
				if not apply:
					print(f"Пропущено из-за ошибок полей: {data_errors}")
				else:
					print("Изменения применены.")
		finally:
			cursor.close()
	except mysql.connector.Error as exc:
		raise ImportProblem(
			f"MySQL: ошибка {exc.errno}, SQLSTATE {exc.sqlstate}. "
			"Проверь подключение, схему и права SELECT/INSERT/UPDATE."
		) from None
	finally:
		if connection is not None:
			# Закрытие соединения также освобождает GET_LOCK и откатывает незавершенное.
			connection.close()
	return 2 if data_errors else 0


if __name__ == "__main__":
	try:
		sys.exit(run())
	except (ImportProblem, ValueError) as exc:
		print(f"ОШИБКА: {exc}", file=sys.stderr)
		sys.exit(1)
	except (KeyboardInterrupt, EOFError):
		print("\nЗапуск прерван.", file=sys.stderr)
		sys.exit(130)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Сверка main.joinrpg_id по именам.
Обновляет joinrpg_id в БД у персонажей, имена которых совпадают (после восстановления joinrpg)
Python 3.10+.
Установка: py -m pip install mysql-connector-python
Запуск: py joinrpg_reconcile_ids.py
Самостоятельный скрипт; joinrpg_import.py рядом не требуется.
"""

# ============================== НАСТРОЙКИ ==============================
MYSQL_HOST = "188.134.70.190"
MYSQL_PORT = 3306
MYSQL_USER = "master"
MYSQL_DATABASE = "cyberwall"
PROJECT_ID = 1631
NAME_PROGRAMMATIC_ID = "1"  # programmaticValue поля «Имя персонажа».
# Сравниваем всех персонажей, возвращённых /characters, включая непринятые
# заявки и неактивных персонажей. API может не возвращать удалённых персонажей.
# Имена сравниваются с учётом регистра, ё/е и внутренних пробелов.
# Пробелы по краям удаляются с обеих сторон только для сравнения.
# ======================================================================

from collections import defaultdict
import getpass
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API_BASE = "https://joinrpg.ru"
JOINRPG_EMAIL = os.getenv("JOINRPG_EMAIL", "")
# Общая блокировка с прежним скриптом импорта.
LOCK_NAME = f"{MYSQL_DATABASE}.main.joinrpg_import"

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


def name_key(name):
    return name.strip() if isinstance(name, str) else ''


def load_characters(api):
    prefix = f'/x-game-api/{positive_id(PROJECT_ID)}'
    metadata = api.request(prefix + '/metadata/fields')
    if not isinstance(metadata, dict) or not isinstance(metadata.get('fields'), list):
        raise ImportProblem('Неверный формат метаданных JoinRPG.')
    fields = [f for f in metadata['fields'] if isinstance(f, dict)
              and str(f.get('programmaticValue', '')).strip() == str(NAME_PROGRAMMATIC_ID)
              and f.get('isActive') is True]
    if len(fields) != 1:
        raise ImportProblem(f'Программный ID {NAME_PROGRAMMATIC_ID}: нужно ровно одно активное поле, найдено {len(fields)}.')
    field_id = positive_id(fields[0]['projectFieldId'])
    headers = api.request(prefix + '/characters')
    if not isinstance(headers, list) or any(not isinstance(h, dict) for h in headers):
        raise ImportProblem('API не вернул полный список персонажей ожидаемого формата.')
    ids = [positive_id(h.get('characterId')) for h in headers]
    if len(ids) != len(set(ids)):
        raise ImportProblem('В списке API повторяется characterId.')
    print(f'Персонажей для проверки: {len(ids)}; программный ID {NAME_PROGRAMMATIC_ID} -> projectFieldId {field_id}')
    records, invalid = [], []
    for number, cid in enumerate(sorted(ids), 1):
        c = api.request(prefix + f'/characters/{cid}')
        if not isinstance(c, dict) or positive_id(c.get('characterId')) != cid:
            raise ImportProblem('API вернул другой characterId вместо запрошенного.')
        values = c.get('fields')
        if not isinstance(values, list) or any(not isinstance(f, dict) for f in values):
            raise ImportProblem(f'JoinRPG {cid}: некорректный массив fields.')
        matches = [f.get('value') for f in values if positive_id(f.get('projectFieldId')) == field_id]
        if len(matches) != 1 or not isinstance(matches[0], str) or not matches[0].strip():
            invalid.append((cid, c.get('characterName'), 'поле имени отсутствует, пустое или повторяется'))
        else:
            records.append({'joinrpg_id': cid, 'name': matches[0].strip()})
        if number % 20 == 0 or number == len(ids):
            print(f'Прочитано {number}/{len(ids)}')
    return records, invalid


def read_db(cursor, lock=False):
    cursor.execute('SELECT `card_id`, `name`, `joinrpg_id` FROM `main` ORDER BY `card_id`'
                   + (' FOR UPDATE' if lock else ''))
    return cursor.fetchall()


def make_plan(db, remote):
    left, right = defaultdict(list), defaultdict(list)
    for r in db:
        if name_key(r['name']):
            left[name_key(r['name'])].append(r)
    for r in remote:
        right[name_key(r['name'])].append(r)
    missing_remote = [r for r in db if name_key(r['name']) and name_key(r['name']) not in right]
    missing_db = [r for r in remote if name_key(r['name']) not in left]
    ambiguous = sorted(n for n in left.keys() | right.keys()
                       if len(left.get(n, [])) > 1 or len(right.get(n, [])) > 1)
    candidates, unchanged = [], 0
    for n in sorted(left.keys() & right.keys()):
        if n in ambiguous:
            continue
        old, new = left[n][0], right[n][0]
        if old['joinrpg_id'] == new['joinrpg_id']:
            unchanged += 1
        else:
            candidates.append({'card_id': old['card_id'], 'name': old['name'],
                               'old': old['joinrpg_id'], 'new': new['joinrpg_id']})
    # ID можно освободить лишь у записи, которая сама входит в применяемый план.
    # Повторяем проверку, чтобы блокировать также цепочки зависимых замен.
    owners = {r['joinrpg_id']: r['card_id'] for r in db if r['joinrpg_id'] is not None}
    eligible = {p['card_id']: p for p in candidates}
    blocked = {}
    while True:
        rejected = {cid: owners[p['new']] for cid, p in eligible.items()
                    if p['new'] in owners and owners[p['new']] != cid
                    and owners[p['new']] not in eligible}
        if not rejected:
            break
        for cid, owner in rejected.items():
            blocked[cid] = owner
            del eligible[cid]
    return candidates, list(eligible.values()), blocked, missing_remote, missing_db, ambiguous, left, right, unchanged


def table(title, headings, rows):
    print('\n' + title)
    rows = [[re.sub(r'[\x00-\x1f\x7f]', ' ', str(v)) if v is not None else 'NULL' for v in row] for row in rows]
    if not rows:
        print('(нет)')
        return
    data = [headings] + rows
    widths = [max(len(row[i]) for row in data) + 2 for i in range(len(headings))]
    for row in data:
        print(''.join(value.ljust(width) for value, width in zip(row, widths)).rstrip())


def show_plan(db, remote, invalid, plan):
    candidates, eligible, blocked, only_db, only_api, ambiguous, left, right, unchanged = plan
    table('РАЗЛИЧИЯ JOINRPG_ID У СОВПАДАЮЩИХ ИМЁН:',
          ['card_id', 'name', 'БД: joinrpg_id', 'API: joinrpg_id', 'Действие'],
          [[p['card_id'], p['name'], p['old'], p['new'],
            f"ПРОПУСК: ID занят card_id {blocked[p['card_id']]}" if p['card_id'] in blocked else 'ОБНОВЛЕНИЕ'] for p in candidates])
    title = 'ИМЕНА В БД, ОТСУТСТВУЮЩИЕ НА JOINRPG:' if not invalid else 'ИМЕНА В БД, НЕ НАЙДЕННЫЕ СРЕДИ ПРОЧИТАННЫХ ИМЁН JOINRPG (список неполный):'
    table(title, ['card_id', 'name', 'joinrpg_id'], [[r['card_id'], r['name'], r['joinrpg_id']] for r in only_db])
    table('ИМЕНА НА JOINRPG, ОТСУТСТВУЮЩИЕ В БД:', ['joinrpg_id', 'name'], [[r['joinrpg_id'], r['name']] for r in only_api])
    table('НЕОДНОЗНАЧНЫЕ ИМЕНА — АВТОМАТИЧЕСКАЯ ЗАМЕНА ПРОПУЩЕНА:',
          ['name', 'БД: card_id', 'API: joinrpg_id'],
          [[n, ', '.join(str(r['card_id']) for r in left[n]) or '—',
            ', '.join(str(r['joinrpg_id']) for r in right[n]) or '—'] for n in ambiguous])
    table('ОШИБКИ ЧТЕНИЯ ИМЁН JOINRPG:', ['joinrpg_id', 'Название персонажа', 'Причина'], invalid)
    table('ЗАПИСИ БД БЕЗ ИМЕНИ — ПРОПУЩЕНЫ:', ['card_id', 'joinrpg_id'],
          [[r['card_id'], r['joinrpg_id']] for r in db if not name_key(r['name'])])
    print(f'\nИТОГО: в БД {len(db)}, прочитано имён JoinRPG {len(remote)}, без изменений {unchanged}, '
          f'расхождений {len(candidates)}, доступно замен {len(eligible)}, конфликтов ID {len(blocked)}.')


def verify_schema(cursor):
    cursor.execute('SHOW COLUMNS FROM `main`')
    columns = {r['Field']: r for r in cursor.fetchall()}
    if {'card_id', 'name', 'joinrpg_id'} - columns.keys():
        raise ImportProblem('Нужны столбцы main.card_id, name, joinrpg_id.')
    if columns['joinrpg_id']['Null'] != 'YES':
        raise ImportProblem('Для безопасной перестановки ID столбец joinrpg_id должен допускать NULL.')
    cursor.execute('SHOW INDEX FROM `main`')
    indexes = defaultdict(list)
    for r in cursor.fetchall():
        if r['Non_unique'] == 0:
            indexes[r['Key_name']].append(r['Column_name'])
    if ['joinrpg_id'] not in indexes.values() or ['card_id'] not in indexes.values():
        raise ImportProblem('Нужны отдельные уникальные индексы card_id и joinrpg_id.')
    cursor.execute("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'main'", (MYSQL_DATABASE,))
    row = cursor.fetchone()
    if not row or row['ENGINE'].upper() != 'INNODB':
        raise ImportProblem('Таблица main должна использовать InnoDB для атомарной записи.')


def snapshot(rows):
    return sorted((r['card_id'], r['name'], r['joinrpg_id']) for r in rows)


def apply_plan(connection, cursor, original, changes):
    # Не держим транзакцию и блокировки во время пользовательского подтверждения.
    connection.rollback()
    cursor.execute('SELECT GET_LOCK(%s, 0) AS acquired', (LOCK_NAME,))
    if cursor.fetchone()['acquired'] != 1:
        raise ImportProblem('Другой экземпляр сверки или импорта уже применяет изменения.')
    connection.rollback()
    try:
        connection.start_transaction(isolation_level='SERIALIZABLE')
        current = read_db(cursor, lock=True)
        if snapshot(current) != snapshot(original):
            raise ImportProblem('БД изменилась после предпросмотра. Запусти сверку заново; изменения не применены.')
        # Сначала освобождаем ID только у одобренных записей, затем назначаем новые.
        # Так поддерживаются обмены A -> B -> A без нарушения UNIQUE.
        for p in changes:
            cursor.execute('UPDATE `main` SET `joinrpg_id` = NULL WHERE `card_id` = %s', (p['card_id'],))
        for p in changes:
            cursor.execute('UPDATE `main` SET `joinrpg_id` = %s WHERE `card_id` = %s', (p['new'], p['card_id']))
            if cursor.rowcount != 1:
                raise ImportProblem('Не удалось обновить ровно одну запись; изменения отменены.')
        expected = {r['card_id']: dict(r) for r in original}
        for p in changes:
            expected[p['card_id']]['joinrpg_id'] = p['new']
        if snapshot(read_db(cursor)) != snapshot(list(expected.values())):
            raise ImportProblem('Результат записи не совпал с планом; изменения отменены.')
        connection.commit()
    except BaseException:
        try:
            connection.rollback()
        except Exception:
            pass
        raise
    # Именная блокировка освобождается закрытием соединения в run().


def run():
    try:
        import mysql.connector
    except ImportError:
        raise ImportProblem('Установи зависимость: py -m pip install mysql-connector-python') from None
    print('РЕЖИМ: СВЕРКА ИМЁН И JOINRPG_ID, ЗАТЕМ ПОДТВЕРЖДЕНИЕ ЗАПИСИ')
    print(f'Для входа в JoinRPG используй учетную запись с мастерскими правами на игру {PROJECT_ID}.')
    print('Сравниваются все персонажи из ответа API, независимо от принятия заявки.')
    print('Имена: точное совпадение с учётом регистра; пробелы по краям игнорируются.')
    email = JOINRPG_EMAIL.strip() or input('Email JoinRPG: ').strip()
    password = os.getenv('JOINRPG_PASSWORD')
    if password is None:
        password = getpass.getpass('Пароль JoinRPG: ')
    api = JoinRpg(email, password)
    api.login()
    remote, invalid = load_characters(api)
    host, port, user = prompt_mysql_connection()
    password = os.getenv('CYBERWALL_MYSQL_PASSWORD')
    if password is None:
        password = getpass.getpass(f'Пароль MySQL ({user}@{host}:{port}): ')
    connection = None
    try:
        connection = mysql.connector.connect(host=host, port=port, user=user, password=password,
                    database=MYSQL_DATABASE, charset='utf8mb4', connection_timeout=15,
                    autocommit=False, raise_on_warnings=True)
        cursor = connection.cursor(dictionary=True, buffered=True)
        try:
            verify_schema(cursor)
            original = read_db(cursor)
            connection.rollback()
            plan = make_plan(original, remote)
            show_plan(original, remote, invalid, plan)
            if invalid:
                print('Есть непрочитанные имена JoinRPG. Применение отключено, чтобы не пропустить одноимённых персонажей.')
                return 2
            changes = plan[1]
            if not changes:
                print('Изменений для применения нет.')
                return 0
            if not confirm_apply():
                print('Изменения не применены. Запись в БД не выполнялась.')
                return 0
            apply_plan(connection, cursor, original, changes)
            print(f'Изменения применены. Обновлено joinrpg_id: {len(changes)}.')
        finally:
            cursor.close()
    except mysql.connector.Error as exc:
        raise ImportProblem(f'MySQL: ошибка {exc.errno}, SQLSTATE {exc.sqlstate}. '
              'Проверь подключение и права SELECT/UPDATE для main.joinrpg_id. '
              'При ошибке записи выполняется откат всей операции. '
              'При потере соединения во время COMMIT результат уточнит повторный запуск.') from None
    finally:
        if connection is not None:
            connection.close()
    return 0


if __name__ == '__main__':
    try:
        sys.exit(run())
    except (ImportProblem, ValueError) as exc:
        print(f'ОШИБКА: {exc}', file=sys.stderr)
        sys.exit(1)
    except (KeyboardInterrupt, EOFError):
        print('\nЗапуск прерван.', file=sys.stderr)
        sys.exit(130)

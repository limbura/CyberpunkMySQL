#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Консольное управление доступом к замкам Cyberwall. Python 3.9+.

Установка: py -m pip install "PyMySQL[rsa]"
Запуск:    py lock_manager.py

Настройки по умолчанию находятся ниже. Пароль запрашивается скрыто.
База cyberwall задана в коде и при подключении не запрашивается.
Нужны SELECT на main, locks, lock_access и EXECUTE на setLockAccess.
Процедура: setLockAccess(lock_id, card_id, grantAccess, OUT errCode).
Коды: 0 — успех, 1 — нет пользователя, 2 — нет замка,
5 — доступ уже назначен, 6 — доступ уже отсутствует.
Процедура из нашей переписки не делает COMMIT: транзакцией управляет скрипт.

Поиск — буквальное вхождение строки, в том числе части номера.
Числа выводятся с пробелами по три разряда; поиск принимает их с пробелами.
Регистр сравнивается по правилам collation столбцов MySQL.
Enter в поиске — показать всех, :b — назад, :q — выход.
При редактировании выбранный человек определяется по card_id, а не main.id.
Скрипт не меняет структуру БД, не создаёт людей/замки, не пишет open_cmd.
"""

from dataclasses import dataclass
from getpass import getpass
import sys
from typing import Optional

try:
    import pymysql
    from pymysql.cursors import DictCursor
except ImportError:
    print('Не установлен PyMySQL. Выполни: py -m pip install "PyMySQL[rsa]"')
    raise SystemExit(1)


DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 3306
DEFAULT_USER = "master"
DATABASE_NAME = "cyberwall"
PAGE_SIZE = 15

BUSINESS_ERRORS = {
    1: "Пользователь с этой картой не найден. Права не изменены.",
    2: "Замок не найден. Права не изменены.",
    5: "Доступ уже назначен. Права не изменены.",
    6: "Доступ уже отсутствует. Права не изменены.",
}


class QuitRequested(Exception):
    pass


class SelectionChanged(Exception):
    pass


class WriteUncertain(Exception):
    """Соединение прервалось: автоматически повторять запись нельзя."""


@dataclass(frozen=True)
class Entity:
    kind: str
    number: Optional[int]        # main.id или locks.lock_id; None для карты без main
    label: Optional[str]
    card_id: Optional[int] = None


def clean(value):
    """Не даём переносам, табуляциям и управляющим символам ломать консоль."""
    if value is None:
        return "—"
    return "".join(c if c.isprintable() else " " for c in str(value))


def format_number(value):
    """Только отображение: SQL получает исходные целые числа."""
    if value is None:
        return "—"
    return f"{value:,}".replace(",", " ")


def compact_number(value):
    """Принимает обычные и неразрывные пробелы в скопированных номерах."""
    compact = "".join(value.split())
    if compact.isascii() and compact.isdecimal():
        return compact
    return value


def entity_text(entity, widths=None):
    kind = {"person": "ЧЕЛОВЕК", "lock": "ЗАМОК", "orphan": "НЕТ В MAIN"}[entity.kind]
    id_label = "lock_id" if entity.kind == "lock" else "id"
    number = format_number(entity.number)
    card = format_number(entity.card_id)
    label = clean(entity.label) if entity.label else (
        "(без описания)" if entity.kind == "lock" else "(без имени)"
    )
    if widths is None:
        return f"{kind} | {id_label} {number} | card_id {card} | {label}"
    kind_width, number_width, card_width = widths
    return (f"{kind:<{kind_width}} | {id_label:<7} {number:>{number_width}}"
            f" | card_id {card:>{card_width}} | {label}")


def aligned_entity_lines(entities):
    """Общие ширины на весь список: колонки не прыгают между страницами."""
    if not entities:
        return []
    widths = (
        10 if any(item.kind == "orphan" for item in entities) else 7,
        max(len(format_number(item.number)) for item in entities),
        max(len(format_number(item.card_id)) for item in entities),
    )
    return [entity_text(item, widths) for item in entities]


def read_input(prompt):
    value = input(prompt).strip()
    if value.lower() == ":q":
        raise QuitRequested
    return value


def like_pattern(value):
    # ESCAPE '=': %, _ и = ищутся буквально; пользовательский ввод — параметр.
    return "%" + value.replace("=", "==").replace("%", "=%").replace("_", "=_") + "%"


def person_from_row(row):
    return Entity("person", row["id"], row["name"], row["card_id"])


def lock_from_row(row):
    return Entity("lock", row["lock_id"], row["description"])


class Database:
    def __init__(self, connection):
        self.connection = connection

    def rows(self, sql, args=()):
        with self.connection.cursor() as cursor:
            cursor.execute(sql, args)
            return list(cursor.fetchall())

    def check_read_access(self):
        # Одновременно проверяем права и ожидаемые имена столбцов.
        self.rows("SELECT id, card_id, name FROM main LIMIT 0")
        self.rows("SELECT lock_id, description FROM locks LIMIT 0")
        self.rows("SELECT lock_id, card_id FROM lock_access LIMIT 0")

    def search(self, text, kind=None):
        pattern = like_pattern(text)
        number_text = compact_number(text)
        number_pattern = like_pattern(number_text)
        found = []
        if kind in (None, "person"):
            rows = self.rows("""
                SELECT id, card_id, name FROM main
                WHERE name LIKE %s ESCAPE '='
                   OR CAST(id AS CHAR) LIKE %s ESCAPE '='
                   OR CAST(card_id AS CHAR) LIKE %s ESCAPE '='
                ORDER BY name, id
            """, (pattern, number_pattern, number_pattern))
            found.extend(person_from_row(row) for row in rows)
        if kind in (None, "lock"):
            rows = self.rows("""
                SELECT lock_id, description FROM locks
                WHERE description LIKE %s ESCAPE '='
                   OR CAST(lock_id AS CHAR) LIKE %s ESCAPE '='
                ORDER BY description, lock_id
            """, (pattern, number_pattern))
            found.extend(lock_from_row(row) for row in rows)
        # Точные совпадения номера/имени показываем перед частичными.
        needle = text.casefold()
        found.sort(key=lambda item: not (
            needle and (
                needle == (item.label or "").casefold()
                or number_text == str(item.number)
                or (item.card_id is not None and number_text == str(item.card_id))
            )
        ))
        return found

    def refresh(self, entity):
        if entity.kind == "lock":
            rows = self.rows("""
                SELECT lock_id, description FROM locks WHERE lock_id = %s
            """, (entity.number,))
            if not rows:
                raise SelectionChanged("Этот замок уже удалён или его номер изменён.")
            return lock_from_row(rows[0])
        if entity.card_id is None:
            raise SelectionChanged("У пользователя не задан card_id. Выдача доступа невозможна.")
        rows = self.rows("""
            SELECT id, card_id, name FROM main WHERE card_id = %s
        """, (entity.card_id,))
        if not rows:
            raise SelectionChanged("Пользователь с выбранным card_id больше не найден.")
        if len(rows) != 1:
            raise SelectionChanged(
                "Один card_id назначен нескольким пользователям. Исправь дубликаты в main."
            )
        return person_from_row(rows[0])

    def access_lines(self, entity):
        if entity.kind == "person":
            rows = self.rows("""
                SELECT l.lock_id, l.description
                FROM lock_access AS a
                JOIN locks AS l ON l.lock_id = a.lock_id
                WHERE a.card_id = %s
                ORDER BY l.description, l.lock_id
            """, (entity.card_id,))
            return aligned_entity_lines([lock_from_row(row) for row in rows])
        rows = self.rows("""
            SELECT a.card_id, u.id, u.name
            FROM lock_access AS a
            LEFT JOIN main AS u ON u.card_id = a.card_id
            WHERE a.lock_id = %s
            ORDER BY u.name, a.card_id, u.id
        """, (entity.number,))
        entities = []
        for row in rows:
            if row["id"] is None:
                entities.append(Entity(
                    "orphan", None,
                    "право сохранено, но checkLockAccess запретит проход",
                    row["card_id"],
                ))
            else:
                entities.append(person_from_row(row))
        return aligned_entity_lines(entities)

    def set_access(self, lock_id, card_id, grant):
        """Одна транзакция, без автоматического переподключения и повторной записи."""
        if type(grant) is not bool:
            raise ValueError("grant должен быть bool")
        try:
            self.connection.begin()
            with self.connection.cursor() as cursor:
                cursor.execute("SET @lock_manager_err = NULL")
                cursor.execute(
                    "CALL setLockAccess(%s, %s, %s, @lock_manager_err)",
                    (lock_id, card_id, int(grant)),
                )
                # CALL имеет дополнительные наборы результатов, включая пустой.
                while cursor.nextset():
                    pass
                cursor.execute("SELECT @lock_manager_err AS errCode")
                row = cursor.fetchone()
                if row is None or row["errCode"] is None:
                    raise ValueError("setLockAccess не вернула errCode. Изменения отменены.")
                code = int(row["errCode"])
                if code != 0 and code not in BUSINESS_ERRORS:
                    raise ValueError(
                        f"Неизвестный errCode={format_number(code)}. Изменения отменены."
                        " Проверь версию setLockAccess."
                    )
            if code == 0:
                self.connection.commit()
            else:
                self.connection.rollback()
            return code
        except BaseException as error:
            try:
                self.connection.rollback()
            except Exception:
                pass
            if isinstance(error, pymysql.MySQLError) and (
                not self.connection.open or (error.args and error.args[0] in (2006, 2013, 2055))
            ):
                raise WriteUncertain(
                    "Связь потеряна во время изменения. Результат не подтверждён. "
                    "После повторного запуска проверь список прав; "
                    "скрипт не повторяет изменение автоматически."
                ) from error
            raise


def show_page(lines, page):
    total_pages = max(1, (len(lines) + PAGE_SIZE - 1) // PAGE_SIZE)
    start = page * PAGE_SIZE
    index_width = max(3, len(format_number(len(lines))))
    for index, line in enumerate(lines[start:start + PAGE_SIZE], start + 1):
        print(f"{format_number(index):>{index_width}}. {line}")
    print(f"Страница {format_number(page + 1)}/{format_number(total_pages)}."
          f" Всего: {format_number(len(lines))}.")
    return total_pages


def choose_candidate(db, kind=None):
    title = {None: "людей и замков", "person": "людей", "lock": "замков"}[kind]
    while True:
        print(f"\nПоиск {title}: имя / описание / номер или его часть.")
        text = read_input("Строка [Enter — все, :b — назад, :q — выход]: ")
        if text.lower() == ":b":
            return None
        found = db.search(text, kind)
        if not found:
            print("Совпадений нет. Попробуй другую строку.")
            continue
        page = 0
        lines = aligned_entity_lines(found)
        while True:
            pages = show_page(lines, page)
            command = read_input(
                "Номер кандидата; n/p — страницы; Enter — другой поиск; :b — назад: "
            ).lower()
            command = compact_number(command)
            if not command:
                break
            if command == ":b":
                return None
            if command == "n":
                page = min(page + 1, pages - 1)
            elif command == "p":
                page = max(page - 1, 0)
            elif command.isascii() and command.isdecimal() and 1 <= int(command) <= len(found):
                return found[int(command) - 1]
            else:
                print("Введи порядковый номер из списка (не id) или команду.")


def change_access(db, selected, grant):
    other = choose_candidate(db, "lock" if selected.kind == "person" else "person")
    if other is None:
        return
    person = db.refresh(selected if selected.kind == "person" else other)
    lock = db.refresh(selected if selected.kind == "lock" else other)
    action = "НАЗНАЧИТЬ ДОСТУП" if grant else "ОТОЗВАТЬ ДОСТУП"
    print(f"\n{action}")
    for line in aligned_entity_lines([person, lock]):
        print(line)
    if read_input("Применить? [да / Enter — отмена]: ").lower() not in ("да", "д", "yes", "y"):
        print("Отменено.")
        return
    code = db.set_access(lock.number, person.card_id, grant)
    if code == 0:
        print("ГОТОВО: доступ назначен." if grant else "ГОТОВО: доступ отозван.")
    else:
        print(f"Код {format_number(code)}: {BUSINESS_ERRORS[code]}")


def inspect_entity(db, selected):
    page = 0
    while True:
        try:
            selected = db.refresh(selected)
        except SelectionChanged as error:
            print(clean(error))
            return
        print("\n" + entity_text(selected))
        print("Доступные замки:" if selected.kind == "person" else "Карты с правом доступа:")
        lines = db.access_lines(selected)
        page = min(page, max(0, (len(lines) - 1) // PAGE_SIZE))
        pages = show_page(lines, page) if lines else 1
        if not lines:
            print("Выданных прав нет.")
        print("\n1 — назначить доступ")
        print("2 — отозвать доступ")
        print("3 — обновить")
        print("0 / Enter — новый поиск")
        print(":q — выход")
        if pages > 1:
            print("n — следующая страница")
            print("p — предыдущая страница")
        command = read_input("Действие: ").lower()
        if command in ("", "0", ":b"):
            return
        if command in ("1", "2"):
            try:
                change_access(db, selected, command == "1")
            except (SelectionChanged, ValueError) as error:
                print(clean(error))
            except pymysql.MySQLError as error:
                if not db.connection.open:
                    raise
                print_sql_error(error)
        elif command == "n":
            page = min(page + 1, pages - 1)
        elif command == "p":
            page = max(0, page - 1)
        elif command != "3":
            print("Неизвестная команда.")


def prompt_default(label, default):
    return read_input(f"{label} [{default}]: ") or default


def connect_interactively():
    host, port, user = DEFAULT_HOST, DEFAULT_PORT, DEFAULT_USER
    while True:
        print("\nПодключение к MySQL. Enter — значение в скобках; :q — выход.")
        host = prompt_default("IP / имя сервера", host)
        while True:
            raw_port = compact_number(str(prompt_default("Порт", port)))
            if raw_port.isascii() and raw_port.isdecimal() and 1 <= int(raw_port) <= 65535:
                port = int(raw_port)
                break
            print("Порт должен быть числом от 1 до 65535.")
        user = prompt_default("Пользователь", user)
        password = getpass("Пароль (ввод скрыт): ")
        try:
            return pymysql.connect(
                host=host, port=port, user=user, password=password, database=DATABASE_NAME,
                charset="utf8mb4", cursorclass=DictCursor, autocommit=True,
                connect_timeout=10, read_timeout=30, write_timeout=30,
            )
        except pymysql.MySQLError as error:
            print_sql_error(error)
            if read_input("Enter — повторить подключение; :q — выход: "):
                print("Введи параметры подключения ещё раз.")


def print_sql_error(error):
    code = error.args[0] if error.args else "?"
    message = error.args[1] if len(error.args) > 1 else str(error)
    shown_code = format_number(code) if isinstance(code, int) else clean(code)
    print(f"Ошибка MySQL {shown_code}: {clean(message)}")
    if code in (1142, 1143, 1370):
        print("Нужны SELECT на main, locks, lock_access и EXECUTE на setLockAccess.")
    elif code == 1305:
        print(f"Проверь наличие setLockAccess в базе {DATABASE_NAME}.")


def main():
    connection = None
    try:
        print("CYBERWALL — управление доступом к замкам")
        connection = connect_interactively()
        db = Database(connection)
        db.check_read_access()
        print("Подключено. Изменения выполняются только после подтверждения.")
        while True:
            selected = choose_candidate(db)
            if selected is not None:
                inspect_entity(db, selected)
    except (QuitRequested, EOFError, KeyboardInterrupt):
        print("\nРабота завершена.")
        return 0
    except WriteUncertain as error:
        print(clean(error))
        return 1
    except pymysql.MySQLError as error:
        print_sql_error(error)
        print("Работа остановлена. После восстановления связи запусти скрипт снова.")
        return 1
    finally:
        if connection is not None and connection.open:
            connection.close()


if __name__ == "__main__":
    sys.exit(main())

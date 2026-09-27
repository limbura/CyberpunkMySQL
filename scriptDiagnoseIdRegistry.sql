-- Диагностика реестра использованных id
--
-- ЗАПУСК:
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. Результаты будут в нескольких вкладках.
-- Можно выделить и выполнить один нужный SELECT отдельно.
--
-- ИНТЕРПРЕТАЦИЯ:
-- OK — конкретная проверка не нашла нарушений.
-- ERROR — нарушение проверяемого требования. Это не SQL-ошибка выполнения.
-- WARN — нужна проверка вручную; ситуация не обязательно является ошибкой.
-- Наличие старых коротких id (1, 123, 321 и т.п.) вызывает ERROR диапазона.
-- Один id может попасть в несколько проверок; счётчики не нужно складывать.
-- Для дублей issue_count — число повторяющихся id, не число лишних строк.
--
-- ИСТОРИЯ:
-- Старый id после changeId должен оставаться в реестре.
-- Отсутствие старого id в main и отсутствие его card_id в main допустимы:
-- пользователь мог сменить id, изменить card_id или удалить запись.
-- Несколько id с одним card_id — тоже допустимая история.
-- CARD_ID_MISMATCH — предупреждение, поскольку ручная смена main.card_id
-- не обязательно должна переписывать исторический card_id в реестре.
-- Нули в реестре могли остаться из-за прежнего BEFORE INSERT с AUTO_INCREMENT,
-- прямого вызова generateId или пропущенной вставки IGNORE / ON DUPLICATE KEY.
--
-- ГРАНИЦЫ ПРОВЕРКИ:
-- По текущим двум таблицам нельзя доказать, что исторические строки никогда
-- не удаляли, id никогда не переиспользовали, а старый card_id не подменили.
-- Нельзя восстановить владельца старого id, если нет внешней истории.
-- Наличие триггера/процедуры не доказывает корректность его кода и всех прав.
-- Для таких гарантий нужны журнал/резервные копии и функциональные тесты.
-- Если запрос завершился SQL-ошибкой, эта проверка НЕ считается пройденной.

-- 1. На каком сервере выполняется диагностика.
SELECT
	NOW(6) AS checked_at,
	@@hostname AS server_name,
	@@port AS server_port,
	VERSION() AS mysql_version,
	CURRENT_USER() AS account_used,
	'cyberwall' AS checked_schema;

-- 2. Главная сводка: в норме все статусы OK.
SELECT checks.check_no, checks.check_code,
	CASE WHEN checks.issue_count = 0 THEN 'OK' ELSE checks.severity END AS status,
	checks.issue_count, checks.description
FROM (
SELECT 1 AS check_no, 'MISSING_REGISTRY' AS check_code, 'ERROR' AS severity,
	'Текущий ID из main отсутствует в реестре' AS description, COUNT(*) AS issue_count
FROM (
	SELECT m.id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE NOT EXISTS (SELECT 1 FROM cyberwall.id_registry AS r WHERE r.id = m.id)
) AS found
UNION ALL
SELECT 2 AS check_no, 'CARD_ID_MISMATCH' AS check_code, 'WARN' AS severity,
	'Для текущего ID различаются card_id: ошибка привязки или ручная смена карты' AS description, COUNT(*) AS issue_count
FROM (
	SELECT m.id, m.card_id AS main_card_id, r.card_id AS registry_card_id, m.name, r.registered_at FROM cyberwall.main AS m JOIN cyberwall.id_registry AS r ON r.id = m.id WHERE m.card_id <> r.card_id OR m.card_id IS NULL OR r.card_id IS NULL
) AS found
UNION ALL
SELECT 3 AS check_no, 'MAIN_ID_RANGE' AS check_code, 'ERROR' AS severity,
	'ID в main не состоит из 9 цифр; ранее созданные короткие ID тоже попадут сюда' AS description, COUNT(*) AS issue_count
FROM (
	SELECT m.id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE m.id IS NULL OR m.id < 100000000 OR m.id > 999999999
) AS found
UNION ALL
SELECT 4 AS check_no, 'REGISTRY_ID_RANGE' AS check_code, 'ERROR' AS severity,
	'ID в реестре не состоит из 9 цифр; ранее созданные короткие ID тоже попадут сюда' AS description, COUNT(*) AS issue_count
FROM (
	SELECT r.id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.id IS NULL OR r.id < 100000000 OR r.id > 999999999
) AS found
UNION ALL
SELECT 5 AS check_no, 'REGISTRY_CARD_ID_ZERO' AS check_code, 'WARN' AS severity,
	'В реестре card_id равен 0 или NULL: возможно, остался временный номер' AS description, COUNT(*) AS issue_count
FROM (
	SELECT r.id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.card_id = 0 OR r.card_id IS NULL
) AS found
UNION ALL
SELECT 6 AS check_no, 'MAIN_CARD_ID_ZERO' AS check_code, 'WARN' AS severity,
	'В main card_id равен 0 или NULL: проверить, было ли это намеренно' AS description, COUNT(*) AS issue_count
FROM (
	SELECT m.id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE m.card_id = 0 OR m.card_id IS NULL
) AS found
UNION ALL
SELECT 7 AS check_no, 'REGISTRY_TIME_INVALID' AS check_code, 'WARN' AS severity,
	'В реестре отсутствует дата регистрации или сохранена нулевая дата' AS description, COUNT(*) AS issue_count
FROM (
	SELECT r.id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.registered_at IS NULL OR CAST(r.registered_at AS CHAR) LIKE '0000-%'
) AS found
UNION ALL
SELECT 8 AS check_no, 'DUPLICATE_MAIN_ID' AS check_code, 'ERROR' AS severity,
	'ID встречается в main несколько раз; количество групп дублей' AS description, COUNT(*) AS issue_count
FROM (
	SELECT m.id, NULL AS main_card_id, NULL AS registry_card_id, NULL AS name, NULL AS registered_at FROM cyberwall.main AS m GROUP BY m.id HAVING COUNT(*) > 1
) AS found
UNION ALL
SELECT 9 AS check_no, 'DUPLICATE_REGISTRY_ID' AS check_code, 'ERROR' AS severity,
	'ID встречается в реестре несколько раз; количество групп дублей' AS description, COUNT(*) AS issue_count
FROM (
	SELECT r.id, NULL AS main_card_id, NULL AS registry_card_id, NULL AS name, NULL AS registered_at FROM cyberwall.id_registry AS r GROUP BY r.id HAVING COUNT(*) > 1
) AS found
) AS checks
ORDER BY checks.check_no;

-- 3. Подробности нарушений: пустой результат означает отсутствие найденных проблем.
-- NULL в незаполненной колонке означает, что она не нужна этой проверке.
SELECT report.check_no, report.check_code, report.severity,
	report.id, report.main_card_id, report.registry_card_id, report.name, report.registered_at
FROM (
SELECT 1 AS check_no, 'MISSING_REGISTRY' AS check_code, 'ERROR' AS severity,
	m.id AS id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE NOT EXISTS (SELECT 1 FROM cyberwall.id_registry AS r WHERE r.id = m.id)
UNION ALL
SELECT 2 AS check_no, 'CARD_ID_MISMATCH' AS check_code, 'WARN' AS severity,
	m.id AS id, m.card_id AS main_card_id, r.card_id AS registry_card_id, m.name, r.registered_at FROM cyberwall.main AS m JOIN cyberwall.id_registry AS r ON r.id = m.id WHERE m.card_id <> r.card_id OR m.card_id IS NULL OR r.card_id IS NULL
UNION ALL
SELECT 3 AS check_no, 'MAIN_ID_RANGE' AS check_code, 'ERROR' AS severity,
	m.id AS id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE m.id IS NULL OR m.id < 100000000 OR m.id > 999999999
UNION ALL
SELECT 4 AS check_no, 'REGISTRY_ID_RANGE' AS check_code, 'ERROR' AS severity,
	r.id AS id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.id IS NULL OR r.id < 100000000 OR r.id > 999999999
UNION ALL
SELECT 5 AS check_no, 'REGISTRY_CARD_ID_ZERO' AS check_code, 'WARN' AS severity,
	r.id AS id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.card_id = 0 OR r.card_id IS NULL
UNION ALL
SELECT 6 AS check_no, 'MAIN_CARD_ID_ZERO' AS check_code, 'WARN' AS severity,
	m.id AS id, m.card_id AS main_card_id, NULL AS registry_card_id, m.name, NULL AS registered_at FROM cyberwall.main AS m WHERE m.card_id = 0 OR m.card_id IS NULL
UNION ALL
SELECT 7 AS check_no, 'REGISTRY_TIME_INVALID' AS check_code, 'WARN' AS severity,
	r.id AS id, NULL AS main_card_id, r.card_id AS registry_card_id, NULL AS name, r.registered_at FROM cyberwall.id_registry AS r WHERE r.registered_at IS NULL OR CAST(r.registered_at AS CHAR) LIKE '0000-%'
UNION ALL
SELECT 8 AS check_no, 'DUPLICATE_MAIN_ID' AS check_code, 'ERROR' AS severity,
	m.id AS id, NULL AS main_card_id, NULL AS registry_card_id, NULL AS name, NULL AS registered_at FROM cyberwall.main AS m GROUP BY m.id HAVING COUNT(*) > 1
UNION ALL
SELECT 9 AS check_no, 'DUPLICATE_REGISTRY_ID' AS check_code, 'ERROR' AS severity,
	r.id AS id, NULL AS main_card_id, NULL AS registry_card_id, NULL AS name, NULL AS registered_at FROM cyberwall.id_registry AS r GROUP BY r.id HAVING COUNT(*) > 1
) AS report
ORDER BY report.check_no, report.id;

-- 4. Информация об объёме и истории. Эти числа сами по себе не являются ошибками.
SELECT
	(SELECT COUNT(*) FROM cyberwall.main) AS current_main_rows,
	(SELECT COUNT(*) FROM cyberwall.id_registry) AS registry_rows,
	(SELECT COUNT(*) FROM cyberwall.id_registry AS r
	 WHERE NOT EXISTS (SELECT 1 FROM cyberwall.main AS m WHERE m.id = r.id))
	 AS registry_ids_not_current,
	(SELECT COUNT(*) FROM cyberwall.id_registry AS r
	 WHERE NOT EXISTS (SELECT 1 FROM cyberwall.main AS m WHERE m.card_id = r.card_id))
	 AS registry_rows_without_current_card,
	(SELECT MIN(registered_at) FROM cyberwall.id_registry) AS first_registration,
	(SELECT MAX(registered_at) FROM cyberwall.id_registry) AS last_registration;

-- 5. Последние 50 регистраций, новые сверху.
-- Старые ID без текущей записи main.name будут иметь NULL — это нормально.
-- При одинаковом времени сортировка по id детерминирована, но не доказывает
-- фактическую очередность выдачи внутри этой временной отметки.
SELECT
	r.id,
	r.card_id AS registry_card_id,
	r.registered_at,
	m.card_id AS current_main_card_id,
	m.name AS current_main_name,
	CASE
		WHEN m.id IS NULL THEN 'NOT_CURRENT'
		WHEN m.card_id = r.card_id THEN 'CURRENT_MATCH'
		ELSE 'CURRENT_CARD_MISMATCH'
	END AS relation_to_main
FROM cyberwall.id_registry AS r
LEFT JOIN cyberwall.main AS m ON m.id = r.id
ORDER BY r.registered_at DESC, r.id DESC
LIMIT 50;

-- 6. Движки таблиц: ожидаются две строки с ENGINE = InnoDB.
-- Только InnoDB у обеих таблиц обеспечивает нужный совместный откат изменений.
SELECT TABLE_NAME, ENGINE,
	CASE WHEN ENGINE = 'InnoDB' THEN 'OK' ELSE 'ERROR' END AS engine_status
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'cyberwall'
	AND TABLE_NAME IN ('main', 'id_registry')
ORDER BY TABLE_NAME;

-- 7. Столбцы: сверить типы, NULL, DEFAULT и AUTO_INCREMENT.
-- Ожидается: id — INT UNSIGNED NOT NULL в обеих таблицах;
-- main.id DEFAULT 0, main.card_id — BIGINT UNSIGNED AUTO_INCREMENT;
-- registry.card_id — BIGINT UNSIGNED NOT NULL без AUTO_INCREMENT;
-- registry.registered_at — DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6).
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE,
	COLUMN_DEFAULT, EXTRA
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'cyberwall'
	AND TABLE_NAME IN ('main', 'id_registry')
	AND COLUMN_NAME IN ('id', 'card_id', 'registered_at')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 8. Индексы (каждая строка — столбец индекса).
-- Ожидаются PRIMARY(id) в id_registry, PRIMARY(card_id) и UNIQUE(id) в main.
-- NON_UNIQUE = 0 означает уникальный индекс.
-- Для защиты id индекс должен быть уникальным именно по одному id,
-- составной UNIQUE(id, card_id) эту гарантию не заменяет.
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'cyberwall'
	AND TABLE_NAME IN ('main', 'id_registry')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- 9. Триггеры на main и id_registry: справочный вывод для проверки кода.
-- В текущей схеме нужны mainBeforeInsert и mainAfterInsert на main:
-- BEFORE INSERT вызывает generateId и присваивает NEW.id;
-- AFTER INSERT записывает NEW.card_id в реестр ПО УСЛОВИЮ id = NEW.id.
-- Также показаны другие триггеры, если появились: они могут влиять на результат.
SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION,
	ACTION_ORDER, DEFINER, ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'cyberwall'
	AND EVENT_OBJECT_TABLE IN ('main', 'id_registry')
ORDER BY EVENT_OBJECT_TABLE, EVENT_MANIPULATION, ACTION_TIMING, ACTION_ORDER;

-- 10. Процедуры выдачи и смены ID: ожидаются две строки, SECURITY_TYPE = DEFINER.
-- DEFINER должен существовать и иметь необходимые права. Его наличие в этом
-- выводе не подтверждает ни существование учётной записи, ни достаточность прав.
SELECT ROUTINE_NAME, ROUTINE_TYPE, SECURITY_TYPE, DEFINER, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'cyberwall'
	AND ROUTINE_NAME IN ('generateId', 'changeId')
ORDER BY ROUTINE_NAME;

-- Скрипт для создания пользователя master c широкими возможностями кроме опасных действий которые могут все сломать
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. 

-- Удаление пользователя если он уже есть
DROP USER IF EXISTS 'master'@'%';

-- Создать пользователя и задать пароль
CREATE USER 'master'@'%'
    IDENTIFIED BY 'master';

-- Разрешить чтение всех таблиц базы cyberwall
GRANT SELECT
ON cyberwall.*
TO 'master'@'%';

-- MAIN: добавление записей
GRANT INSERT
ON cyberwall.main
TO 'master'@'%';

-- MAIN: изменение всех столбцов, кроме id и card_id
GRANT UPDATE (
    -- card_id,
    name,
    netrunner_lvl,
    password,
    losa,
    money,
    police,
    occupancy
)
ON cyberwall.main
TO 'master'@'%';

-- ID_REGISTRY: добавление записей
GRANT INSERT
ON cyberwall.id_registry
TO 'master'@'%';

-- ID_REGISTRY: изменение только card_id и registered_at
GRANT UPDATE (
    card_id,
    registered_at
)
ON cyberwall.id_registry
TO 'master'@'%';

-- LOGS: добавление, изменение и удаление записей
GRANT INSERT, UPDATE, DELETE
ON cyberwall.logs
TO 'master'@'%';

-- LOCKS: изменение только описания и команды открытия
GRANT UPDATE (description, open_cmd)
ON cyberwall.locks
TO 'master'@'%';

-- LOCKS: добавление записей
GRANT INSERT
ON cyberwall.locks
TO 'master'@'%';

-- LOCK_ACCESS: просмотр, выдача и отзыв доступа
GRANT SELECT, INSERT, DELETE
ON cyberwall.lock_access
TO 'master'@'%';

-- Вызов процедур -----------------------------------------------------------------------------------------

-- Смена ID через процедуру
GRANT EXECUTE
ON PROCEDURE cyberwall.changeId
TO 'master'@'%';

-- Запись действий нетраннеров
GRANT EXECUTE
ON PROCEDURE cyberwall.logNetrunAction
TO 'master'@'%';

-- Общая процедура перевода баланса
GRANT EXECUTE
ON PROCEDURE cyberwall.transferBalanceCommon
TO 'master'@'%';

-- Перевод баланса по card_id для терминалов
GRANT EXECUTE
ON PROCEDURE cyberwall.transferBalanceTerminal
TO 'master'@'%';

-- Проверка доступа к замку
GRANT EXECUTE
ON PROCEDURE cyberwall.checkLockAccess
TO 'master'@'%';

-- Назначение и отзыв доступа к замку
GRANT EXECUTE
ON PROCEDURE cyberwall.setLockAccess
TO 'master'@'%';

-- Показать итоговые права
SHOW GRANTS FOR 'master'@'%';
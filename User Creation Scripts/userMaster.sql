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

-- MAIN: добавление и удаление записей
GRANT INSERT, DELETE
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

-- Разрешить смену ID через процедуру
GRANT EXECUTE
ON PROCEDURE cyberwall.changeId
TO 'master'@'%';

-- Запись действий нетраннера
GRANT EXECUTE
ON PROCEDURE cyberwall.logNetrunAction
TO 'master'@'%';

-- Общая процедура перевода баланса
GRANT EXECUTE
ON PROCEDURE cyberwall.transferBalanceCommon
TO 'master'@'%';

-- Перевод баланса по card_id
GRANT EXECUTE
ON PROCEDURE cyberwall.transferBalanceTerminal
TO 'master'@'%';

-- Показать итоговые права
SHOW GRANTS FOR 'master'@'%';
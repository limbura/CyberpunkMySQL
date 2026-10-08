-- Скрипт для создания пользователя terminal: права SELECT для main и вызова transferBalanceTerminal
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. 

-- Удаление пользователя если он уже есть
DROP USER IF EXISTS 'terminal'@'%';

-- Создать пользователя и задать пароль
CREATE USER 'terminal'@'%'
    IDENTIFIED BY 'term1n0l';

-- MAIN: чтение всех столбцов.
GRANT SELECT
ON cyberwall.main
TO 'terminal'@'%';

-- Перевод между картами через процедуру
GRANT EXECUTE
ON PROCEDURE cyberwall.transferBalanceTerminal
TO 'terminal'@'%';

-- Показать итоговые права
SHOW GRANTS FOR 'terminal'@'%';
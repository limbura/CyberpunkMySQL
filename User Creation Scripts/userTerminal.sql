-- Active: 1790464578606@@127.0.0.1@3306@cyberwall
-- Скрипт для создания пользователя terminal: права SELECT для main и вызова transferBalanceTerminal
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. 

-- Удаление пользователя если он уже есть
DROP USER IF EXISTS 'terminal'@'%';

-- Создать пользователя и задать пароль
-- ESP32 поддерживают только старый механизм аутентификации
-- Его необходимо включить. В файле my.ini который лежит обычно например в C:\ProgramData\MySQL\MySQL Server 8.4\my.ini
-- В секции [mysqld] добавить строчку:
-- mysql_native_password=ON
-- Затем перезапустить сервис MySQL
CREATE USER 'terminal'@'%'
    IDENTIFIED WITH mysql_native_password
	BY 'term1n0l';

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
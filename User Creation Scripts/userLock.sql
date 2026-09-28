-- Скрипт для создания пользователя lock: права SELECT для main, SELECT для locks и записи locks.open_cmd, вызова checkLockAccess
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. 

-- Удаление пользователя если он уже есть
DROP USER IF EXISTS 'lock'@'%';

-- Создать пользователя и задать пароль
CREATE USER 'lock'@'%'
	IDENTIFIED BY 'lock';

-- Чтение пользователей
GRANT SELECT
ON cyberwall.main
TO 'lock'@'%';

-- Чтение замков
GRANT SELECT
ON cyberwall.locks
TO 'lock'@'%';

-- Запись locks.open_cmd
GRANT UPDATE (open_cmd)
ON cyberwall.locks
TO 'lock'@'%';

-- Проверка доступа карты к замку
GRANT EXECUTE
ON PROCEDURE cyberwall.checkLockAccess
TO 'lock'@'%';

-- Показать итоговые права
SHOW GRANTS FOR 'lock'@'%';
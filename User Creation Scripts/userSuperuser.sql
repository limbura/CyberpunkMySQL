-- Скрипт для создания пользователя админа MySQL. Аналог root, допускающий подключения с любых адресов
-- Выполнить под root или другим администратором MySQL
-- VS Code / Database Client: Ctrl+Shift+Enter — выполнить весь файл.
-- DBeaver: Alt+X — выполнить как скрипт. 

-- Создать пользователя, если он ещё не существует
CREATE USER IF NOT EXISTS 'superuser'@'%'
    IDENTIFIED BY 'superuser';

-- Выдать все глобальные привилегии
GRANT ALL PRIVILEGES
ON *.*
TO 'superuser'@'%'
WITH GRANT OPTION;

-- Показать итоговые права
SHOW GRANTS FOR 'superuser'@'%';
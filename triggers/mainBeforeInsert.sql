DROP TRIGGER IF EXISTS mainBeforeInsert;
CREATE TRIGGER mainBeforeInsert
BEFORE INSERT ON main						-- Код выполняется перед INSERT в main
FOR EACH ROW								-- Для каждой добавляемой INSERT строки
BEGIN

	-- Этот код выполняется каждый раз когда происходит добавление новой записи в таблицу main
	-- Он генерирует новый уникальный id пользователя которого еще никогда не было в БД и добавляет его в список уже использованных
	-- Генерация происходит даже если id попытались указать при вставке - все равно будет задан сгенерированный вместо указанного

    DECLARE _newId INT UNSIGNED;
    -- Сгенерировать id и добавить его в реестр
    CALL generateId(NEW.card_id, _newId);
    -- Присвоить id создаваемой записи
    SET NEW.id = _newId;
END;
-- ALTER TABLE main
--     ALTER COLUMN id SET DEFAULT 0;
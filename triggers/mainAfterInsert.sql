DROP TRIGGER IF EXISTS mainAfterInsert;
CREATE TRIGGER mainAfterInsert
AFTER INSERT ON cyberwall.main              -- Код выполняется после INSERT в main
FOR EACH ROW                                -- Для каждой добавленной INSERT строки
	-- Этот код выполняется каждый раз после того как происходит добавление новой записи в таблицу main
	-- Он еще раз задает card_id в таблице id_registry на случай если beforeInsert получил card_id = 0 
	-- когда при создании записи card_id не был указан и назначился авто инкрементом
    UPDATE cyberwall.id_registry
    SET card_id = NEW.card_id
    WHERE id = NEW.id;
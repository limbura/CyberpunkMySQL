DROP PROCEDURE IF EXISTS changeId;
CREATE PROCEDURE `changeId` (
    IN cardId   BIGINT UNSIGNED,            -- card_id пользователя, которому необходимо сменить id
    OUT newId   INT UNSIGNED,				-- Новый назначенный ему id
    OUT errCode	INT                         -- Код ошибки, 0 успешно, таблица ниже
)
BEGIN

    -- Смена ID существующей записи по ее card_id
    -- Это самостоятельная транзакция. Вызывать на соединении без незавершенной
    -- транзакции: START TRANSACTION в MySQL не поддерживает вложенность
	-- Возможна проблема: при обрыве связи в момент выполнения клиент может не получить новый id, но id при этом будет изменен!

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 изменение ID не было произведено!
	
	0 	- NO_ERROR							(нет ошибок, успешное выполнение)
	1 	- SENDER_NOT_FOUND 					(пользователь не найден в БД, для перевода - отправитель не найден в БД)
	*/

	-- Объявления +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    DECLARE _oldId INT UNSIGNED;            -- Старый id
    DECLARE _newId INT UNSIGNED;            -- Новый id
    DECLARE _found BOOLEAN DEFAULT TRUE;	-- Признак "пользователь найден в БД"

    -- Любая SQL-ошибка = откат транзакции и вернуть ошибку тому кто вызвал процедуру
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;							-- Откатить все изменения если они были сделаны
        SET newId = NULL;
        RESIGNAL;							-- Отправить код ошибки SQL вызывающему процедуру
    END;

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SET errCode = 0;

    START TRANSACTION;

	-- Проверить наличие пользователя с таким card_id, попытавшись получить его старый id и заблокировать строку от изменений
    BEGIN
		-- Обработка ошибки "пользователя с таким card_id нет в БД"
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET _found = FALSE;

        SELECT main.id INTO _oldId
        FROM main
        WHERE main.card_id = cardId
        FOR UPDATE;
    END;

    IF _found THEN

		-- Пользователь найден
		CALL `generateId`(cardId, _newId);	-- Сгенерировать новый уникальный id который никогда ранее не использовался
		
		-- Изменить id в main
		UPDATE `main`
		SET `id` = _newId
		WHERE `card_id` = cardId;

		COMMIT;
    	SET newId = _newId;

	ELSE

		-- Пользователь не наден
		ROLLBACK;
    	SET newId = NULL;
		SET errCode = 1;

    END IF;

END;
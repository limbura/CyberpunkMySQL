DROP PROCEDURE IF EXISTS generateId;
CREATE PROCEDURE `generateId` (
    IN cardId BIGINT UNSIGNED,  -- card_id для указания в реестре использованных id
    OUT newId INT UNSIGNED      -- Уникальный id который не использовался раньше, для назначения пользователю
)
procedure_block: BEGIN

	-- Внутренняя процедура создания нового id
	-- КЛИЕНТЫ НЕ ДОЛЖНЫ ВЫЗЫВАТЬ ЭТУ ПРОЦЕДУРУ! Право вызова только у root!
	-- Вызываетcя ВНУТРИ транзакции создающей/меняющей запись процедуры/программы
	-- Сама не делает START TRANSACTION, COMMIT или ROLLBACK
	-- Не передавать полученный id пользователю до успешного COMMIT!
	-- При любой ошибке вызывающий код должен откатить всю транзакцию

    DECLARE _candidate INT UNSIGNED;            -- Сгенерированный случайно id
    DECLARE _attempt INT UNSIGNED DEFAULT 0;    -- Текущий номер попытки сгенерировать id, который не использовался ранее
    DECLARE _duplicate BOOLEAN DEFAULT FALSE;   -- Признак того что сгенерированный id уже использовался

    SET newId = NULL;

	-- Обработка ошибки "cardId не указан"
    IF cardId IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CARD_ID_IS_NULL';
    END IF;

	-- Генерация id - не более 200 раз попытаться сгенерировать случайный id до тех пор пока он не будет уникальным
	-- Шанс что уникальный id не будет сгенерирован за 200 попыток близок к нулю, но теоретически возможен
    WHILE _attempt < 200 DO
        SET _attempt = _attempt + 1;
        SET _candidate = FLOOR(100000000 + RAND() * 900000000);
        SET _duplicate = FALSE;

		-- Попытка добавить сгенерированный id в реестр использованных id
        BEGIN
            -- Обработка ошибки "такой id уже есть в реестре использованных"
            DECLARE CONTINUE HANDLER FOR 1062 SET _duplicate = TRUE;

            INSERT INTO `id_registry` (`id`, `card_id`)
            VALUES (_candidate, cardId);
        END;

		-- id не был в реестре использованных и успешно добавлен
        IF NOT _duplicate THEN
            SET newId = _candidate;
            LEAVE procedure_block;		-- Выйти из процедуры
        END IF;
    END WHILE;

    -- За 200 попыток так и не удалось сгенерировать уникальный id - вернуть ошибку (шанс этого исключения близко к нулю, но оно теоретически возможно)
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ID_GENERATION_RETRY_LIMIT_TRY_AGAIN';
END;
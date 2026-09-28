DROP PROCEDURE IF EXISTS setLockAccess;
-- CREATE DEFINER=`testuser`@`%` PROCEDURE `setLockAccess`(
CREATE PROCEDURE `setLockAccess`(
    IN 	lock_id 		INT UNSIGNED,			-- id замка
	IN 	card_id			BIGINT UNSIGNED,		-- id карты пользователя
	IN	grantAccess		BOOL,					-- TRUE: назначить, FALSE: отозвать
	OUT errCode			INT						-- Код ошибки, 0 успешно, таблица ниже
)
BEGIN

    /*
    Назначает или отзывает пользователю с card_id доступ к замку с lock_id
    */

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 права доступа не изменяются. Внимательно следи за цифрами кодов, они не подряд!

	0 	- NO_ERROR					(нет ошибок, успешное выполнение)
	1 	- USER_NOT_FOUND 			(пользователя с таким card_id не найдено в базе)
	2	- LOCK_NOT_FOUND			(замка с таким lock_id не найдено в базе)
	5 	- ACCESS_ALREADY_GRANTED  	(этот пользователь итак имеет доступ к этому замку)
	6 	- ACCESS_ALREADY_REVOKED  	(этот пользователь итак не имеет доступа к этому замку)
	*/

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- Начальные значения
	SET errCode = 0;

	-- Проверка допустимости grantAccess
	IF grantAccess IS NULL OR grantAccess NOT IN (0, 1) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'grantAccess должен быть TRUE (1) или FALSE (0)';

	-- Проверка существования пользователя
	ELSEIF NOT EXISTS (
		SELECT 1
		FROM main
		WHERE main.card_id = card_id
	) THEN
		SET errCode = 1;

	-- Проверка существования замка
	ELSEIF NOT EXISTS (
		SELECT 1
		FROM locks
		WHERE locks.lock_id = lock_id
	) THEN
		SET errCode = 2;

	-- Назначение доступа
	ELSEIF grantAccess = TRUE THEN
		BEGIN
			-- Повторная пара (lock_id, card_id) запрещена PRIMARY KEY
			-- Преобразовать ошибку дубликата MySQL в код ошибки процедуры "доступ уже назначен"
			DECLARE CONTINUE HANDLER FOR 1062
				SET errCode = 5;

			INSERT INTO lock_access (lock_id, card_id)
			VALUES (lock_id, card_id);
		END;

	-- Отзыв доступа
	ELSE
		DELETE FROM lock_access
		WHERE lock_access.lock_id = lock_id
			AND lock_access.card_id = card_id;

		-- Если ничего не удалено, доступ уже отсутствовал - вернуть код ошибки процедуры
		IF ROW_COUNT() = 0 THEN
			SET errCode = 6;
		END IF;
		
	END IF;

END;
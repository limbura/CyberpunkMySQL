DROP PROCEDURE IF EXISTS checkLockAccess;
-- CREATE DEFINER=`testuser`@`%` PROCEDURE `checkLockAccess`(
CREATE PROCEDURE `checkLockAccess`(
    IN 	lock_id 		INT UNSIGNED,			-- id замка
	IN 	card_id			BIGINT UNSIGNED			-- id карты пользователя
)
BEGIN

    /*
    Проверяет наличие прав доступа к замку
	Возвращает через SELECT _accessGranted и затем _errCode
    */

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 _accessGranted = FALSE
	0 	- NO_ERROR				(нет ошибок, успешное выполнение)
	1 	- USER_NOT_FOUND 		(пользователя с таким card_id не найдено в базе)
	8	- LOCK_NOT_FOUND		(замка с таким lock_id не найдено в базе)
	*/

	-- Объявления ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	DECLARE _accessGranted BOOL DEFAULT FALSE;	-- TRUE если пользователь имеет права доступа к замку
	DECLARE _errCode	INT DEFAULT 0;			-- Код ошибки, 0 успешно, таблица выше

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- Проверка существования пользователя
	IF NOT EXISTS (
		SELECT 1
		FROM main
		WHERE main.card_id = card_id
	) THEN
		-- Пользователь не найден
		SET _errCode = 1;

	-- Проверка существования замка
	ELSEIF NOT EXISTS (
		SELECT 1
		FROM locks
		WHERE locks.lock_id = lock_id
	) THEN
		-- Замок не найден
		SET _errCode = 8;

	-- Проверка прав доступа
	ELSE
		SET _accessGranted = EXISTS (
			SELECT 1
			FROM lock_access
			WHERE lock_access.lock_id = lock_id
				AND lock_access.card_id = card_id
		);
	END IF;

	-- Вернуть наличие права доступа и код ошибки
	SELECT _accessGranted AS accessGranted, _errCode AS code;

END;
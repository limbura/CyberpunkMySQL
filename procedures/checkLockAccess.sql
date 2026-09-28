DROP PROCEDURE IF EXISTS checkLockAccess;
-- CREATE DEFINER=`testuser`@`%` PROCEDURE `checkLockAccess`(
CREATE PROCEDURE `checkLockAccess`(
    IN 	lock_id 		INT UNSIGNED,			-- id замка
	IN 	card_id			BIGINT UNSIGNED,		-- id карты пользователя
	OUT accessGranted	BOOL,					-- TRUE если пользователь имеет права доступа к замку
	OUT errCode			INT						-- Код ошибки, 0 успешно, таблица ниже
)
BEGIN

    /*
    Проверяет наличие прав доступа к замку
    */

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 accessGranted = FALSE

	0 	- NO_ERROR				(нет ошибок, успешное выполнение)
	1 	- USER_NOT_FOUND 		(пользователя с таким card_id не найдено в базе)
	2	- LOCK_NOT_FOUND		(замка с таким lock_id не найдено в базе)
	*/

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- Начальные значения
	SET accessGranted = FALSE;
	SET errCode = 0;

	-- Проверка существования пользователя
	IF NOT EXISTS (
		SELECT 1
		FROM main
		WHERE main.card_id = card_id
	) THEN
		-- Пользователь не найден
		SET errCode = 1;

	-- Проверка существования замка
	ELSEIF NOT EXISTS (
		SELECT 1
		FROM locks
		WHERE locks.lock_id = lock_id
	) THEN
		-- Замок не найден
		SET errCode = 2;

	-- Проверка прав доступа
	ELSE
		SET accessGranted = EXISTS (
			SELECT 1
			FROM lock_access
			WHERE lock_access.lock_id = lock_id
				AND lock_access.card_id = card_id
		);
	END IF;

END;
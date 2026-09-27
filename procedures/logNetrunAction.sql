DROP PROCEDURE IF EXISTS logNetrunAction;
-- CREATE DEFINER=`testuser`@`%` PROCEDURE `logNetrunAction`(
CREATE PROCEDURE `logNetrunAction`(
    IN 	action 			VARCHAR(50),			-- Логгируемое действие нетраннера, до 50 символов
	IN 	objectId		INT UNSIGNED,			-- id объекта подвергшегося взлому (id персонажа, замка, камеры и т.д.)
    IN 	netrunnerId 	INT UNSIGNED,			-- id нетраннера (не card_id!)
    IN 	isSuccess 		BOOL,					-- TRUE если взлом успешен
	OUT errCode			INT						-- Код ошибки, 0 успешно, таблица ниже
)
BEGIN

    /*
    Добавляет в логи запись NETRUN_SUCCESS action или NETRUN_FAIL action
	Заполняет:
	object_id = objectId
	subject_id = netrunnerId (не card_id!)
	value = уровень нетраннера НА МОМЕНТ ДЕЙСТВИЯ (это важно! апгрейд или даунгрейд деки не делает твои старые следы более или менее видимыми!)
	action НЕ БОЛЕЕ 50 СИМВОЛОВ, ИНАЧЕ РАСШИРИТЬ его и _string
    */

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 запись в логи не выполнена!

	0 	- NO_ERROR				(нет ошибок, успешное выполнение)
	1 	- NOT_FOUND 			(нетраннера с таким id не найдено в базе)
	255 - OTHER					(другая ошибка)
	*/

	-- Объявления +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	DECLARE _string VARCHAR(70);						-- Строка для запись в логи
	DECLARE _netrunnerLvl TINYINT UNSIGNED DEFAULT 0;	-- Уровень нетраннера на момент совершения действия
	DECLARE _notFound BOOL DEFAULT FALSE;				-- Флаг "нетраннер не найден"

	-- Если SELECT ... INTO не нашел строку (нетраннер не найден в БД)
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	    SET _notFound = TRUE;
	END;

	-- Любая SQL-ошибка = откат транзакции и вернуть ошибку тому кто вызвал процедуру
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;										-- Откатить все изменения если они были сделаны
        RESIGNAL;										-- Отправить код ошибки SQL вызывающему процедуру
    END;

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SET errCode = 0;

	START TRANSACTION;			-- Блокируется изменения пользователя между получением уровня нетраннера по ID и записью его в логи

	-- Получить уровень нетраннера по netrunnerId и заблокировать изменения пользователя пока не записаны логи
	SET _notFound = false;		-- Инициализация флага "не найден"
	SELECT netrunner_lvl
	INTO _netrunnerLvl
	FROM main
	WHERE id = netrunnerId
	FOR UPDATE;

	-- Убедится что нетраннер существует (HANDLER for not found срабатывал)
    IF _notFound THEN
    	-- При попытке чтения уровня нетраннера записи с таким id не найдено в базе
        SET errCode = 1;		-- NOT_FOUND
    END IF;

	-- Добавить запись в логи
	IF errCode = 0 THEN
		-- Не было ошибок при выполнении кода выше

		-- Сформировать строку для записи
		IF isSuccess THEN
			SET _string = "NETRUN_SUCCESS ";
		ELSE
			SET _string = "NETRUN_FAIL ";
		END IF;
		SET _string = CONCAT(_string, action);

		-- Добавить запись
		INSERT INTO logs
		(object_id, subject_id, log_action, value)
		VALUES
		(objectId, netrunnerId, _string, _netrunnerLvl);

	END IF;

	-- Откат или завершение процедуры
	IF errCode = 0 THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END if;

END
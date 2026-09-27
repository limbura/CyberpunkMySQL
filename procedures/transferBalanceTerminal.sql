DROP PROCEDURE IF EXISTS transferBalanceTerminal;
-- CREATE DEFINER=`testuser`@`%` PROCEDURE `transferBalanceTerminal`(
CREATE PROCEDURE `transferBalanceTerminal`(
    IN 	senderCardId 	bigint unsigned,		-- cardId отправителя
    IN 	receiverCardId 	bigint unsigned,		-- cardId получателя
    IN 	amount 			int unsigned,			-- Количество (положительное!)
    IN 	sourceLosa 		bool					-- Если TRUE переводится losa, иначе money
)
begin

    /*
    Процедура перевода баланса через терминалы по card_id
	Получает id по card_id и вызывает transferBalanceCommon
	isNetrun всегда false
	Возвращает _errCode не как out а select as code
    */

	/* ERR CODE:
	При любом ERR CODE кроме 0 перевод не был произведен!
	0 	- NO_ERROR				(нет ошибок, успешное выполнение)
	1 	- SENDER_NOT_FOUND 		(пользователь не найден в БД, для перевода - отправитель не найден в БД)
	2 	- RECEIVER_NOT_FOUND 	(получатель не найден в БД)
	3 	- ZERO_DENY 			(недостаточно средств при переводе)
	4	- RECEIVER_OVERFLOW		(перевод приведет к переполнению INT получателя)
	255 - OTHER					(другая ошибка)
	*/
	
	-- Объявления +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	declare _senderId int unsigned;							-- Баланс отправителя
	declare _receiverId int unsigned;						-- Баланс получателя
	declare _notFound bool default false;					-- Флаг "отправитель/получатель не найден"
	declare _errCode int default 0;							-- Код ошибки, возвращаемый этой процедурой
	
    -- Если SELECT ... INTO не нашел строку (получатель / отправитель не найден в БД)
	declare continue HANDLER for not found
	begin
	    SET _notFound = TRUE;
	end;

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Найти id отправителя по его card_id  ------------------------------------------------------------------------------------------------------
    set _notFound = false;		-- Инициализация флага "не найден"
	select id
	into _senderId
	from main
	where card_id = senderCardId;
    
    -- Убедится что отправитель существует (HANDLER for not found срабатывал)  ------------------------------------------------------------------
    if _notFound then
    	-- При попытке чтения баланса отправителя записи с таким card_id не найдено в базе
        set _errCode = 1;     	-- SENDER_NOT_FOUND
    end if;
    
    -- Найти id получателя по его card_id  ------------------------------------------------------------------------------------------------------
	set _notFound = false;		-- Инициализация флага "не найден"
    if _errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
		select id
		into _receiverId
		from main
		where card_id = receiverCardId;
    end if;
    
    -- Убедится что получатель существует  ------------------------------------------------------------------------------------------------------
    if _errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
	    if _notFound then
	    	-- При попытке чтения id получателя записи с таким card_id не найдено в базе
	        set _errCode = 2; 	-- RECEIVER_NOT_FOUND
	    end if;
    end if;

    -- Вызвать transferBalanceCommon -------------------------------------------------------------------------------------------------------------
    if _errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
	    call transferBalanceCommon(_senderId, _receiverId, amount, sourceLosa, false, _errCode);
    end if;

	-- Вернуть код ошибки
	select _errCode as code;

end
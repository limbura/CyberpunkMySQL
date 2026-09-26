DROP PROCEDURE transferBalanceCommon;
CREATE DEFINER=`testuser`@`%` PROCEDURE `transferBalanceCommon`(
    in  senderId		int unsigned,			-- id отправителя
    in  receiverId		int unsigned,			-- id получателя
    in  amount			int unsigned,			-- Количество (положительное!)
    in  sourceLosa		bool,					-- Если TRUE переводится losa, иначе money
    in  isNetrun		bool,					-- TRUE если перевод через модель нетрана (в логи будет записано NETRUN_SEND / NETRUN_RECEIVE)
    out errCode			int						-- Код ошибки, 0 успешно, таблица ниже
)
begin

    /*
    Общая процедура перевода баланса по id
    */

	/* 
	ERR CODE:
	При любом ERR CODE кроме 0 перевод не был произведен!
	
	0 	- NO_ERROR				(нет ошибок, успешное выполнение)
	1 	- SENDER_NOT_FOUND 		(пользователь не найден в БД, для перевода - отправитель не найден в БД)
	2 	- RECEIVER_NOT_FOUND 	(получатель не найден в БД)
	3 	- ZERO_DENY 			(недостаточно средств при переводе)
	4	- RECEIVER_OVERFLOW		(перевод приведет к переполнению INT получателя)
	255 - OTHER					(другая ошибка)
	*/
	
	-- Объявления +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	declare _senderBalance int;				-- Баланс отправителя
	declare _receiverBalance int;			-- Баланс получателя
	declare _notFound bool default false;	-- Флаг "отправитель/получатель не найден"
	declare _logActionSend varchar(50);		-- Строка для записи в логи об отправке
	declare _logActionReceive varchar(50);	-- Строка для записи в логи о получении
	
    -- Любая SQL-ошибка = откат транзакции и вернуть ошибку тому кто вызвал процедуру
    declare exit HANDLER for sqlexception
    begin
        rollback;							-- Откатить все изменения если они были сделаны
        resignal;							-- Отправить код ошибки SQL вызывающему процедуру
    end;
    
    -- Если SELECT ... INTO не нашел строку (получатель / отправитель не найден в БД)
	declare continue HANDLER for not found
	begin
	    SET _notFound = TRUE;
	end;

	-- Код +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	set errCode = 0;

    start transaction;

    -- Запрет перевода самому себе ?
    
    -- Запрет перевода amount=0 ?

    -- Прочитать баланс отправителя в _senderBalance и заблокировать строку для изменений  -------------------------------------------------------
    set _notFound = false;		-- Инициализация флага "не найден"
    if sourceLosa then
    	-- Читать losa
	    select losa
		into _senderBalance
		from main
		where id = senderId
		for update;
    else
    	-- Читать money
    	select money
		into _senderBalance
		from main
		where id = senderId
		for update;
    end if;
    
    -- Убедится что отправитель существует (HANDLER for not found срабатывал)  ------------------------------------------------------------------
    if _notFound then
    	-- При попытке чтения баланса отправителя записи с таким id не найдено в базе
        set errCode = 1;     	-- SENDER_NOT_FOUND
    end if;
    
    -- Прочитать баланс получателя в _receiverBalance и заблокировать строку для изменений -------------------------------------------------------
	set _notFound = false;		-- Инициализация флага "не найден"
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
		if sourceLosa then
			-- Читать losa
			select losa
			into _receiverBalance
			from main
			where id = receiverId
			for update;
		else
			-- Читать money
			select money
			into _receiverBalance
			from main
			where id = receiverId
			for update;
		end if;
    end if;
    
    -- Убедится что получатель существует  ------------------------------------------------------------------------------------------------------
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
	    if _notFound then
	    	-- При попытке чтения баланса получателя записи с таким id не найдено в базе
	        set errCode = 2; 	-- RECEIVER_NOT_FOUND
	    end if;
    end if;

    -- Проверка что баланс отправителя не станет ниже нуля  -------------------------------------------------------------------------------------
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
        if _senderBalance < CAST(amount AS SIGNED) then
        	-- Недостаточно средств
            set errCode = 3; 	-- ZERO_DENY
        end if;
    end if;

	-- Проверка что баланс получателя не переполнится  ------------------------------------------------------------------------------------------
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
        if _receiverBalance > 2147483647 - CAST(amount AS SIGNED) then
        	-- Переполнение баланса
            set errCode = 4; 	-- RECEIVER_OVERFLOW
        end if;
    end if;
	
   	-- Перевод баланса --------------------------------------------------------------------------------------------------------------------------
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше
    	if sourceLosa then
    		-- Перевод losa
			-- Списание у отправителя
	        update main
	        set losa = losa - CAST(amount AS SIGNED)
	        where id = senderId;
			-- Начисление получателю
	        update main
	        set losa = losa + CAST(amount AS SIGNED)
	        where id = receiverId;
    	else
    		-- Перевод money
    		-- Списание у отправителя
	        update main
	        set money = money - CAST(amount AS SIGNED)
	        where id = senderId;
			-- Начисление получателю
	        update main
	        set money = money + CAST(amount AS SIGNED)
	        where id = receiverId;
    	end if;
    end if;
    
   	-- Добавить записи в логи --------------------------------------------------------------------------------------------------
    if errCode = 0 then
    	-- Не было ошибок при выполнении кода выше

		-- Формирование строк для записи
		if sourceLosa then
			if isNetrun then
				set _logActionSend = "NETRUN_SEND LOSA";
				set _logActionReceive = "NETRUN_RECEIVE LOSA";
			else
				set _logActionSend = "SEND LOSA";
				set _logActionReceive = "RECEIVE LOSA";
			end if;
		else
			if isNetrun then
				set _logActionSend = "NETRUN_SEND MONEY";
				set _logActionReceive = "NETRUN_RECEIVE MONEY";
			else
				set _logActionSend = "SEND MONEY";
				set _logActionReceive = "RECEIVE MONEY";
			end if;
		end if;

		-- Запись отправки
    	insert into logs
		(object_id, subject_id, log_action, value)
		values
		(senderId, receiverId, _logActionSend, amount);
		-- Запись получения
    	insert into logs
		(object_id, subject_id, log_action, value)
		values
		(receiverId, senderId, _logActionReceive, amount);

    end if;
    
    -- Финальное решение о применении изменений или откате в случае ошибок -----------------------------------------------------
  	if errCode = 0 then
		-- Применить изменения
		commit;
	else
    	-- Исключительная ситуация - откатить изменения
		rollback;
	end if;

end
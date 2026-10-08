-- Active: 1787916304607@@188.134.70.190@3306@cyberwall
-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: 188.134.70.190    Database: cyberwall
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `id_registry`
--

DROP TABLE IF EXISTS `id_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_registry` (
  `id` int unsigned NOT NULL,
  `card_id` bigint unsigned NOT NULL,
  `registered_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_registry`
--

LOCK TABLES `id_registry` WRITE;
/*!40000 ALTER TABLE `id_registry` DISABLE KEYS */;
INSERT INTO `id_registry` VALUES (1,5,'2026-09-26 14:11:00.292027'),(123,4,'2026-09-26 14:11:00.292027'),(321,6,'2026-09-26 14:11:00.292027'),(123456781,3,'2026-09-26 14:11:00.292027'),(123456782,2,'2026-09-26 14:11:00.292027'),(123456789,123,'2026-09-26 14:11:00.292027'),(812370639,8,'2026-09-26 16:34:22.000452');
/*!40000 ALTER TABLE `id_registry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `log_id` int unsigned NOT NULL AUTO_INCREMENT,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `object_id` int unsigned DEFAULT NULL,
  `subject_id` int unsigned DEFAULT NULL,
  `log_action` varchar(255) NOT NULL,
  `value` bigint DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1039 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
INSERT INTO `logs` VALUES (880,'2026-08-22 21:12:06',123456781,123456782,'SEND MONEY',111),(881,'2026-08-22 21:12:06',123456782,123456781,'RECEIVE MONEY',111),(882,'2026-08-22 21:25:26',123456782,123456781,'SEND MONEY',888),(883,'2026-08-22 21:25:26',123456781,123456782,'RECEIVE MONEY',888),(884,'2026-08-22 21:53:07',123456781,123456782,'SEND MONEY',100),(885,'2026-08-22 21:53:07',123456782,123456781,'RECEIVE MONEY',100),(886,'2026-08-22 21:56:57',123456782,123456781,'SEND MONEY',100),(887,'2026-08-22 21:56:57',123456781,123456782,'RECEIVE MONEY',100),(888,'2026-08-22 21:57:19',123456781,123456782,'SEND MONEY',10),(889,'2026-08-22 21:57:19',123456782,123456781,'RECEIVE MONEY',10),(890,'2026-08-22 21:57:40',123456781,123456782,'SEND MONEY',100),(891,'2026-08-22 21:57:40',123456782,123456781,'RECEIVE MONEY',100),(892,'2026-08-22 22:03:08',123456782,123456781,'SEND MONEY',500),(893,'2026-08-22 22:03:08',123456781,123456782,'RECEIVE MONEY',500),(894,'2026-08-22 22:04:28',123456782,123456781,'SEND MONEY',555),(895,'2026-08-22 22:04:28',123456781,123456782,'RECEIVE MONEY',555),(896,'2026-08-23 10:33:53',123456782,123456782,'SEND MONEY',900),(897,'2026-08-23 10:33:53',123456782,123456782,'RECEIVE MONEY',900),(898,'2026-08-23 12:05:32',123456782,123456781,'SEND MONEY',85),(899,'2026-08-23 12:05:32',123456781,123456782,'RECEIVE MONEY',85),(900,'2026-08-23 13:53:44',123456782,123456781,'SEND MONEY',666),(901,'2026-08-23 13:53:44',123456781,123456782,'RECEIVE MONEY',666),(902,'2026-08-23 14:44:30',123456781,123456782,'SEND MONEY',42),(903,'2026-08-23 14:44:30',123456782,123456781,'RECEIVE MONEY',42),(904,'2026-08-23 19:42:41',123456782,123456781,'SEND MONEY',456),(905,'2026-08-23 19:42:41',123456781,123456782,'RECEIVE MONEY',456),(906,'2026-08-23 23:55:39',123456781,123456782,'SEND MONEY',147),(907,'2026-08-23 23:55:39',123456782,123456781,'RECEIVE MONEY',147),(908,'2026-08-24 08:27:39',123456782,123456781,'SEND MONEY',119),(909,'2026-08-24 08:27:39',123456781,123456782,'RECEIVE MONEY',119),(910,'2026-08-24 23:12:02',123456781,123456782,'SEND MONEY',896),(911,'2026-08-24 23:12:02',123456782,123456781,'RECEIVE MONEY',896),(912,'2026-08-24 23:12:23',123456782,123456781,'SEND MONEY',56),(913,'2026-08-24 23:12:23',123456781,123456782,'RECEIVE MONEY',56),(914,'2026-08-25 01:27:11',123456782,123456781,'SEND MONEY',853),(915,'2026-08-25 01:27:11',123456781,123456782,'RECEIVE MONEY',853),(916,'2026-08-25 01:29:23',123456782,123456781,'SEND MONEY',12),(917,'2026-08-25 01:29:23',123456781,123456782,'RECEIVE MONEY',12),(918,'2026-08-25 01:50:40',123456782,123456781,'SEND MONEY',89),(919,'2026-08-25 01:50:40',123456781,123456782,'RECEIVE MONEY',89),(920,'2026-08-25 01:50:51',123456782,123456781,'SEND MONEY',87),(921,'2026-08-25 01:50:51',123456781,123456782,'RECEIVE MONEY',87),(922,'2026-08-25 01:51:02',123456781,123456782,'SEND MONEY',5558),(923,'2026-08-25 01:51:02',123456782,123456781,'RECEIVE MONEY',5558),(924,'2026-08-25 09:54:43',123456782,123456781,'SEND MONEY',74),(925,'2026-08-25 09:54:43',123456781,123456782,'RECEIVE MONEY',74),(926,'2026-08-25 09:58:41',123456782,123456781,'SEND MONEY',1),(927,'2026-08-25 09:58:41',123456781,123456782,'RECEIVE MONEY',1),(928,'2026-08-25 13:40:59',123456782,123456781,'SEND MONEY',951),(929,'2026-08-25 13:40:59',123456781,123456782,'RECEIVE MONEY',951),(930,'2026-08-25 14:48:57',123456781,123456782,'SEND MONEY',89),(931,'2026-08-25 14:48:57',123456782,123456781,'RECEIVE MONEY',89),(932,'2026-08-25 14:49:10',123456782,123456781,'SEND MONEY',57),(933,'2026-08-25 14:49:10',123456781,123456782,'RECEIVE MONEY',57),(934,'2026-08-25 15:27:20',123456782,123456781,'SEND MONEY',52),(935,'2026-08-25 15:27:20',123456781,123456782,'RECEIVE MONEY',52),(936,'2026-08-25 15:27:36',123456781,123456782,'SEND MONEY',53),(937,'2026-08-25 15:27:36',123456782,123456781,'RECEIVE MONEY',53),(938,'2026-08-26 00:52:38',123456781,123456782,'SEND MONEY',14),(939,'2026-08-26 00:52:38',123456782,123456781,'RECEIVE MONEY',14),(940,'2026-08-26 09:13:47',123456782,123456781,'SEND MONEY',18),(941,'2026-08-26 09:13:47',123456781,123456782,'RECEIVE MONEY',18),(942,'2026-08-26 15:03:01',123456782,123456781,'SEND MONEY',47),(943,'2026-08-26 15:03:01',123456781,123456782,'RECEIVE MONEY',47),(944,'2026-08-26 16:06:15',123456782,123456781,'SEND MONEY',1),(945,'2026-08-26 16:06:15',123456781,123456782,'RECEIVE MONEY',1),(946,'2026-08-27 10:36:44',123456781,100000001,'SEND MONEY',555),(947,'2026-08-27 10:36:44',100000001,123456781,'RECEIVE MONEY',555),(948,'2026-08-27 18:37:32',123456781,100000001,'SEND MONEY',999000),(949,'2026-08-27 18:37:32',100000001,123456781,'RECEIVE MONEY',999000),(950,'2026-08-28 06:56:57',100000001,100000001,'SEND MONEY',50),(951,'2026-08-28 06:56:57',100000001,100000001,'RECEIVE MONEY',50),(952,'2026-08-29 00:17:28',100000001,123456783,'SEND MONEY',999000),(953,'2026-08-29 00:17:28',123456783,100000001,'RECEIVE MONEY',999000),(954,'2026-08-29 00:23:00',123,321,'NETRUN_SEND MONEY',999000),(955,'2026-08-29 00:23:00',321,123,'NETRUN_RECEIVE MONEY',999000),(956,'2026-08-29 01:14:57',321,123456782,'SEND MONEY',700000),(957,'2026-08-29 01:14:57',123456782,321,'RECEIVE MONEY',700000),(958,'2026-08-29 02:57:08',123456781,321,'SEND MONEY',100000),(959,'2026-08-29 02:57:08',321,123456781,'RECEIVE MONEY',100000),(960,'2026-08-29 02:58:52',666,321,'NETRUN_SUCCESS HACK PENTAGON',5),(961,'2026-08-29 03:00:47',8888,321,'NETRUN_SUCCESS HACK PENTAGON',5),(962,'2026-08-29 03:02:07',8888,1,'NETRUN_FAIL HACK PENTAGON',0),(963,'2026-08-31 02:07:55',123456781,123456782,'SEND LOSA',5),(964,'2026-08-31 02:07:55',123456782,123456781,'RECEIVE LOSA',5),(965,'2026-08-31 02:18:12',321,123456782,'SEND MONEY',500),(966,'2026-08-31 02:18:12',123456782,321,'RECEIVE MONEY',500),(967,'2026-08-31 02:21:01',321,123456781,'SEND MONEY',399000),(968,'2026-08-31 02:21:01',123456781,321,'RECEIVE MONEY',399000),(969,'2026-08-31 02:24:14',321,123456781,'SEND MONEY',0),(970,'2026-08-31 02:24:14',123456781,321,'RECEIVE MONEY',0),(971,'2026-08-31 02:24:26',321,123456781,'SEND MONEY',0),(972,'2026-08-31 02:24:26',123456781,321,'RECEIVE MONEY',0),(973,'2026-08-31 02:27:21',123456781,321,'SEND MONEY',500000),(974,'2026-08-31 02:27:21',321,123456781,'RECEIVE MONEY',500000),(975,'2026-08-31 02:27:39',123456781,321,'SEND MONEY',800000),(976,'2026-08-31 02:27:39',321,123456781,'RECEIVE MONEY',800000),(977,'2026-08-31 02:27:57',123456781,123456782,'SEND MONEY',400),(978,'2026-08-31 02:27:57',123456782,123456781,'RECEIVE MONEY',400),(979,'2026-08-31 18:37:02',123456781,123456782,'SEND MONEY',700),(980,'2026-08-31 18:37:02',123456782,123456781,'RECEIVE MONEY',700),(981,'2026-08-31 20:27:45',321,123456782,'SEND MONEY',500),(982,'2026-08-31 20:27:45',123456782,321,'RECEIVE MONEY',500),(983,'2026-09-01 10:59:14',321,123456782,'SEND MONEY',100),(984,'2026-09-01 10:59:14',123456782,321,'RECEIVE MONEY',100),(985,'2026-09-01 10:59:52',123456781,123456782,'SEND MONEY',100),(986,'2026-09-01 10:59:52',123456782,123456781,'RECEIVE MONEY',100),(987,'2026-09-01 16:42:31',123456781,123456782,'SEND MONEY',200),(988,'2026-09-01 16:42:31',123456782,123456781,'RECEIVE MONEY',200),(989,'2026-09-01 16:44:08',123456781,123456782,'SEND MONEY',800),(990,'2026-09-01 16:44:08',123456782,123456781,'RECEIVE MONEY',800),(991,'2026-09-01 16:45:18',123456781,123456782,'SEND MONEY',1000000),(992,'2026-09-01 16:45:18',123456782,123456781,'RECEIVE MONEY',1000000),(993,'2026-09-01 16:45:50',123456781,123456782,'SEND MONEY',1000000000),(994,'2026-09-01 16:45:50',123456782,123456781,'RECEIVE MONEY',1000000000),(995,'2026-09-01 16:46:26',123456781,123456782,'SEND MONEY',1000000000),(996,'2026-09-01 16:46:26',123456782,123456781,'RECEIVE MONEY',1000000000),(997,'2026-09-01 17:48:07',321,123456782,'SEND MONEY',78900),(998,'2026-09-01 17:48:07',123456782,321,'RECEIVE MONEY',78900),(999,'2026-09-01 21:04:06',123456781,123456782,'SEND MONEY',100),(1000,'2026-09-01 21:04:06',123456782,123456781,'RECEIVE MONEY',100),(1001,'2026-09-12 13:19:43',321,123456782,'SEND MONEY',777777800),(1002,'2026-09-12 13:19:43',123456782,321,'RECEIVE MONEY',777777800),(1003,'2026-09-12 15:09:08',123456782,321,'SEND MONEY',100),(1004,'2026-09-12 15:09:08',321,123456782,'RECEIVE MONEY',100),(1005,'2026-09-12 15:13:24',321,123456782,'SEND MONEY',100),(1006,'2026-09-12 15:13:24',123456782,321,'RECEIVE MONEY',100),(1007,'2026-09-12 15:21:51',321,123456782,'SEND MONEY',100),(1008,'2026-09-12 15:21:51',123456782,321,'RECEIVE MONEY',100),(1009,'2026-09-12 15:37:33',321,123456782,'SEND MONEY',888888900),(1010,'2026-09-12 15:37:33',123456782,321,'RECEIVE MONEY',888888900),(1011,'2026-09-12 15:40:22',123456782,321,'SEND MONEY',900),(1012,'2026-09-12 15:40:22',321,123456782,'RECEIVE MONEY',900),(1013,'2026-09-12 15:41:27',321,123456782,'SEND MONEY',100),(1014,'2026-09-12 15:41:27',123456782,321,'RECEIVE MONEY',100),(1015,'2026-09-12 15:43:14',123456782,321,'SEND MONEY',900),(1016,'2026-09-12 15:43:14',321,123456782,'RECEIVE MONEY',900),(1017,'2026-09-12 15:46:18',321,123456782,'SEND MONEY',600),(1018,'2026-09-12 15:46:18',123456782,321,'RECEIVE MONEY',600),(1019,'2026-09-12 15:55:55',321,123456782,'SEND MONEY',55600),(1020,'2026-09-12 15:55:55',123456782,321,'RECEIVE MONEY',55600),(1021,'2026-09-12 15:57:40',123456782,321,'SEND MONEY',1000),(1022,'2026-09-12 15:57:40',321,123456782,'RECEIVE MONEY',1000),(1023,'2026-09-12 16:04:22',123456782,321,'SEND MONEY',888888900),(1024,'2026-09-12 16:04:22',321,123456782,'RECEIVE MONEY',888888900),(1025,'2026-09-12 17:13:18',123456782,321,'SEND MONEY',900),(1026,'2026-09-12 17:13:18',321,123456782,'RECEIVE MONEY',900),(1027,'2026-09-13 14:35:53',123,123456781,'SEND MONEY',100),(1028,'2026-09-13 14:35:53',123456781,123,'RECEIVE MONEY',100),(1029,'2026-09-13 14:39:04',123456782,123,'SEND LOSA',1),(1030,'2026-09-13 14:39:04',123,123456782,'RECEIVE LOSA',1),(1031,'2026-09-13 17:21:13',123456782,123,'SEND MONEY',12500),(1032,'2026-09-13 17:21:13',123,123456782,'RECEIVE MONEY',12500),(1033,'2026-09-13 17:21:34',123456782,123,'SEND MONEY',1300),(1034,'2026-09-13 17:21:34',123,123456782,'RECEIVE MONEY',1300),(1035,'2026-09-13 17:22:58',321,123456782,'SEND MONEY',3600),(1036,'2026-09-13 17:22:58',123456782,321,'RECEIVE MONEY',3600),(1037,'2026-09-13 17:23:17',321,321,'SEND MONEY',12300),(1038,'2026-09-13 17:23:17',321,321,'RECEIVE MONEY',12300);
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `main`
--

DROP TABLE IF EXISTS `main`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `main` (
  `card_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id` int unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `netrunner_lvl` tinyint unsigned NOT NULL DEFAULT '0',
  `password` varchar(255) DEFAULT NULL,
  `losa` int NOT NULL DEFAULT '0',
  `money` int NOT NULL DEFAULT '0',
  `police` tinyint(1) DEFAULT NULL,
  `occupancy` varchar(255) NOT NULL,
  PRIMARY KEY (`card_id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `main`
--

LOCK TABLES `main` WRITE;
/*!40000 ALTER TABLE `main` DISABLE KEYS */;
INSERT INTO `main` VALUES (2,123456782,'Шляпа',1,'01012000',358,632118953,1,'Vostok'),(3,123456781,'Ересь',2,'01021990',7,100,NULL,'Zapad'),(4,123,'Марьяна',0,'20071996',1,33700,NULL,'Zapad'),(5,1,'Кристиан Шварц Фон Хряк',0,NULL,0,2147483647,NULL,'Zapad'),(6,321,'Корпорация \"Верк\"',5,NULL,205,1369649547,NULL,'Werg'),(7,123456789,'Райнис',3,'16081994',0,10000,NULL,'Bar'),(8,812370639,'Тест Создания id',0,NULL,0,0,NULL,'test');
/*!40000 ALTER TABLE `main` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'cyberwall'
--
/*!50003 DROP PROCEDURE IF EXISTS `changeId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`testuser`@`%` PROCEDURE `changeId`(

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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generateId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`testuser`@`%` PROCEDURE `generateId`(

    IN cardId BIGINT UNSIGNED,  -- card_id для указания в реестре использованных id

    OUT newId INT UNSIGNED      -- Уникальный id который не использовался раньше, для назначения пользователю

)
procedure_block: BEGIN



	-- Внутренняя процедура создания нового id

	-- КЛИЕНТЫ НЕ ДОЛЖНЫ ВЫЗЫВАТЬ ЭТУ ПРОЦЕДУРУ!

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `logNetrunAction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`testuser`@`%` PROCEDURE `logNetrunAction`(

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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `transferBalanceCommon` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
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



end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `transferBalanceTerminal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`testuser`@`%` PROCEDURE `transferBalanceTerminal`(

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



end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07 12:04:13

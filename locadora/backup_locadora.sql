-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: locadora
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
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(40) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `valor_diaria` decimal(10,2) NOT NULL,
  `franquia_km` int NOT NULL DEFAULT '200',
  `valor_km_excedente` decimal(10,2) NOT NULL DEFAULT '1.50',
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uk_categoria_nome` (`nome`),
  CONSTRAINT `chk_categoria_franquia_km` CHECK ((`franquia_km` >= 0)),
  CONSTRAINT `chk_categoria_valor_diaria` CHECK ((`valor_diaria` > 0)),
  CONSTRAINT `chk_categoria_valor_km_excedente` CHECK ((`valor_km_excedente` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'ECONOMICO','Hatch compacto, ar-condicionado e direcao eletrica',129.90,200,1.20),(2,'INTERMEDIARIO','Sedan compacto, porta-malas ampliado',189.90,200,1.40),(3,'SUV','Veiculo alto, cinco lugares, porta-malas grande',289.90,250,1.90),(4,'LUXO','Sedan premium, cambio automatico e acabamento em couro',549.90,150,3.50),(5,'UTILITARIO','Furgao de carga para transporte de volumes',219.90,300,1.60);
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `cpf` char(11) NOT NULL,
  `num_cnh` char(11) NOT NULL,
  `cat_cnh` char(2) NOT NULL,
  `validade_cnh` date NOT NULL,
  `data_nascimento` date NOT NULL,
  `telefone` varchar(15) NOT NULL,
  `email` varchar(120) DEFAULT NULL,
  `logradouro` varchar(150) NOT NULL,
  `cidade` varchar(60) NOT NULL,
  `uf` char(2) NOT NULL,
  `cep` char(8) NOT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(10) NOT NULL DEFAULT 'ATIVO',
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `uq_cliente_cpf` (`cpf`),
  UNIQUE KEY `uk_cliente_num_cnh` (`num_cnh`),
  UNIQUE KEY `uk_cliente_email` (`email`),
  KEY `idx_cliente_nome` (`nome`),
  CONSTRAINT `chk_cliente_cat_cnh` CHECK ((`cat_cnh` in (_latin1'A',_latin1'B',_latin1'AB',_latin1'C',_latin1'D',_latin1'E'))),
  CONSTRAINT `chk_cliente_status` CHECK ((`status` in (_latin1'ATIVO',_latin1'INATIVO',_latin1'BLOQUEADO')))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'Marcos Vinicius Andrade','07894561203','03214785690','B','2029-04-18','1988-03-22','61991819883','marcos.andrade@email.com','SHIN QI 5 Conjunto 3 Casa 12','Brasilia','DF','71503035','2025-11-04 10:12:00','ATIVO'),(2,'Patricia Nogueira Lima','15342768094','07845123607','AB','2028-11-02','1992-07-09','61984472260','patricia.lima@email.com','SQS 308 Bloco F Apartamento 204','Brasilia','DF','70355060','2026-01-19 14:40:00','ATIVO'),(3,'Rafael Bittencourt Souza','29876543012','01247896305','B','2030-02-27','1985-12-14','61996633104','rafael.souza@email.com','QNA 22 Casa 9','Taguatinga','DF','72110220','2026-02-27 09:05:00','ATIVO'),(4,'Camila Duarte Ferreira','38217459086','09632587410','B','2029-09-30','1995-05-30','61987710455','camila.ferreira@email.com','Rua 12 Norte Lote 4 Ap 801','Aguas Claras','DF','71905000','2026-03-11 16:22:00','ATIVO'),(5,'Thiago Moreira Alencar','46053917822','05478912360','AB','2031-06-15','1990-10-03','61993328017',NULL,'CLN 410 Bloco B Ap 112','Brasilia','DF','70866520','2026-05-08 11:48:00','ATIVO'),(6,'Juliana Rezende Castro','51728394607','02896547130','B','2028-08-21','1998-01-26','61995540982','juliana.castro@email.com','Rua das Figueiras Lote 22','Aguas Claras','DF','71936250','2026-06-30 08:30:00','ATIVO');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documento_veiculo`
--

DROP TABLE IF EXISTS `documento_veiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documento_veiculo` (
  `id_veiculo` int NOT NULL,
  `renavam` char(11) NOT NULL,
  `num_crlv` varchar(20) NOT NULL,
  `ano_licenciamento` smallint NOT NULL,
  `venc_licenciamento` date NOT NULL,
  `apolice_seguro` varchar(30) DEFAULT NULL,
  `seguradora` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id_veiculo`),
  UNIQUE KEY `uk_documento_veiculo_renavam` (`renavam`),
  CONSTRAINT `fk_documento_veiculo_veiculo` FOREIGN KEY (`id_veiculo`) REFERENCES `veiculo` (`id_veiculo`) ON DELETE CASCADE,
  CONSTRAINT `chk_documento_veiculo_ano_licenciamento` CHECK ((`ano_licenciamento` >= 1990))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documento_veiculo`
--

LOCK TABLES `documento_veiculo` WRITE;
/*!40000 ALTER TABLE `documento_veiculo` DISABLE KEYS */;
INSERT INTO `documento_veiculo` VALUES (1,'00987654321','CRLV2026007412',2026,'2026-12-31','AP-2026-55412','Porto Seguro'),(2,'01122334455','CRLV2026007413',2026,'2026-12-31','AP-2026-55413','Porto Seguro'),(3,'02233445566','CRLV2026007414',2026,'2026-11-30','AP-2026-55414','Allianz'),(4,'03344556677','CRLV2026007415',2026,'2026-12-31','AP-2026-55415','Allianz'),(5,'04455667788','CRLV2026007416',2026,'2026-10-31','AP-2026-55416','Bradesco Seguros'),(6,'05566778899','CRLV2026007417',2026,'2026-12-31','AP-2026-55417','Porto Seguro'),(7,'06677889900','CRLV2026007418',2026,'2026-09-30',NULL,NULL),(8,'07788990011','CRLV2026007419',2026,'2026-12-31','AP-2026-55419','Bradesco Seguros'),(9,'10000000009','CRLV2026007420',2026,'2026-12-31','AP-2026-55420','Porto Seguro'),(10,'10000000010','CRLV2026007421',2026,'2026-12-31','AP-2026-55421','Allianz'),(11,'10000000011','CRLV2026007422',2026,'2026-12-31',NULL,NULL),(12,'10000000012','CRLV2026007423',2026,'2026-12-31','AP-2026-55423','Porto Seguro'),(13,'10000000013','CRLV2026007424',2026,'2026-12-31','AP-2026-55424','Allianz'),(14,'10000000014','CRLV2026007425',2026,'2026-12-31','AP-2026-55425','Bradesco Seguros'),(15,'10000000015','CRLV2026007426',2026,'2026-12-31','AP-2026-55426','Porto Seguro'),(16,'10000000016','CRLV2026007427',2026,'2026-12-31','AP-2026-55427','Allianz'),(17,'10000000017','CRLV2026007428',2026,'2026-12-31','AP-2026-55428','Bradesco Seguros'),(18,'10000000018','CRLV2026007429',2026,'2026-12-31','AP-2026-55429','Porto Seguro'),(19,'10000000019','CRLV2026007430',2026,'2026-12-31','AP-2026-55430','Allianz'),(20,'10000000020','CRLV2026007431',2026,'2026-12-31','AP-2026-55431','Bradesco Seguros'),(21,'10000000021','CRLV2026007432',2026,'2026-12-31','AP-2026-55432','Porto Seguro'),(22,'10000000022','CRLV2026007433',2026,'2026-12-31','AP-2026-55433','Allianz'),(23,'10000000023','CRLV2026007434',2026,'2026-12-31','AP-2026-55434','Bradesco Seguros'),(24,'10000000024','CRLV2026007435',2026,'2026-12-31','AP-2026-55435','Porto Seguro'),(25,'10000000025','CRLV2026007436',2026,'2026-12-31',NULL,NULL),(26,'10000000026','CRLV2026007437',2026,'2026-12-31','AP-2026-55437','Bradesco Seguros'),(27,'10000000027','CRLV2026007438',2026,'2026-12-31','AP-2026-55438','Porto Seguro'),(28,'10000000028','CRLV2026007439',2026,'2026-12-31','AP-2026-55439','Allianz'),(29,'10000000029','CRLV2026007440',2026,'2026-12-31','AP-2026-55440','Bradesco Seguros'),(30,'10000000030','CRLV2026007441',2026,'2026-12-31','AP-2026-55441','Porto Seguro');
/*!40000 ALTER TABLE `documento_veiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filial`
--

DROP TABLE IF EXISTS `filial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `filial` (
  `id_filial` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `cnpj` char(14) NOT NULL,
  `logradouro` varchar(150) NOT NULL,
  `cidade` varchar(60) NOT NULL,
  `uf` char(2) NOT NULL,
  `cep` char(8) NOT NULL,
  `telefone` varchar(15) NOT NULL,
  PRIMARY KEY (`id_filial`),
  UNIQUE KEY `uk_filial_cnpj` (`cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filial`
--

LOCK TABLES `filial` WRITE;
/*!40000 ALTER TABLE `filial` DISABLE KEYS */;
INSERT INTO `filial` VALUES (1,'Filial Asa Sul','12345678000190','SGAS 607 Bloco A Loja 12','Brasilia','DF','70200670','6132245510'),(2,'Filial Asa Norte','12345678000271','CLN 408 Bloco C Loja 30','Brasilia','DF','70856530','6132248820'),(3,'Filial Taguatinga','12345678000352','QNA 14 Lote 8','Taguatinga','DF','72110140','6133518840'),(4,'Filial Aguas Claras','12345678000433','Rua Copaiba Lote 15 Loja 4','Aguas Claras','DF','71919180','6133619070'),(5,'Filial Aeroporto','12345678000514','Aeroporto Internacional Setor 2','Brasilia','DF','71608900','6134647120');
/*!40000 ALTER TABLE `filial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locacao`
--

DROP TABLE IF EXISTS `locacao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locacao` (
  `id_locacao` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `id_veiculo` int NOT NULL,
  `id_filial_retirada` int NOT NULL,
  `id_filial_devolucao` int NOT NULL,
  `data_retirada` datetime NOT NULL,
  `data_prevista_devolucao` datetime NOT NULL,
  `data_real_devolucao` datetime DEFAULT NULL,
  `valor_diaria_contratada` decimal(10,2) NOT NULL,
  `km_retirada` int NOT NULL,
  `km_devolucao` int DEFAULT NULL,
  `valor_total` decimal(10,2) DEFAULT NULL,
  `status` varchar(15) NOT NULL DEFAULT 'ABERTA',
  PRIMARY KEY (`id_locacao`),
  KEY `idx_locacao_aberta` (`data_real_devolucao`),
  KEY `idx_locacao_cliente` (`id_cliente`),
  KEY `idx_locacao_filial_ret` (`id_filial_retirada`),
  KEY `fk_locacao_veiculo` (`id_veiculo`),
  KEY `fk_locacao_filial_devolucao` (`id_filial_devolucao`),
  KEY `idx_locacao_data_retirada` (`data_retirada`),
  CONSTRAINT `fk_locacao_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT,
  CONSTRAINT `fk_locacao_filial_devolucao` FOREIGN KEY (`id_filial_devolucao`) REFERENCES `filial` (`id_filial`) ON DELETE RESTRICT,
  CONSTRAINT `fk_locacao_filial_retirada` FOREIGN KEY (`id_filial_retirada`) REFERENCES `filial` (`id_filial`) ON DELETE RESTRICT,
  CONSTRAINT `fk_locacao_veiculo` FOREIGN KEY (`id_veiculo`) REFERENCES `veiculo` (`id_veiculo`) ON DELETE RESTRICT,
  CONSTRAINT `chk_locacao_datas_previstas` CHECK ((`data_prevista_devolucao` > `data_retirada`)),
  CONSTRAINT `chk_locacao_km_devolucao` CHECK (((`km_devolucao` is null) or (`km_devolucao` >= `km_retirada`))),
  CONSTRAINT `chk_locacao_km_retirada` CHECK ((`km_retirada` >= 0)),
  CONSTRAINT `chk_locacao_status` CHECK ((`status` in (_utf8mb4'ABERTA',_utf8mb4'FINALIZADA',_utf8mb4'CANCELADA'))),
  CONSTRAINT `chk_locacao_valor_diaria` CHECK ((`valor_diaria_contratada` > 0)),
  CONSTRAINT `chk_locacao_valor_total` CHECK (((`valor_total` is null) or (`valor_total` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locacao`
--

LOCK TABLES `locacao` WRITE;
/*!40000 ALTER TABLE `locacao` DISABLE KEYS */;
INSERT INTO `locacao` VALUES (1,1,2,1,1,'2026-06-03 09:00:00','2026-06-08 09:00:00','2026-06-08 08:40:00',129.90,12000,12480,649.50,'FINALIZADA'),(2,2,1,1,3,'2026-06-20 10:00:00','2026-06-25 10:00:00','2026-06-27 14:20:00',289.90,18000,19250,2319.20,'FINALIZADA'),(3,3,5,3,3,'2026-07-02 08:00:00','2026-07-05 08:00:00','2026-07-05 07:30:00',189.90,9000,9410,569.70,'FINALIZADA'),(4,1,4,2,2,'2026-07-10 09:00:00','2026-07-17 09:00:00','2026-07-17 08:50:00',289.90,22000,23600,2029.30,'FINALIZADA'),(5,4,6,5,5,'2026-07-22 15:00:00','2026-07-25 15:00:00','2026-07-28 11:00:00',549.90,5000,5900,3299.40,'FINALIZADA'),(6,2,3,2,1,'2026-08-05 10:00:00','2026-08-10 10:00:00','2026-08-10 09:15:00',129.90,15000,15700,649.50,'FINALIZADA'),(7,1,7,4,4,'2026-08-12 08:00:00','2026-08-19 08:00:00','2026-08-19 07:40:00',219.90,31000,32200,1539.30,'FINALIZADA'),(8,5,8,4,4,'2026-08-20 14:00:00','2026-08-24 14:00:00','2026-08-24 13:20:00',129.90,27000,27500,519.60,'FINALIZADA'),(9,2,2,1,2,'2026-08-28 09:00:00','2026-09-02 09:00:00','2026-09-04 16:00:00',129.90,12480,13400,1039.20,'FINALIZADA'),(10,3,5,3,3,'2026-09-05 08:00:00','2026-09-09 08:00:00','2026-09-09 07:50:00',189.90,9410,9980,759.60,'FINALIZADA'),(11,1,1,1,3,'2026-09-12 09:00:00','2026-09-19 09:00:00',NULL,289.90,19250,NULL,NULL,'ABERTA'),(12,6,4,2,5,'2026-09-14 10:00:00','2026-09-21 10:00:00',NULL,289.90,23600,NULL,NULL,'ABERTA'),(13,1,10,1,1,'2026-09-10 09:00:00','2026-09-17 09:00:00',NULL,129.90,21400,NULL,NULL,'ABERTA'),(14,3,13,2,2,'2026-09-11 10:00:00','2026-09-18 10:00:00',NULL,189.90,19600,NULL,NULL,'ABERTA'),(15,4,17,1,4,'2026-09-13 08:30:00','2026-09-20 08:30:00',NULL,289.90,9400,NULL,NULL,'ABERTA'),(16,5,22,5,1,'2026-09-15 14:00:00','2026-09-18 14:00:00',NULL,549.90,15800,NULL,NULL,'ABERTA'),(17,6,27,4,4,'2026-09-15 07:00:00','2026-09-22 07:00:00',NULL,219.90,12600,NULL,NULL,'ABERTA');
/*!40000 ALTER TABLE `locacao` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_locacao_ai_status` AFTER INSERT ON `locacao` FOR EACH ROW BEGIN
    IF NEW.data_real_devolucao IS NULL AND NEW.status = 'ABERTA' THEN
        UPDATE veiculo
           SET status = 'LOCADO'
         WHERE id_veiculo = NEW.id_veiculo;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_locacao_au_status` AFTER UPDATE ON `locacao` FOR EACH ROW BEGIN
    IF OLD.data_real_devolucao IS NULL
       AND NEW.data_real_devolucao IS NOT NULL THEN
        UPDATE veiculo
           SET status   = 'DISPONIVEL',
               km_atual = COALESCE(NEW.km_devolucao, km_atual)
         WHERE id_veiculo = NEW.id_veiculo;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_locacao_au_auditoria` AFTER UPDATE ON `locacao` FOR EACH ROW BEGIN
    IF NOT (OLD.valor_total <=> NEW.valor_total)
       OR NOT (OLD.status   <=> NEW.status) THEN
        INSERT INTO log_locacao (id_locacao, valor_antigo, valor_novo,
                                 status_antigo, status_novo, usuario)
        VALUES (NEW.id_locacao, OLD.valor_total, NEW.valor_total,
                OLD.status, NEW.status, CURRENT_USER());
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log_locacao`
--

DROP TABLE IF EXISTS `log_locacao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_locacao` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `id_locacao` int NOT NULL,
  `valor_antigo` decimal(10,2) DEFAULT NULL,
  `valor_novo` decimal(10,2) DEFAULT NULL,
  `status_antigo` varchar(15) DEFAULT NULL,
  `status_novo` varchar(15) DEFAULT NULL,
  `usuario` varchar(100) NOT NULL,
  `data_alteracao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`),
  KEY `fk_log_locacao_locacao` (`id_locacao`),
  CONSTRAINT `fk_log_locacao_locacao` FOREIGN KEY (`id_locacao`) REFERENCES `locacao` (`id_locacao`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_locacao`
--

LOCK TABLES `log_locacao` WRITE;
/*!40000 ALTER TABLE `log_locacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `log_locacao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manutencao`
--

DROP TABLE IF EXISTS `manutencao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manutencao` (
  `id_manutencao` int NOT NULL AUTO_INCREMENT,
  `id_veiculo` int NOT NULL,
  `tipo` varchar(15) NOT NULL,
  `descricao` varchar(200) NOT NULL,
  `data_entrada` date NOT NULL,
  `data_saida` date DEFAULT NULL,
  `km_manutencao` int NOT NULL,
  `custo` decimal(10,2) NOT NULL,
  `fornecedor` varchar(100) NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  KEY `idx_manutencao_veiculo` (`id_veiculo`),
  CONSTRAINT `fk_manutencao_veiculo` FOREIGN KEY (`id_veiculo`) REFERENCES `veiculo` (`id_veiculo`) ON DELETE RESTRICT,
  CONSTRAINT `chk_manutencao_custo` CHECK ((`custo` >= 0)),
  CONSTRAINT `chk_manutencao_datas` CHECK (((`data_saida` is null) or (`data_saida` >= `data_entrada`))),
  CONSTRAINT `chk_manutencao_km` CHECK ((`km_manutencao` >= 0)),
  CONSTRAINT `chk_manutencao_tipo` CHECK ((`tipo` in (_latin1'PREVENTIVA',_latin1'CORRETIVA',_latin1'REVISAO')))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manutencao`
--

LOCK TABLES `manutencao` WRITE;
/*!40000 ALTER TABLE `manutencao` DISABLE KEYS */;
INSERT INTO `manutencao` VALUES (1,2,'PREVENTIVA','Troca de oleo, filtro de oleo e filtro de ar','2026-06-10','2026-06-11',12480,640.00,'Concessionaria Sul'),(2,2,'CORRETIVA','Substituicao das pastilhas de freio dianteiras','2026-09-05','2026-09-06',13400,890.00,'Auto Center Guara'),(3,1,'REVISAO','Revisao programada de 20 mil quilometros','2026-06-29','2026-07-01',19250,1480.00,'Concessionaria Toyota Norte'),(4,5,'PREVENTIVA','Alinhamento, balanceamento e rodizio de pneus','2026-07-08','2026-07-08',9410,320.00,'Pneus Taguatinga'),(5,5,'CORRETIVA','Reparo no compressor do ar-condicionado','2026-09-10','2026-09-12',9980,1250.00,'Auto Center Guara'),(6,6,'REVISAO','Revisao anual de garantia de fabrica','2026-07-30','2026-08-02',5900,2890.00,'Concessionaria BMW Sul'),(7,3,'CORRETIVA','Troca de bateria e do alternador','2026-09-15',NULL,15700,1720.00,'Auto Center Guara'),(8,16,'CORRETIVA','Troca do kit de embreagem','2026-09-14',NULL,33900,2150.00,'Auto Center Guara'),(9,24,'REVISAO','Revisao do sistema hibrido','2026-09-15',NULL,19700,1980.00,'Concessionaria Lexus Brasilia');
/*!40000 ALTER TABLE `manutencao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teste_restore`
--

DROP TABLE IF EXISTS `teste_restore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teste_restore` (
  `id` int NOT NULL,
  `texto` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teste_restore`
--

LOCK TABLES `teste_restore` WRITE;
/*!40000 ALTER TABLE `teste_restore` DISABLE KEYS */;
INSERT INTO `teste_restore` VALUES (1,'antes do backup');
/*!40000 ALTER TABLE `teste_restore` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha_hash` varchar(255) DEFAULT NULL,
  `perfil` enum('admin','atendente') NOT NULL DEFAULT 'atendente',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token_hash` char(64) DEFAULT NULL,
  `token_expira_em` datetime DEFAULT NULL,
  `deve_trocar_senha` tinyint(1) NOT NULL DEFAULT '0',
  `tentativas_falhas` tinyint unsigned NOT NULL DEFAULT '0',
  `bloqueado_ate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_usuarios_token` (`token_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador de teste','admin@locadora.test','$2y$10$D56btf0dvs1v4yVTdZMZj.A52JKmY18IM4BbPEIFEnsc4pFQWFpdS','admin','2026-11-04 13:08:07',NULL,NULL,1,0,NULL),(2,'Atendente de teste','atendente@locadora.test','$2y$10$7RqHFjUDcbPAhLVbPJFZEu8GBT0tmT04z9xhyuaySHtb/Ek4m24lW','atendente','2026-11-04 13:08:07',NULL,NULL,1,0,NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `veiculo`
--

DROP TABLE IF EXISTS `veiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `veiculo` (
  `id_veiculo` int NOT NULL AUTO_INCREMENT,
  `placa` char(7) NOT NULL,
  `chassi` char(17) NOT NULL,
  `marca` varchar(40) NOT NULL,
  `modelo` varchar(60) NOT NULL,
  `ano_fabricacao` smallint NOT NULL,
  `ano_modelo` smallint NOT NULL,
  `cor` varchar(30) NOT NULL,
  `combustivel` varchar(15) NOT NULL DEFAULT 'FLEX',
  `km_atual` int NOT NULL DEFAULT '0',
  `status` varchar(15) NOT NULL DEFAULT 'DISPONIVEL',
  `id_categoria` int NOT NULL,
  `id_filial` int NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_veiculo`),
  UNIQUE KEY `uq_veiculo_placa` (`placa`),
  UNIQUE KEY `uk_veiculo_chassi` (`chassi`),
  KEY `idx_veiculo_categoria` (`id_categoria`,`status`),
  KEY `fk_veiculo_filial` (`id_filial`),
  CONSTRAINT `fk_veiculo_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT,
  CONSTRAINT `fk_veiculo_filial` FOREIGN KEY (`id_filial`) REFERENCES `filial` (`id_filial`) ON DELETE RESTRICT,
  CONSTRAINT `chk_veiculo_ano_fabricacao` CHECK ((`ano_fabricacao` >= 1990)),
  CONSTRAINT `chk_veiculo_ano_modelo` CHECK ((`ano_modelo` >= `ano_fabricacao`)),
  CONSTRAINT `chk_veiculo_combustivel` CHECK ((`combustivel` in (_utf8mb4'FLEX',_utf8mb4'GASOLINA',_utf8mb4'DIESEL',_utf8mb4'ELETRICO',_utf8mb4'HIBRIDO'))),
  CONSTRAINT `chk_veiculo_km_atual` CHECK ((`km_atual` >= 0)),
  CONSTRAINT `chk_veiculo_status` CHECK ((`status` in (_utf8mb4'DISPONIVEL',_utf8mb4'LOCADO',_utf8mb4'MANUTENCAO',_utf8mb4'INATIVO')))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `veiculo`
--

LOCK TABLES `veiculo` WRITE;
/*!40000 ALTER TABLE `veiculo` DISABLE KEYS */;
INSERT INTO `veiculo` VALUES (1,'JKL5C21','9BWZZZ377VT004251','Toyota','Corolla Cross',2024,2025,'Prata','FLEX',19250,'LOCADO',3,1,NULL),(2,'RTB7D45','9BD19640TL2140233','Fiat','Argo',2023,2024,'Branco','FLEX',13400,'DISPONIVEL',1,1,NULL),(3,'MQP2E88','9BHBG51CAPP721904','Hyundai','HB20',2024,2024,'Preto','FLEX',15700,'MANUTENCAO',1,2,NULL),(4,'XCV9F03','98JMCA5H7PK118276','Jeep','Compass',2023,2024,'Cinza','DIESEL',23600,'LOCADO',3,2,NULL),(5,'BND4G12','9BGKS69X0RG205417','Chevrolet','Onix Plus',2024,2025,'Prata','FLEX',9980,'DISPONIVEL',2,3,NULL),(6,'LWS8H27','WBA5R71090FH88251','BMW','320i',2024,2025,'Preto','GASOLINA',5900,'DISPONIVEL',4,5,NULL),(7,'PDF3J56','9BD26512MN3067148','Fiat','Fiorino',2022,2023,'Branco','FLEX',32200,'DISPONIVEL',5,4,NULL),(8,'GHT6K91','93YRBB00274108392','Renault','Kwid',2023,2023,'Vermelho','FLEX',27500,'DISPONIVEL',1,4,NULL),(9,'QAB1C23','9BWAA05U0EP000109','Volkswagen','Polo Track',2024,2025,'Branco','FLEX',8200,'DISPONIVEL',1,3,NULL),(10,'QAC2D34','9BGEA48A0PG000110','Chevrolet','Onix',2023,2024,'Prata','FLEX',21400,'LOCADO',1,1,NULL),(11,'QAD3E45','9BFZH55L0R8000111','Ford','Ka',2021,2021,'Azul','FLEX',48700,'INATIVO',1,2,NULL),(12,'QAE4F56','9BWDB45U0PT000112','Volkswagen','Virtus',2024,2024,'Cinza','FLEX',11800,'DISPONIVEL',2,1,NULL),(13,'QAF5G67','9BD35812XRY000113','Fiat','Cronos',2023,2024,'Branco','FLEX',19600,'LOCADO',2,2,NULL),(14,'QAG6H78','93HGR3860RZ000114','Honda','City',2024,2025,'Preto','FLEX',7300,'DISPONIVEL',2,5,NULL),(15,'QAH7J89','9BHCN41BAR0000115','Hyundai','HB20S',2023,2023,'Prata','FLEX',25100,'DISPONIVEL',2,4,NULL),(16,'QAJ8K90','9BRBD48E0R4000116','Toyota','Yaris Sedan',2022,2023,'Vermelho','FLEX',33900,'MANUTENCAO',2,3,NULL),(17,'QAK9L01','9BWBH6BF0R4000117','Volkswagen','T-Cross',2024,2025,'Branco','FLEX',9400,'LOCADO',3,1,NULL),(18,'QAL0M12','9BHBG41DAR0000118','Hyundai','Creta',2023,2024,'Cinza','FLEX',22800,'DISPONIVEL',3,3,NULL),(19,'QAM1N23','93YHSR2F5RJ000119','Renault','Duster',2022,2022,'Marrom','FLEX',41200,'DISPONIVEL',3,4,NULL),(20,'QAN2P34','9BGEP76K0RB000120','Chevrolet','Tracker',2024,2024,'Azul','FLEX',14500,'DISPONIVEL',3,5,NULL),(21,'QAP3Q45','WDD2050421F000121','Mercedes-Benz','C 200',2024,2025,'Preto','GASOLINA',6100,'DISPONIVEL',4,1,NULL),(22,'QAQ4R56','WAUZZZF40RA000122','Audi','A4',2023,2024,'Branco','GASOLINA',15800,'LOCADO',4,5,NULL),(23,'QAR5S67','YV1ZWA8U0R1000123','Volvo','XC40 Recharge',2024,2024,'Cinza','ELETRICO',8900,'DISPONIVEL',4,2,NULL),(24,'QAS6T78','JTHBA1D20R5000124','Lexus','ES 300h',2023,2023,'Prata','HIBRIDO',19700,'MANUTENCAO',4,5,NULL),(25,'QAT7U89','WBA7U2100RG000125','BMW','X1',2022,2023,'Azul','GASOLINA',36400,'INATIVO',4,1,NULL),(26,'QAU8V90','93ZC3580R80000126','Iveco','Daily',2023,2023,'Branco','DIESEL',42300,'DISPONIVEL',5,3,NULL),(27,'QAV9W01','WF0XXXTTGXR000127','Ford','Transit',2024,2024,'Branco','DIESEL',12600,'LOCADO',5,4,NULL),(28,'QAW0X12','9BD2651JHR9000128','Fiat','Strada',2024,2025,'Vermelho','FLEX',10300,'DISPONIVEL',5,2,NULL),(29,'QAX1Y23','8AC906635RE000129','Mercedes-Benz','Sprinter',2022,2023,'Branco','DIESEL',58800,'DISPONIVEL',5,1,NULL),(30,'QAY2Z34','9BD5781DAR8000130','Fiat','Ducato',2023,2024,'Prata','DIESEL',27400,'DISPONIVEL',5,5,NULL);
/*!40000 ALTER TABLE `veiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_faturamento_mensal`
--

DROP TABLE IF EXISTS `vw_faturamento_mensal`;
/*!50001 DROP VIEW IF EXISTS `vw_faturamento_mensal`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_faturamento_mensal` AS SELECT 
 1 AS `filial_retirada`,
 1 AS `cidade`,
 1 AS `ano`,
 1 AS `mes`,
 1 AS `ano_mes`,
 1 AS `total_locacoes`,
 1 AS `faturamento_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_locacoes_ativas`
--

DROP TABLE IF EXISTS `vw_locacoes_ativas`;
/*!50001 DROP VIEW IF EXISTS `vw_locacoes_ativas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_locacoes_ativas` AS SELECT 
 1 AS `id_locacao`,
 1 AS `cliente`,
 1 AS `cpf_cliente`,
 1 AS `placa`,
 1 AS `veiculo`,
 1 AS `filial_retirada`,
 1 AS `filial_devolucao_prevista`,
 1 AS `data_retirada`,
 1 AS `data_prevista_devolucao`,
 1 AS `valor_diaria_contratada`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_veiculos_disponiveis`
--

DROP TABLE IF EXISTS `vw_veiculos_disponiveis`;
/*!50001 DROP VIEW IF EXISTS `vw_veiculos_disponiveis`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_veiculos_disponiveis` AS SELECT 
 1 AS `id_veiculo`,
 1 AS `placa`,
 1 AS `marca`,
 1 AS `modelo`,
 1 AS `cor`,
 1 AS `km_atual`,
 1 AS `categoria`,
 1 AS `valor_diaria`,
 1 AS `filial_atual`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'locadora'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_calcula_multa` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcula_multa`(
    p_id_locacao        INT,
    p_taxa_diaria_multa DECIMAL(10,2)
) RETURNS decimal(10,2)
    READS SQL DATA
BEGIN
    DECLARE v_prevista DATETIME;
    DECLARE v_real     DATETIME;
    DECLARE v_dias     INT;

    SELECT data_prevista_devolucao, data_real_devolucao
      INTO v_prevista, v_real
      FROM locacao
     WHERE id_locacao = p_id_locacao;

    IF v_real IS NULL OR v_prevista IS NULL THEN
        RETURN 0.00;
    END IF;

    SET v_dias = DATEDIFF(v_real, v_prevista);

    IF v_dias <= 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND(v_dias * COALESCE(p_taxa_diaria_multa, 0), 2);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_abrir_locacao` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_abrir_locacao`(
    IN  p_id_cliente     INT,
    IN  p_id_veiculo     INT,
    IN  p_id_filial      INT,
    IN  p_dias_locacao   INT,
    OUT p_id_locacao     INT,
    OUT p_valor_previsto DECIMAL(10,2)
)
BEGIN
    DECLARE v_status       VARCHAR(15);
    DECLARE v_km_atual     INT;
    DECLARE v_valor_diaria DECIMAL(10,2);

    IF p_dias_locacao IS NULL OR p_dias_locacao < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_abrir_locacao: dias de locacao deve ser 1 ou mais';
    END IF;

    SELECT v.status, v.km_atual, c.valor_diaria
      INTO v_status, v_km_atual, v_valor_diaria
      FROM veiculo v
      JOIN categoria c ON c.id_categoria = v.id_categoria
     WHERE v.id_veiculo = p_id_veiculo;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_abrir_locacao: veiculo inexistente';
    END IF;

    IF v_status <> 'DISPONIVEL' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_abrir_locacao: veiculo nao esta disponivel';
    END IF;

    SET p_valor_previsto = v_valor_diaria * p_dias_locacao;

    INSERT INTO locacao (id_cliente, id_veiculo, id_filial_retirada,
                         id_filial_devolucao, data_retirada,
                         data_prevista_devolucao, data_real_devolucao,
                         valor_diaria_contratada, km_retirada,
                         km_devolucao, valor_total, status)
    VALUES (p_id_cliente, p_id_veiculo, p_id_filial,
            p_id_filial, NOW(),
            NOW() + INTERVAL p_dias_locacao DAY, NULL,
            v_valor_diaria, v_km_atual,
            NULL, NULL, 'ABERTA');

    SET p_id_locacao = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_faturamento_mensal`
--

/*!50001 DROP VIEW IF EXISTS `vw_faturamento_mensal`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_faturamento_mensal` AS select `f`.`nome` AS `filial_retirada`,`f`.`cidade` AS `cidade`,year(`l`.`data_real_devolucao`) AS `ano`,month(`l`.`data_real_devolucao`) AS `mes`,date_format(`l`.`data_real_devolucao`,'%Y-%m') AS `ano_mes`,count(`l`.`id_locacao`) AS `total_locacoes`,sum(`l`.`valor_total`) AS `faturamento_total` from (`locacao` `l` join `filial` `f` on((`f`.`id_filial` = `l`.`id_filial_retirada`))) where ((`l`.`status` = 'FINALIZADA') and (`l`.`data_real_devolucao` is not null)) group by `f`.`id_filial`,`f`.`nome`,`f`.`cidade`,year(`l`.`data_real_devolucao`),month(`l`.`data_real_devolucao`),date_format(`l`.`data_real_devolucao`,'%Y-%m') order by `ano` desc,`mes` desc,`filial_retirada` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_locacoes_ativas`
--

/*!50001 DROP VIEW IF EXISTS `vw_locacoes_ativas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_locacoes_ativas` AS select `l`.`id_locacao` AS `id_locacao`,`c`.`nome` AS `cliente`,`c`.`cpf` AS `cpf_cliente`,`v`.`placa` AS `placa`,concat(`v`.`marca`,' ',`v`.`modelo`) AS `veiculo`,`fr`.`nome` AS `filial_retirada`,`fd`.`nome` AS `filial_devolucao_prevista`,`l`.`data_retirada` AS `data_retirada`,`l`.`data_prevista_devolucao` AS `data_prevista_devolucao`,`l`.`valor_diaria_contratada` AS `valor_diaria_contratada` from ((((`locacao` `l` join `cliente` `c` on((`c`.`id_cliente` = `l`.`id_cliente`))) join `veiculo` `v` on((`v`.`id_veiculo` = `l`.`id_veiculo`))) join `filial` `fr` on((`fr`.`id_filial` = `l`.`id_filial_retirada`))) join `filial` `fd` on((`fd`.`id_filial` = `l`.`id_filial_devolucao`))) where (`l`.`data_real_devolucao` is null) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_veiculos_disponiveis`
--

/*!50001 DROP VIEW IF EXISTS `vw_veiculos_disponiveis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_veiculos_disponiveis` AS select `v`.`id_veiculo` AS `id_veiculo`,`v`.`placa` AS `placa`,`v`.`marca` AS `marca`,`v`.`modelo` AS `modelo`,`v`.`cor` AS `cor`,`v`.`km_atual` AS `km_atual`,`cat`.`nome` AS `categoria`,`cat`.`valor_diaria` AS `valor_diaria`,`f`.`nome` AS `filial_atual` from ((`veiculo` `v` join `categoria` `cat` on((`cat`.`id_categoria` = `v`.`id_categoria`))) join `filial` `f` on((`f`.`id_filial` = `v`.`id_filial`))) where ((`v`.`status` = 'DISPONIVEL') and (`v`.`deleted_at` is null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-04 11:34:11

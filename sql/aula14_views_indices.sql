-- =====================================================================
-- Aula 14 - Views e Indices - Grupo 3
-- Atividade separada do Laboratorio 01. Pre-requisito: banco locadora
-- criado e populado por sql/Laboratorio01_Grupo3.sql.
-- SGBD: MySQL 8. Re-executavel: pode ser rodado varias vezes seguidas.
-- =====================================================================

USE locadora;


-- ---------------------------------------------------------------------
-- SECAO 0. Ampliacao da frota
-- ---------------------------------------------------------------------
-- A carga do Laboratorio 01 tem 8 veiculos. Aqui a frota passa para 30,
-- com 6 veiculos em cada uma das 5 categorias e status variados.
-- Para manter a coerencia dos dados: todo veiculo LOCADO recebe uma
-- locacao ABERTA, todo veiculo em MANUTENCAO recebe uma manutencao sem
-- data de saida, e todos recebem o documento (relacao 1:1).
-- ON DUPLICATE KEY / NOT EXISTS tornam a secao re-executavel.

INSERT INTO veiculo (id_veiculo, placa, chassi, marca, modelo, ano_fabricacao, ano_modelo, cor, combustivel, km_atual, status, id_categoria, id_filial) VALUES
-- ECONOMICO
( 9, 'QAB1C23', '9BWAA05U0EP000109', 'Volkswagen',    'Polo Track',    2024, 2025, 'Branco',   'FLEX',     8200,  'DISPONIVEL', 1, 3),
(10, 'QAC2D34', '9BGEA48A0PG000110', 'Chevrolet',     'Onix',          2023, 2024, 'Prata',    'FLEX',     21400, 'LOCADO',     1, 1),
(11, 'QAD3E45', '9BFZH55L0R8000111', 'Ford',          'Ka',            2021, 2021, 'Azul',     'FLEX',     48700, 'INATIVO',    1, 2),
-- INTERMEDIARIO
(12, 'QAE4F56', '9BWDB45U0PT000112', 'Volkswagen',    'Virtus',        2024, 2024, 'Cinza',    'FLEX',     11800, 'DISPONIVEL', 2, 1),
(13, 'QAF5G67', '9BD35812XRY000113', 'Fiat',          'Cronos',        2023, 2024, 'Branco',   'FLEX',     19600, 'LOCADO',     2, 2),
(14, 'QAG6H78', '93HGR3860RZ000114', 'Honda',         'City',          2024, 2025, 'Preto',    'FLEX',     7300,  'DISPONIVEL', 2, 5),
(15, 'QAH7J89', '9BHCN41BAR0000115', 'Hyundai',       'HB20S',         2023, 2023, 'Prata',    'FLEX',     25100, 'DISPONIVEL', 2, 4),
(16, 'QAJ8K90', '9BRBD48E0R4000116', 'Toyota',        'Yaris Sedan',   2022, 2023, 'Vermelho', 'FLEX',     33900, 'MANUTENCAO', 2, 3),
-- SUV
(17, 'QAK9L01', '9BWBH6BF0R4000117', 'Volkswagen',    'T-Cross',       2024, 2025, 'Branco',   'FLEX',     9400,  'LOCADO',     3, 1),
(18, 'QAL0M12', '9BHBG41DAR0000118', 'Hyundai',       'Creta',         2023, 2024, 'Cinza',    'FLEX',     22800, 'DISPONIVEL', 3, 3),
(19, 'QAM1N23', '93YHSR2F5RJ000119', 'Renault',       'Duster',        2022, 2022, 'Marrom',   'FLEX',     41200, 'DISPONIVEL', 3, 4),
(20, 'QAN2P34', '9BGEP76K0RB000120', 'Chevrolet',     'Tracker',       2024, 2024, 'Azul',     'FLEX',     14500, 'DISPONIVEL', 3, 5),
-- LUXO
(21, 'QAP3Q45', 'WDD2050421F000121', 'Mercedes-Benz', 'C 200',         2024, 2025, 'Preto',    'GASOLINA', 6100,  'DISPONIVEL', 4, 1),
(22, 'QAQ4R56', 'WAUZZZF40RA000122', 'Audi',          'A4',            2023, 2024, 'Branco',   'GASOLINA', 15800, 'LOCADO',     4, 5),
(23, 'QAR5S67', 'YV1ZWA8U0R1000123', 'Volvo',         'XC40 Recharge', 2024, 2024, 'Cinza',    'ELETRICO', 8900,  'DISPONIVEL', 4, 2),
(24, 'QAS6T78', 'JTHBA1D20R5000124', 'Lexus',         'ES 300h',       2023, 2023, 'Prata',    'HIBRIDO',  19700, 'MANUTENCAO', 4, 5),
(25, 'QAT7U89', 'WBA7U2100RG000125', 'BMW',           'X1',            2022, 2023, 'Azul',     'GASOLINA', 36400, 'INATIVO',    4, 1),
-- UTILITARIO
(26, 'QAU8V90', '93ZC3580R80000126', 'Iveco',         'Daily',         2023, 2023, 'Branco',   'DIESEL',   42300, 'DISPONIVEL', 5, 3),
(27, 'QAV9W01', 'WF0XXXTTGXR000127', 'Ford',          'Transit',       2024, 2024, 'Branco',   'DIESEL',   12600, 'LOCADO',     5, 4),
(28, 'QAW0X12', '9BD2651JHR9000128', 'Fiat',          'Strada',        2024, 2025, 'Vermelho', 'FLEX',     10300, 'DISPONIVEL', 5, 2),
(29, 'QAX1Y23', '8AC906635RE000129', 'Mercedes-Benz', 'Sprinter',      2022, 2023, 'Branco',   'DIESEL',   58800, 'DISPONIVEL', 5, 1),
(30, 'QAY2Z34', '9BD5781DAR8000130', 'Fiat',          'Ducato',        2023, 2024, 'Prata',    'DIESEL',   27400, 'DISPONIVEL', 5, 5)
ON DUPLICATE KEY UPDATE id_veiculo = id_veiculo;

-- Documento de cada veiculo novo, seguindo a numeracao da carga original.
-- Veiculo INATIVO fica sem apolice de seguro.
INSERT INTO documento_veiculo (id_veiculo, renavam, num_crlv, ano_licenciamento, venc_licenciamento, apolice_seguro, seguradora)
SELECT v.id_veiculo,
       CONCAT('100000000', LPAD(v.id_veiculo, 2, '0')),
       CONCAT('CRLV2026', LPAD(7411 + v.id_veiculo, 6, '0')),
       2026,
       '2026-12-31',
       IF(v.status = 'INATIVO', NULL, CONCAT('AP-2026-', 55411 + v.id_veiculo)),
       CASE WHEN v.status = 'INATIVO'    THEN NULL
            WHEN v.id_veiculo % 3 = 0    THEN 'Porto Seguro'
            WHEN v.id_veiculo % 3 = 1    THEN 'Allianz'
            ELSE 'Bradesco Seguros' END
FROM veiculo v
WHERE v.id_veiculo BETWEEN 9 AND 30
  AND NOT EXISTS (SELECT 1 FROM documento_veiculo d WHERE d.id_veiculo = v.id_veiculo);

-- Locacoes em aberto dos veiculos novos com status LOCADO.
-- km_retirada igual ao km_atual, porque o veiculo ainda nao voltou.
INSERT INTO locacao (id_locacao, id_cliente, id_veiculo, id_filial_retirada, id_filial_devolucao, data_retirada, data_prevista_devolucao, data_real_devolucao, valor_diaria_contratada, km_retirada, km_devolucao, valor_total, status) VALUES
(13, 2, 10, 1, 1, '2026-09-10 09:00:00', '2026-09-17 09:00:00', NULL, 129.90, 21400, NULL, NULL, 'ABERTA'),
(14, 3, 13, 2, 2, '2026-09-11 10:00:00', '2026-09-18 10:00:00', NULL, 189.90, 19600, NULL, NULL, 'ABERTA'),
(15, 4, 17, 1, 4, '2026-09-13 08:30:00', '2026-09-20 08:30:00', NULL, 289.90,  9400, NULL, NULL, 'ABERTA'),
(16, 5, 22, 5, 1, '2026-09-15 14:00:00', '2026-09-18 14:00:00', NULL, 549.90, 15800, NULL, NULL, 'ABERTA'),
(17, 6, 27, 4, 4, '2026-09-15 07:00:00', '2026-09-22 07:00:00', NULL, 219.90, 12600, NULL, NULL, 'ABERTA')
ON DUPLICATE KEY UPDATE id_locacao = id_locacao;

-- Manutencoes em aberto dos veiculos novos com status MANUTENCAO.
INSERT INTO manutencao (id_manutencao, id_veiculo, tipo, descricao, data_entrada, data_saida, km_manutencao, custo, fornecedor) VALUES
(8, 16, 'CORRETIVA', 'Troca do kit de embreagem',   '2026-09-14', NULL, 33900, 2150.00, 'Auto Center Guara'),
(9, 24, 'REVISAO',   'Revisao do sistema hibrido',  '2026-09-15', NULL, 19700, 1980.00, 'Concessionaria Lexus Brasilia')
ON DUPLICATE KEY UPDATE id_manutencao = id_manutencao;


-- ---------------------------------------------------------------------
-- SECAO 1. View atualizavel (slides 9 e 14)
-- ---------------------------------------------------------------------
-- Uma unica tabela, sem JOIN, sem agregacao e com a PK id_veiculo: o MySQL
-- consegue mapear cada linha da view para uma linha de veiculo, entao a
-- view aceita UPDATE. WITH CHECK OPTION recusa qualquer alteracao feita
-- pela view que deixaria a linha fora do filtro status = 'DISPONIVEL'.

CREATE OR REPLACE VIEW vw_veiculos_disponiveis AS
SELECT v.id_veiculo,
       v.placa,
       v.marca,
       v.modelo,
       v.cor,
       v.km_atual,
       v.status,
       v.id_categoria,
       v.id_filial
FROM veiculo v
WHERE v.status = 'DISPONIVEL'
WITH CHECK OPTION;

-- UPDATE que passa (a linha continua DISPONIVEL e a tabela veiculo e alterada):
--   UPDATE vw_veiculos_disponiveis SET km_atual = 13500 WHERE id_veiculo = 2;
--   Query OK, 1 row affected
--
-- UPDATE que o WITH CHECK OPTION bloqueia (a linha sairia do filtro):
--   UPDATE vw_veiculos_disponiveis SET status = 'MANUTENCAO' WHERE id_veiculo = 2;
--   ERROR 1369 (HY000): CHECK OPTION failed 'locadora.vw_veiculos_disponiveis'
--
-- Os dois comandos ficam so em comentario para o script nao alterar a carga
-- do laboratorio nem parar no erro.


-- ---------------------------------------------------------------------
-- SECAO 2. View com JOIN (slide 10)
-- ---------------------------------------------------------------------
-- Locacoes em aberto. Por ter JOIN, nao e atualizavel de forma geral; serve
-- para simplificar uma consulta usada com frequencia.

CREATE OR REPLACE VIEW vw_locacoes_ativas AS
SELECT l.id_locacao,
       c.nome                     AS cliente,
       v.placa                    AS placa,
       v.modelo                   AS modelo,
       fr.nome                    AS filial_retirada,
       l.data_retirada            AS data_retirada,
       l.data_prevista_devolucao  AS data_prevista_devolucao
FROM locacao l
JOIN cliente c  ON c.id_cliente = l.id_cliente
JOIN veiculo v  ON v.id_veiculo = l.id_veiculo
JOIN filial  fr ON fr.id_filial = l.id_filial_retirada
WHERE l.status = 'ABERTA';


-- ---------------------------------------------------------------------
-- SECAO 3. Exercicio 1 do slide 11
-- ---------------------------------------------------------------------
-- "Ativa ou ja encerrada" corresponde a ABERTA e FINALIZADA. As CANCELADA
-- ficam de fora: o contrato nao chegou a acontecer, nao tem valor faturado
-- e so poluiria uma listagem de locacoes efetivas do periodo.
-- No nosso esquema a data de inicio e data_retirada. valor_total e NULL
-- enquanto a locacao esta aberta, porque so e calculado na devolucao.

CREATE OR REPLACE VIEW vw_locacoes_mes AS
SELECT c.nome           AS cliente,
       v.modelo         AS veiculo,
       l.data_retirada  AS data_inicio,
       l.valor_total    AS valor_total
FROM locacao l
JOIN cliente c ON c.id_cliente = l.id_cliente
JOIN veiculo v ON v.id_veiculo = l.id_veiculo
WHERE l.status IN ('ABERTA', 'FINALIZADA')
ORDER BY l.data_retirada DESC;

-- Teste do ORDER BY na definicao (MySQL 8.0.46):
--   SELECT * FROM vw_locacoes_mes;  (sem ORDER BY externo)
--   A ordem se manteve: as 17 linhas vieram da data_inicio mais recente
--   (2026-09-15 14:00) para a mais antiga (2026-06-03 09:00). O EXPLAIN
--   mostra a view mesclada (select_type SIMPLE) com "Using filesort", ou
--   seja, o ORDER BY da definicao foi aplicado. Com um WHERE externo a
--   ordem tambem se manteve.
--   Com ORDER BY externo (ex.: ORDER BY cliente) o ORDER BY da view e
--   ignorado, como diz a documentacao do MySQL. Mesmo quando e respeitado,
--   isso e comportamento do otimizador e nao garantia do padrao SQL: quem
--   precisa de ordem deve colocar ORDER BY na consulta que le a view.


-- ---------------------------------------------------------------------
-- SECAO 4. View com agregacao (slide 13)
-- ---------------------------------------------------------------------
-- Soma apenas os contratos FINALIZADA. O filtro de status fica no ON do
-- LEFT JOIN, e o HAVING descarta os modelos sem nenhum contrato finalizado.
--
-- Nao e atualizavel: cada linha resume varias linhas de locacao (GROUP BY,
-- COUNT, SUM e HAVING), entao o MySQL nao tem como saber qual linha real
-- alterar. Alem disso ha JOIN. Um UPDATE nela devolve
-- ERROR 1288 (HY000): The target table vw_faturamento_veiculo of the UPDATE is not updatable

CREATE OR REPLACE VIEW vw_faturamento_veiculo AS
SELECT v.modelo              AS modelo,
       COUNT(l.id_locacao)   AS total_locacoes,
       SUM(l.valor_total)    AS faturamento
FROM veiculo v
LEFT JOIN locacao l ON l.id_veiculo = v.id_veiculo
                   AND l.status = 'FINALIZADA'
GROUP BY v.modelo
HAVING COUNT(l.id_locacao) > 0;


-- ---------------------------------------------------------------------
-- SECAO 5. View materializada simulada (slide 17)
-- ---------------------------------------------------------------------
-- O MySQL nao tem MATERIALIZED VIEW. O resultado e gravado numa tabela e
-- atualizado por uma procedure, chamada quando o relatorio precisar ser
-- renovado. Optamos por procedure em vez de EVENT porque o event_scheduler
-- pode estar desligado e liga-lo exige privilegio global.

DROP TABLE IF EXISTS mv_faturamento_veiculo;
CREATE TABLE mv_faturamento_veiculo AS
SELECT modelo, total_locacoes, faturamento
FROM vw_faturamento_veiculo;

DROP PROCEDURE IF EXISTS sp_refresh_mv_faturamento_veiculo;
DELIMITER //
CREATE PROCEDURE sp_refresh_mv_faturamento_veiculo()
BEGIN
    TRUNCATE TABLE mv_faturamento_veiculo;
    INSERT INTO mv_faturamento_veiculo (modelo, total_locacoes, faturamento)
    SELECT modelo, total_locacoes, faturamento
    FROM vw_faturamento_veiculo;
END//
DELIMITER ;

CALL sp_refresh_mv_faturamento_veiculo();
SELECT * FROM mv_faturamento_veiculo ORDER BY faturamento DESC;


-- ---------------------------------------------------------------------
-- SECAO 6. Indice composto e EXPLAIN (slides 22 e 24)
-- ---------------------------------------------------------------------
-- Consulta alvo: locacoes de um cliente a partir de uma data.
-- Indice idx_cliente_data (id_cliente, data_retirada), nessa ordem:
-- id_cliente entra com igualdade e reduz a busca a um cliente; dentro dele,
-- data_retirada ja esta ordenada e o intervalo >= e lido em sequencia.
--
-- Com 12 linhas em locacao o otimizador prefere table scan mesmo com
-- indice, e o EXPLAIN nao mostra ganho. Por isso a medicao e feita em
-- locacao_teste: mesma estrutura de locacao, sem FK e sem indices
-- secundarios, com 200 mil linhas geradas.

DROP TABLE IF EXISTS locacao_teste;
CREATE TABLE locacao_teste (
    id_locacao INT AUTO_INCREMENT NOT NULL,
    id_cliente INT NOT NULL,
    id_veiculo INT NOT NULL,
    id_filial_retirada INT NOT NULL,
    id_filial_devolucao INT NOT NULL,
    data_retirada DATETIME NOT NULL,
    data_prevista_devolucao DATETIME NOT NULL,
    data_real_devolucao DATETIME NULL DEFAULT NULL,
    valor_diaria_contratada DECIMAL(10,2) NOT NULL,
    km_retirada INT NOT NULL,
    km_devolucao INT NULL DEFAULT NULL,
    valor_total DECIMAL(10,2) NULL DEFAULT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ABERTA',
    CONSTRAINT pk_locacao_teste PRIMARY KEY (id_locacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Distribuicao: 1000 clientes (n % 1000) e datas espalhadas entre
-- 2024-01-01 e 2026-09-16 ((n * 7919) % 990 dias). Como 990 e 1000 sao
-- diferentes, cada cliente recebe datas variadas ao longo do periodo.
SET SESSION cte_max_recursion_depth = 200000;

INSERT INTO locacao_teste
    (id_cliente, id_veiculo, id_filial_retirada, id_filial_devolucao,
     data_retirada, data_prevista_devolucao, data_real_devolucao,
     valor_diaria_contratada, km_retirada, km_devolucao, valor_total, status)
WITH RECURSIVE seq (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 200000
),
base AS (
    SELECT n,
           TIMESTAMP('2024-01-01')
               + INTERVAL ((n * 7919) % 990) DAY
               + INTERVAL ((n * 13) % 24) HOUR  AS dt,
           1 + (n % 7)                          AS dias
    FROM seq
)
SELECT 1 + n % 1000,
       1 + n % 8,
       1 + n % 5,
       1 + (n * 3) % 5,
       dt,
       dt + INTERVAL dias DAY,
       dt + INTERVAL dias DAY,
       129.90,
       10000 + n % 20000,
       10000 + n % 20000 + 100 * dias,
       129.90 * dias,
       'FINALIZADA'
FROM base;

ANALYZE TABLE locacao_teste;

-- EXPLAIN SEM indice (MySQL 8.0.46):
--   type: ALL   key: NULL   rows: 199100   filtered: 3.33   Extra: Using where
--   Varredura completa: o otimizador estima ler praticamente as 200 mil linhas.
EXPLAIN
SELECT lt.id_locacao, lt.id_cliente, lt.data_retirada, lt.valor_total
FROM locacao_teste lt
WHERE lt.id_cliente = 42
  AND lt.data_retirada >= '2026-01-01';

CREATE INDEX idx_cliente_data ON locacao_teste (id_cliente, data_retirada);
ANALYZE TABLE locacao_teste;

-- EXPLAIN COM idx_cliente_data (MySQL 8.0.46):
--   type: range   key: idx_cliente_data   key_len: 9   rows: 54
--   filtered: 100.00   Extra: Using index condition
--   key_len 9 = 4 bytes de id_cliente (INT) + 5 de data_retirada (DATETIME):
--   as duas colunas do indice sao usadas. A estimativa cai de 199100 para
--   54 linhas, e a consulta devolve de fato 54 linhas.
EXPLAIN
SELECT lt.id_locacao, lt.id_cliente, lt.data_retirada, lt.valor_total
FROM locacao_teste lt
WHERE lt.id_cliente = 42
  AND lt.data_retirada >= '2026-01-01';

-- Mesmo indice na tabela real. O MySQL 8 nao tem CREATE INDEX IF NOT
-- EXISTS, entao o comando so e executado se o indice ainda nao existir.
SET @idx_existe := (
    SELECT COUNT(*)
    FROM information_schema.statistics s
    WHERE s.table_schema = 'locadora'
      AND s.table_name   = 'locacao'
      AND s.index_name   = 'idx_cliente_data'
);
SET @ddl := IF(@idx_existe = 0,
               'CREATE INDEX idx_cliente_data ON locacao (id_cliente, data_retirada)',
               'DO 0');
PREPARE stmt_idx FROM @ddl;
EXECUTE stmt_idx;
DEALLOCATE PREPARE stmt_idx;

SHOW INDEX FROM locacao WHERE Key_name = 'idx_cliente_data';

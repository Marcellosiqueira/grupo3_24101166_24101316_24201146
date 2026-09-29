-- =====================================================================
-- Laboratorio 01 - Parte 2 - Grupo 3
-- Views, indices, triggers, procedures e functions
-- SGBD: MySQL 8. Pre-requisito: banco locadora criado e povoado por
-- sql/Laboratorio01_Grupo3.sql.
-- Re-executavel: pode ser rodado varias vezes seguidas.
-- =====================================================================

USE locadora;


-- ---------------------------------------------------------------------
-- PARTE 1.1  VIEWS
-- ---------------------------------------------------------------------

-- Locacoes ainda sem data real de devolucao.
CREATE OR REPLACE VIEW vw_locacoes_ativas AS
SELECT l.id_locacao,
       c.nome                          AS cliente,
       c.cpf                           AS cpf_cliente,
       v.placa,
       CONCAT(v.marca, ' ', v.modelo)  AS veiculo,
       fr.nome                         AS filial_retirada,
       fd.nome                         AS filial_devolucao_prevista,
       l.data_retirada,
       l.data_prevista_devolucao,
       l.valor_diaria_contratada
FROM locacao l
JOIN cliente c  ON c.id_cliente = l.id_cliente
JOIN veiculo v  ON v.id_veiculo = l.id_veiculo
JOIN filial  fr ON fr.id_filial = l.id_filial_retirada
JOIN filial  fd ON fd.id_filial = l.id_filial_devolucao
WHERE l.data_real_devolucao IS NULL;

-- Veiculos prontos para locacao, com categoria e valor da diaria.
CREATE OR REPLACE VIEW vw_veiculos_disponiveis AS
SELECT v.id_veiculo,
       v.placa,
       v.marca,
       v.modelo,
       v.cor,
       v.km_atual,
       cat.nome         AS categoria,
       cat.valor_diaria,
       f.nome           AS filial_atual
FROM veiculo v
JOIN categoria cat ON cat.id_categoria = v.id_categoria
JOIN filial    f   ON f.id_filial      = v.id_filial
WHERE v.status = 'DISPONIVEL';

-- Faturamento agrupado por mes/ano e filial de retirada.
-- A receita e reconhecida na devolucao, porque valor_total so existe no
-- fechamento do contrato. Agrupar por data_retirada seria a alternativa.
CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT f.nome                                        AS filial_retirada,
       f.cidade,
       YEAR(l.data_real_devolucao)                   AS ano,
       MONTH(l.data_real_devolucao)                  AS mes,
       DATE_FORMAT(l.data_real_devolucao, '%Y-%m')   AS ano_mes,
       COUNT(l.id_locacao)                           AS total_locacoes,
       SUM(l.valor_total)                            AS faturamento_total
FROM locacao l
JOIN filial f ON f.id_filial = l.id_filial_retirada
WHERE l.status = 'FINALIZADA'
  AND l.data_real_devolucao IS NOT NULL
GROUP BY f.id_filial, f.nome, f.cidade,
         YEAR(l.data_real_devolucao),
         MONTH(l.data_real_devolucao),
         DATE_FORMAT(l.data_real_devolucao, '%Y-%m')
ORDER BY ano DESC, mes DESC, filial_retirada;


-- ---------------------------------------------------------------------
-- PARTE 1.2  INDICES DAS TRES CONSULTAS ANALISADAS
-- ---------------------------------------------------------------------
-- Consulta A, busca de cliente por CPF:
--   ja atendida por uq_cliente_cpf, criada no script do Laboratorio 01
--   como restricao UNIQUE. Nao ha indice novo a criar.
-- Consulta C, filtro de veiculos por categoria:
--   ja atendida por idx_veiculo_categoria (id_categoria, status), tambem
--   criada no Laboratorio 01.
-- Consulta B, locacoes por intervalo de data de retirada:
--   nao havia indice. E o unico criado aqui.
--
-- A medicao do EXPLAIN antes e depois esta em evidencias_explain.sql,
-- que NAO faz parte da entrega executavel: ele derruba e recria indices
-- para produzir o cenario "antes", e por isso fica separado deste script.

-- MySQL 8 nao tem CREATE INDEX IF NOT EXISTS, entao o indice e criado
-- condicionalmente para o script poder rodar mais de uma vez.
SET @ja_existe := (SELECT COUNT(*) FROM information_schema.STATISTICS
                   WHERE TABLE_SCHEMA = 'locadora'
                     AND TABLE_NAME   = 'locacao'
                     AND INDEX_NAME   = 'idx_locacao_data_retirada');
SET @ddl := IF(@ja_existe = 0,
               'CREATE INDEX idx_locacao_data_retirada ON locacao (data_retirada)',
               'DO 0');
PREPARE st FROM @ddl; EXECUTE st; DEALLOCATE PREPARE st;


-- ---------------------------------------------------------------------
-- PARTE 2.1  TABELA DE AUDITORIA E TRIGGERS
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS log_locacao (
    id_log         INT AUTO_INCREMENT PRIMARY KEY,
    id_locacao     INT            NOT NULL,
    valor_antigo   DECIMAL(10,2)  NULL,
    valor_novo     DECIMAL(10,2)  NULL,
    status_antigo  VARCHAR(15)    NULL,
    status_novo    VARCHAR(15)    NULL,
    usuario        VARCHAR(100)   NOT NULL,
    data_alteracao DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_locacao_locacao
        FOREIGN KEY (id_locacao) REFERENCES locacao (id_locacao)
        ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

DROP TRIGGER IF EXISTS trg_locacao_ai_status;
DROP TRIGGER IF EXISTS trg_locacao_au_status;
DROP TRIGGER IF EXISTS trg_locacao_au_auditoria;

DELIMITER $$

-- Ao abrir uma locacao, o veiculo passa a LOCADO.
-- A condicao sobre data_real_devolucao evita marcar como LOCADO um
-- contrato ja inserido encerrado, o que acontece na carga historica.
CREATE TRIGGER trg_locacao_ai_status
AFTER INSERT ON locacao
FOR EACH ROW
BEGIN
    IF NEW.data_real_devolucao IS NULL AND NEW.status = 'ABERTA' THEN
        UPDATE veiculo
           SET status = 'LOCADO'
         WHERE id_veiculo = NEW.id_veiculo;
    END IF;
END$$

-- Ao preencher a data real de devolucao, o veiculo volta a DISPONIVEL
-- e a quilometragem corrente do veiculo e atualizada.
CREATE TRIGGER trg_locacao_au_status
AFTER UPDATE ON locacao
FOR EACH ROW
BEGIN
    IF OLD.data_real_devolucao IS NULL
       AND NEW.data_real_devolucao IS NOT NULL THEN
        UPDATE veiculo
           SET status   = 'DISPONIVEL',
               km_atual = COALESCE(NEW.km_devolucao, km_atual)
         WHERE id_veiculo = NEW.id_veiculo;
    END IF;
END$$

-- Auditoria: registra alteracao de valor_total ou de status.
-- O comparador usa NULL-safe (<=>) porque valor_total nasce nulo.
CREATE TRIGGER trg_locacao_au_auditoria
AFTER UPDATE ON locacao
FOR EACH ROW
BEGIN
    IF NOT (OLD.valor_total <=> NEW.valor_total)
       OR NOT (OLD.status   <=> NEW.status) THEN
        INSERT INTO log_locacao (id_locacao, valor_antigo, valor_novo,
                                 status_antigo, status_novo, usuario)
        VALUES (NEW.id_locacao, OLD.valor_total, NEW.valor_total,
                OLD.status, NEW.status, CURRENT_USER());
    END IF;
END$$

DELIMITER ;


-- ---------------------------------------------------------------------
-- PARTE 2.2  PROCEDURE E FUNCTION
-- ---------------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_abrir_locacao;
DROP FUNCTION  IF EXISTS fn_calcula_multa;

DELIMITER $$

-- Abre uma locacao para um veiculo disponivel.
--
-- Duas adaptacoes em relacao ao enunciado generico, ambas para manter o
-- modelo entregue na Parte 1 sem alteracao:
--
-- 1. O enunciado preve um unico <id_filial>. O modelo tem filial de
--    retirada e de devolucao, as duas NOT NULL, porque o cenario permite
--    devolver em filial diferente. A procedure usa o parametro recebido
--    para as duas, que e o caso de devolucao na mesma unidade.
-- 2. O enunciado manda calcular o valor total e gravar no INSERT. No
--    dicionario de dados, valor_total e o valor faturado no fechamento e
--    nasce nulo, e a consulta de faturamento depende disso. A procedure
--    calcula o valor previsto e devolve em p_valor_previsto, mas grava
--    valor_total como NULL. O valor efetivo entra na devolucao.
--
-- LIMITACAO CONHECIDA, mantida de proposito: a leitura do status e um
-- SELECT comum, sem trava, entao existe uma janela entre a validacao e o
-- INSERT. Sob concorrencia, duas sessoes conseguem abrir locacao para o
-- mesmo veiculo. A demonstracao da falha e a versao corrigida com
-- FOR UPDATE estao em sql/parte3_concorrencia.sql (Cenarios 3 e 4) e na
-- Secao 7.5 do relatorio de evidencias. Esta versao fica aqui como
-- contraexemplo.
CREATE PROCEDURE sp_abrir_locacao (
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
END$$

-- Multa por atraso na devolucao.
-- Retorna 0 quando a locacao ainda esta aberta ou foi devolvida no prazo.
-- DATEDIFF compara apenas a parte de data, entao devolver no mesmo dia
-- alguns minutos depois da hora prevista nao gera multa.
CREATE FUNCTION fn_calcula_multa (
    p_id_locacao        INT,
    p_taxa_diaria_multa DECIMAL(10,2)
) RETURNS DECIMAL(10,2)
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
END$$

DELIMITER ;

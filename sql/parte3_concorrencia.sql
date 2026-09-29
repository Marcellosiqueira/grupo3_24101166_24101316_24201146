-- =====================================================================
-- Laboratorio 01 - Parte 3 - Grupo 3
-- Controle de concorrencia: roteiro de execucao com DUAS sessoes
-- SGBD: MySQL 8 (InnoDB). Pre-requisitos: Laboratorio01_Grupo3.sql e
-- script_parte2.sql ja executados (banco locadora, triggers, procedure).
--
-- COMO USAR
--   Abra tres conexoes (tres terminais ou tres abas do Workbench):
--     Sessao A  e  Sessao B : executam os cenarios
--     Sessao C              : monitor (consultas da secao 0.3)
--   Em todas: USE locadora;
--   Este arquivo NAO e para ser executado de uma vez. Cada comando traz
--   a sessao responsavel e o passo (T1, T2, ...). Execute na ordem dos
--   passos, alternando entre as sessoes. Rode o RESET (0.2) antes de
--   cada cenario e registre a saida REAL no relatorio: os "resultados
--   esperados" abaixo sao a hipotese a confirmar, nao a evidencia.
--
--   A secao 9 traz os tres experimentos do roteiro do professor na
--   forma literal. Os cenarios 1 a 8 sao a versao ampliada.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0.1  PREPARACAO
-- ---------------------------------------------------------------------
USE locadora;

-- RODAR EM CADA UMA DAS TRES SESSOES, logo apos conectar.
-- O padrao do innodb_lock_wait_timeout e 50 segundos. Nos cenarios 2, 3,
-- 4, 7 e 9.1 uma sessao fica bloqueada enquanto o operador alterna de
-- janela e consulta o monitor, e 50 segundos nao bastam: a sessao
-- bloqueada morre com "ERROR 1205 (HY000): Lock wait timeout exceeded".
-- O valor e de sessao, entao some se a conexao cair e precisa ser
-- aplicado de novo.
SET SESSION innodb_lock_wait_timeout = 300;

-- Todas as tabelas devem ser InnoDB (transacoes e bloqueio por linha).
SELECT TABLE_NAME, ENGINE
  FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'locadora'
   AND TABLE_TYPE   = 'BASE TABLE';

-- Versao corrigida de sp_abrir_locacao: trava a linha do veiculo com
-- FOR UPDATE OF v antes de verificar o status. A procedure da Parte 2
-- fica intacta para servir de contraexemplo no Cenario 3.
-- Deve ser chamada DENTRO de uma transacao explicita: em autocommit o
-- bloqueio seria liberado ao fim do proprio SELECT.
-- O FOR UPDATE nomeia apenas o alias v, e nao categoria: travar a
-- categoria serializaria todas as locacoes da mesma faixa de preco.
DROP PROCEDURE IF EXISTS sp_abrir_locacao_seguro;

DELIMITER $$
CREATE PROCEDURE sp_abrir_locacao_seguro (
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
            SET MESSAGE_TEXT = 'sp_abrir_locacao_seguro: dias de locacao deve ser 1 ou mais';
    END IF;

    SELECT v.status, v.km_atual, c.valor_diaria
      INTO v_status, v_km_atual, v_valor_diaria
      FROM veiculo v
      JOIN categoria c ON c.id_categoria = v.id_categoria
     WHERE v.id_veiculo = p_id_veiculo
       FOR UPDATE OF v;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_abrir_locacao_seguro: veiculo inexistente';
    END IF;

    IF v_status <> 'DISPONIVEL' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_abrir_locacao_seguro: veiculo nao esta disponivel';
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
DELIMITER ;


-- ---------------------------------------------------------------------
-- 0.2  RESET (rodar ANTES de cada cenario, com nenhuma transacao aberta)
-- ---------------------------------------------------------------------
-- Restaura os veiculos usados nos testes aos valores da carga original
-- e apaga locacoes/manutencoes criadas pelos cenarios (o log_locacao
-- dessas locacoes some junto, por ON DELETE CASCADE). Nao mexe nos
-- registros de log gerados nos testes da Parte 2.
DELETE FROM locacao    WHERE id_locacao    > 17;
ALTER TABLE locacao    AUTO_INCREMENT = 18;
DELETE FROM manutencao WHERE id_manutencao > 9;
ALTER TABLE manutencao AUTO_INCREMENT = 10;

UPDATE veiculo SET status = 'DISPONIVEL', km_atual = 13400 WHERE id_veiculo = 2;
UPDATE veiculo SET status = 'DISPONIVEL', km_atual =  9980 WHERE id_veiculo = 5;
UPDATE veiculo SET status = 'DISPONIVEL', km_atual =  5900 WHERE id_veiculo = 6;
UPDATE veiculo SET status = 'DISPONIVEL', km_atual = 32200 WHERE id_veiculo = 7;
UPDATE veiculo SET status = 'DISPONIVEL', km_atual = 27500 WHERE id_veiculo = 8;

-- Conferencia do estado inicial
SELECT id_veiculo, placa, status, km_atual
  FROM veiculo WHERE id_veiculo IN (2, 5, 6, 7, 8) ORDER BY id_veiculo;


-- ---------------------------------------------------------------------
-- 0.3  MONITOR (Sessao C) - rodar enquanto uma sessao estiver bloqueada
-- ---------------------------------------------------------------------
-- Transacoes ativas e quem esta esperando:
SELECT trx_id, trx_mysql_thread_id AS conexao, trx_state, trx_started,
       trx_wait_started, trx_rows_locked, trx_isolation_level, trx_query
  FROM information_schema.INNODB_TRX;

-- Travas mantidas e solicitadas (requer privilegio em performance_schema):
SELECT object_name, index_name, lock_type, lock_mode, lock_status,
       lock_data, thread_id
  FROM performance_schema.data_locks
 WHERE object_schema = 'locadora';

-- Quem bloqueia quem:
-- ATENCAO: blocking_query vem NULL na maioria dos cenarios deste
-- arquivo, e isso nao e defeito da consulta. A coluna mostra o comando
-- que a sessao bloqueadora esta executando AGORA; nos nossos cenarios
-- ela ja terminou o comando e esta parada com a transacao aberta, sem
-- comando em execucao. Para identificar quem segura a trava use
-- blocking_pid e cruze com trx_mysql_thread_id da consulta acima.
SELECT waiting_pid, waiting_query, blocking_pid, blocking_query,
       wait_age_secs
  FROM sys.innodb_lock_waits;

-- Configuracao usada nos testes:
SELECT @@transaction_isolation    AS isolamento_padrao,
       @@innodb_lock_wait_timeout AS timeout_espera_seg;


-- =====================================================================
-- CENARIO 1 - ATUALIZACAO PERDIDA (lost update), SEM controle
-- Alvo: veiculo 2, km_atual = 13400.
-- A aplicacao le o km, calcula o novo valor e grava. A soma de +100 (A)
-- e +50 (B) deveria dar 13550.
-- Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
SELECT km_atual INTO @km FROM veiculo WHERE id_veiculo = 2;
SELECT @km AS km_lido_por_A;                 -- esperado: 13400

-- T2 [B]
START TRANSACTION;
SELECT km_atual INTO @km FROM veiculo WHERE id_veiculo = 2;
SELECT @km AS km_lido_por_B;                 -- esperado: 13400

-- T3 [A]
UPDATE veiculo SET km_atual = @km + 100 WHERE id_veiculo = 2;
COMMIT;

-- T4 [B]  (nao bloqueia: A ja confirmou; B grava com base no valor velho)
UPDATE veiculo SET km_atual = @km + 50 WHERE id_veiculo = 2;
COMMIT;

-- T5 [A ou B]
SELECT id_veiculo, km_atual FROM veiculo WHERE id_veiculo = 2;
-- esperado: 13450. Correto seria 13550: o +100 de A foi perdido.


-- =====================================================================
-- CENARIO 2 - CORRECAO com bloqueio pessimista (SELECT ... FOR UPDATE)
-- Mesmo alvo e mesmas operacoes do Cenario 1. Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
SELECT km_atual INTO @km FROM veiculo WHERE id_veiculo = 2 FOR UPDATE;
SELECT @km AS km_lido_por_A;                 -- esperado: 13400

-- T2 [B]  (deve FICAR BLOQUEADA, sem retornar)
START TRANSACTION;
SELECT km_atual INTO @km FROM veiculo WHERE id_veiculo = 2 FOR UPDATE;

-- T3 [C]  registrar a evidencia do bloqueio (secao 0.3)
SELECT trx_mysql_thread_id, trx_state, trx_query FROM information_schema.INNODB_TRX;
SELECT waiting_pid, waiting_query, blocking_pid FROM sys.innodb_lock_waits;

-- T4 [A]
UPDATE veiculo SET km_atual = @km + 100 WHERE id_veiculo = 2;
COMMIT;                                      -- B e liberada

-- T5 [B]  (o SELECT do T2 retorna agora)
SELECT @km AS km_lido_por_B;                 -- esperado: 13500 (valor atualizado por A)
UPDATE veiculo SET km_atual = @km + 50 WHERE id_veiculo = 2;
COMMIT;

-- T6 [A ou B]
SELECT id_veiculo, km_atual FROM veiculo WHERE id_veiculo = 2;
-- esperado: 13550. Nenhuma atualizacao perdida.
-- Alternativa sem bloqueio explicito: UPDATE ... SET km_atual = km_atual + n.


-- =====================================================================
-- CENARIO 3 - LOCACAO CONCORRENTE DO MESMO VEICULO (falha da Parte 2)
-- sp_abrir_locacao verifica o status com SELECT comum (sem trava).
-- Alvo: veiculo 5 (DISPONIVEL). Clientes 1 (A) e 2 (B), filial 3.
-- Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
CALL sp_abrir_locacao(1, 5, 3, 3, @id_loc, @valor);
SELECT @id_loc AS locacao_A, @valor AS valor_previsto_A;
-- A ainda NAO deu COMMIT. O trigger trg_locacao_ai_status ja travou a
-- linha do veiculo 5 em A.

-- T2 [B]
START TRANSACTION;
CALL sp_abrir_locacao(2, 5, 3, 3, @id_loc, @valor);
-- Hipotese: o SELECT de status le o snapshot (ainda DISPONIVEL) e a
-- verificacao passa; B fica BLOQUEADA ao tocar a linha do veiculo 5.
-- Anotar em qual comando dentro da procedure a espera ocorre.

-- T3 [C]  evidencia do bloqueio
SELECT waiting_pid, waiting_query, blocking_pid FROM sys.innodb_lock_waits;

-- T4 [A]
COMMIT;                                      -- B e liberada

-- T5 [B]
COMMIT;
SELECT @id_loc AS locacao_B;

-- T6 [qualquer]
SELECT id_locacao, id_cliente, id_veiculo, status
  FROM locacao WHERE id_veiculo = 5 AND data_real_devolucao IS NULL;
-- esperado (falha): DUAS locacoes ABERTAS para o mesmo veiculo.


-- =====================================================================
-- CENARIO 4 - CORRECAO: sp_abrir_locacao_seguro
-- Alvo: veiculo 6 (DISPONIVEL). Clientes 1 (A) e 2 (B), filial 5.
-- Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
CALL sp_abrir_locacao_seguro(1, 6, 5, 3, @id_loc, @valor);
SELECT @id_loc AS locacao_A, @valor AS valor_previsto_A;

-- T2 [B]  (BLOQUEADA no SELECT ... FOR UPDATE, antes de qualquer INSERT)
START TRANSACTION;
CALL sp_abrir_locacao_seguro(2, 6, 5, 3, @id_loc, @valor);

-- T3 [C]  evidencia
SELECT waiting_pid, waiting_query, blocking_pid FROM sys.innodb_lock_waits;

-- T4 [A]
COMMIT;

-- T5 [B]  a chamada retorna com erro 1644 ("veiculo nao esta
--         disponivel"), porque a leitura com FOR UPDATE enxerga o
--         status LOCADO ja confirmado por A.
ROLLBACK;

-- T6 [qualquer]
SELECT id_locacao, id_cliente, id_veiculo, status
  FROM locacao WHERE id_veiculo = 6 AND data_real_devolucao IS NULL;
-- esperado: UMA locacao aberta (a de A).


-- =====================================================================
-- CENARIO 5 - DEADLOCK e sua prevencao
-- Alvos: veiculos 7 e 8, travados em ordem cruzada. Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
UPDATE veiculo SET km_atual = km_atual + 1 WHERE id_veiculo = 7;

-- T2 [B]
START TRANSACTION;
UPDATE veiculo SET km_atual = km_atual + 1 WHERE id_veiculo = 8;

-- T3 [A]  (BLOQUEIA: 8 esta com B)
UPDATE veiculo SET km_atual = km_atual + 1 WHERE id_veiculo = 8;

-- T4 [B]  (fecha o ciclo; o InnoDB detecta e aborta uma das duas)
UPDATE veiculo SET km_atual = km_atual + 1 WHERE id_veiculo = 7;
-- esperado: ERROR 1213 (40001) Deadlock found when trying to get lock;
-- try restarting transaction  (em B ou em A, conforme a vitima escolhida)

-- T5 [C]  evidencia (rodar logo apos o erro)
SHOW ENGINE INNODB STATUS\G
-- copiar a secao "LATEST DETECTED DEADLOCK"
-- No Workbench o \G nao existe: rodar SHOW ENGINE INNODB STATUS; e
-- abrir a celula Status do resultado.

-- T6 [A e B]  encerrar
ROLLBACK;

-- PREVENCAO: em ambas as sessoes, travar sempre na mesma ordem
-- (menor id_veiculo primeiro: 7 e depois 8). Repetir T1..T4 nessa
-- ordem para B tambem e confirmar que B apenas espera e nao ha
-- deadlock.


-- =====================================================================
-- CENARIO 6 - NIVEIS DE ISOLAMENTO: leitura nao repetivel e fantasma
-- Alvo: veiculo 2 e suas manutencoes. Rodar 0.2 antes de CADA variante.
-- =====================================================================

-- ---- 6a. READ COMMITTED --------------------------------------------
-- T1 [A]
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;
START TRANSACTION;
SELECT status FROM veiculo WHERE id_veiculo = 2;              -- DISPONIVEL
SELECT COUNT(*) AS qtd_manut FROM manutencao WHERE id_veiculo = 2;  -- 2

-- T2 [B]  (autocommit, cada comando ja confirma)
UPDATE veiculo SET status = 'MANUTENCAO' WHERE id_veiculo = 2;
INSERT INTO manutencao (id_veiculo, tipo, descricao, data_entrada, data_saida,
                        km_manutencao, custo, fornecedor)
VALUES (2, 'PREVENTIVA', 'Teste de concorrencia', '2026-09-28', NULL,
        13400, 100.00, 'Auto Center Guara');

-- T3 [A]  mesmas leituras, mesma transacao
SELECT status FROM veiculo WHERE id_veiculo = 2;
SELECT COUNT(*) AS qtd_manut FROM manutencao WHERE id_veiculo = 2;
-- esperado em READ COMMITTED: MANUTENCAO e 3
--   (leitura nao repetivel no status; linha fantasma na contagem)
COMMIT;

-- ---- 6b. REPEATABLE READ (padrao do MySQL) --------------------------
-- Rodar 0.2 (o RESET desfaz as alteracoes de B) e repetir:
-- T1 [A]
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;
START TRANSACTION;
SELECT status FROM veiculo WHERE id_veiculo = 2;              -- DISPONIVEL
SELECT COUNT(*) AS qtd_manut FROM manutencao WHERE id_veiculo = 2;  -- 2

-- T2 [B]  os mesmos UPDATE e INSERT da variante 6a

-- T3 [A]
SELECT status FROM veiculo WHERE id_veiculo = 2;
SELECT COUNT(*) AS qtd_manut FROM manutencao WHERE id_veiculo = 2;
-- esperado em REPEATABLE READ: DISPONIVEL e 2 (snapshot da transacao)
COMMIT;
SELECT status FROM veiculo WHERE id_veiculo = 2;              -- agora MANUTENCAO


-- =====================================================================
-- CENARIO 7 - SERIALIZABLE (opcional)
-- Em SERIALIZABLE, o SELECT comum dentro de transacao passa a travar
-- (compartilhado) as linhas lidas. Rodar 0.2 antes.
-- =====================================================================

-- T1 [A]
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT status FROM veiculo WHERE id_veiculo = 2;

-- T2 [B]  (nivel padrao; BLOQUEIA ate A encerrar)
UPDATE veiculo SET status = 'MANUTENCAO' WHERE id_veiculo = 2;

-- T3 [C]  evidencia
SELECT waiting_pid, waiting_query, blocking_pid FROM sys.innodb_lock_waits;

-- T4 [A]
COMMIT;                                      -- B e liberada

-- Restaurar o nivel padrao nas sessoes usadas:
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- =====================================================================
-- CENARIO 8 - ATOMICIDADE: ROLLBACK desfaz a devolucao e seus triggers
-- Alvo: locacao 11 (ABERTA, veiculo 1 LOCADO). NAO usar COMMIT aqui:
-- o cenario termina em ROLLBACK para nao alterar a carga.
-- =====================================================================

-- T1 [A]
START TRANSACTION;
UPDATE locacao
   SET data_real_devolucao = NOW(), km_devolucao = 19500,
       valor_total = 2029.30, status = 'FINALIZADA'
 WHERE id_locacao = 11;
SELECT status, km_atual FROM veiculo WHERE id_veiculo = 1;
-- dentro de A: DISPONIVEL e 19500 (trigger trg_locacao_au_status)
SELECT id_locacao, valor_antigo, valor_novo, status_antigo, status_novo
  FROM log_locacao WHERE id_locacao = 11;
-- dentro de A: 1 registro de auditoria novo (trigger de auditoria)

-- T2 [B]  (nao ve dados nao confirmados: sem leitura suja)
SELECT status, km_atual FROM veiculo WHERE id_veiculo = 1;    -- LOCADO, 19250
SELECT COUNT(*) FROM log_locacao WHERE id_locacao = 11;       -- sem o novo registro

-- T3 [A]
ROLLBACK;
SELECT status, km_atual FROM veiculo WHERE id_veiculo = 1;    -- LOCADO, 19250
SELECT status, data_real_devolucao FROM locacao WHERE id_locacao = 11;  -- ABERTA, NULL
-- A mesma transacao desfez locacao, veiculo e log_locacao.


-- =====================================================================
-- 9. EXPERIMENTOS DO ROTEIRO, NA FORMA LITERAL
-- Os cenarios 1 a 8 cobrem o mesmo conteudo de forma ampliada. Esta
-- secao reproduz os tres experimentos exatamente como o roteiro pede,
-- com os nomes de tabela e coluna do nosso modelo substituidos.
-- Rodar 0.2 antes de cada um.
-- =====================================================================

-- ---- 9.1  Experimento 3.1: bloqueio explicito ----------------------
-- T1 [A]
BEGIN;
SELECT * FROM veiculo WHERE id_veiculo = 1 FOR UPDATE;
-- manter a transacao aberta

-- T2 [B]  (fica bloqueada)
BEGIN;
SELECT * FROM veiculo WHERE id_veiculo = 1 FOR UPDATE;

-- T3 [A]
COMMIT;                                      -- B e liberada imediatamente

-- T4 [B]
COMMIT;

-- ---- 9.2  Experimento 3.2: inducao de deadlock ---------------------
-- Passo 1 [A]
BEGIN;
-- Passo 2 [A]
UPDATE cliente SET nome = 'Teste A' WHERE id_cliente = 1;
-- Passo 3 [B]
BEGIN;
-- Passo 4 [B]
UPDATE veiculo SET modelo = 'Teste B' WHERE id_veiculo = 1;
-- Passo 5 [A]  (fica aguardando a Sessao B)
UPDATE veiculo SET modelo = 'Teste A' WHERE id_veiculo = 1;
-- Passo 6 [B]  (provoca o deadlock)
UPDATE cliente SET nome = 'Teste B' WHERE id_cliente = 1;
-- esperado: ERROR 1213 (40001) em uma das duas sessoes

-- [C] capturar a mensagem oficial
SHOW ENGINE INNODB STATUS;
-- secao "LATEST DETECTED DEADLOCK"

-- [A e B] encerrar e restaurar os valores alterados
ROLLBACK;
UPDATE cliente SET nome  = 'Marcos Vinicius Andrade' WHERE id_cliente = 1;
UPDATE veiculo SET modelo = 'Corolla Cross'          WHERE id_veiculo = 1;

-- ---- 9.3  Experimento 3.3: isolamento e MVCC -----------------------
-- O roteiro trata READ COMMITTED como nivel padrao, o que vale para o
-- PostgreSQL e para o SQL Server, mas nao para o MySQL, cujo padrao no
-- InnoDB e REPEATABLE READ. Sem declarar o nivel, o passo 4 abaixo nao
-- mostra a atualizacao. Por isso a Sessao B declara explicitamente, e o
-- teste e feito nos dois niveis, o que ja atende ao passo 5 do roteiro.

-- T0 [B]
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- depois REPEATABLE READ
SELECT @@transaction_isolation;

-- T1 [A]
BEGIN;
UPDATE cliente SET nome = 'Alterado pela Sessao A' WHERE id_cliente = 1;  -- sem COMMIT

-- T2 [B]  leitura 1: valor antigo nos dois niveis (sem leitura suja)
BEGIN;
SELECT nome FROM cliente WHERE id_cliente = 1;

-- T3 [A]
COMMIT;

-- T4 [B]  leitura 2, mesma transacao
SELECT nome FROM cliente WHERE id_cliente = 1;
-- READ COMMITTED  : valor novo (leitura nao repetivel)
-- REPEATABLE READ : valor antigo (snapshot da transacao)

-- T5 [B]  leitura 3, nova transacao
COMMIT;
SELECT nome FROM cliente WHERE id_cliente = 1;   -- valor novo nos dois niveis

-- [B] restaurar
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE cliente SET nome = 'Marcos Vinicius Andrade' WHERE id_cliente = 1;


-- =====================================================================
-- ENCERRAMENTO: rodar 0.2 e confirmar que o banco voltou ao estado da
-- carga antes de entregar.
-- =====================================================================

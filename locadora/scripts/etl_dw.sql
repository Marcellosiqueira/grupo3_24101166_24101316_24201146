-- etl_dw.sql: carrega o modelo estrela a partir das tabelas do sistema (OLTP).
-- Rodar com a conta administrativa (app_locadora nao tem DELETE):
--   mysql -u admin_locadora -p locadora_lab < scripts/etl_dw.sql
-- Dimensoes antes do fato. Pode rodar quantas vezes quiser (ver respostas.md).
USE locadora_lab;
SET SESSION cte_max_recursion_depth = 5000;

-- dimensao tempo: um registro por dia
INSERT IGNORE INTO dim_tempo (sk_tempo, data, ano, mes, nome_mes, ano_mes, dia_semana)
WITH RECURSIVE dias AS (
  SELECT DATE('2020-01-01') AS d
  UNION ALL SELECT d + INTERVAL 1 DAY FROM dias WHERE d < '2027-12-31'
)
SELECT DATE_FORMAT(d, '%Y%m%d'), d, YEAR(d), MONTH(d),
       ELT(MONTH(d), 'Janeiro','Fevereiro','Marco','Abril','Maio','Junho',
                     'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'),
       DATE_FORMAT(d, '%Y-%m'),
       ELT(WEEKDAY(d) + 1, 'Segunda','Terca','Quarta','Quinta','Sexta','Sabado','Domingo')
FROM dias;

-- dimensao carro: inclui os excluidos (soft delete), marcados como inativos
INSERT INTO dim_carro (id_origem, placa, modelo, ativo)
SELECT id_veiculo, placa, modelo, deleted_at IS NULL FROM veiculo
ON DUPLICATE KEY UPDATE placa = VALUES(placa), modelo = VALUES(modelo), ativo = VALUES(ativo);

-- dimensao cliente
INSERT INTO dim_cliente (id_origem, nome, cidade)
SELECT id_cliente, nome, cidade FROM cliente
ON DUPLICATE KEY UPDATE nome = VALUES(nome), cidade = VALUES(cidade);

-- dimensao filial (filial de retirada da locacao)
INSERT INTO dim_filial (id_origem, nome, cidade)
SELECT id_filial, nome, cidade FROM filial
ON DUPLICATE KEY UPDATE nome = VALUES(nome), cidade = VALUES(cidade);

-- fato: recarga completa, numa transacao. Se o INSERT falhar (ex.: data fora
-- da dim_tempo, erro 1452), o cliente mysql para sem chegar ao COMMIT e o
-- DELETE e desfeito: a fato antiga continua la, em vez de ficar vazia.
-- dias: devolucao real; se nao houver (aberta ou cancelada), a prevista; minimo 1.
-- valor: FINALIZADA = valor_total; ABERTA = estimado (diaria contratada x dias
-- ate a data prevista); CANCELADA = 0, nao fatura.
START TRANSACTION;
DELETE FROM fato_locacao;
INSERT INTO fato_locacao (id_locacao, sk_tempo, sk_carro, sk_cliente, sk_filial, status, dias, valor)
SELECT l.id_locacao,
       DATE_FORMAT(l.data_retirada, '%Y%m%d'),
       dc.sk_carro,
       dcl.sk_cliente,
       df.sk_filial,
       l.status,
       GREATEST(DATEDIFF(COALESCE(l.data_real_devolucao, l.data_prevista_devolucao), l.data_retirada), 1),
       CASE l.status
         WHEN 'FINALIZADA' THEN l.valor_total
         WHEN 'ABERTA'     THEN l.valor_diaria_contratada
                                * GREATEST(DATEDIFF(l.data_prevista_devolucao, l.data_retirada), 1)
         ELSE 0
       END
FROM locacao l
JOIN dim_carro   dc  ON dc.id_origem  = l.id_veiculo
JOIN dim_cliente dcl ON dcl.id_origem = l.id_cliente
JOIN dim_filial  df  ON df.id_origem  = l.id_filial_retirada;
COMMIT;

-- estatisticas novas depois da recarga, para o otimizador estimar a fato direito
ANALYZE TABLE dim_tempo, dim_carro, dim_cliente, dim_filial, fato_locacao;

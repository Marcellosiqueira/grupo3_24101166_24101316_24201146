-- gerar_carga.sql: dados de teste da Parte 02, Etapa 0. Nao e migration.
-- Rodar uma vez, so em locadora_lab, com a conta administrativa:
--   mysql -u admin_locadora -p locadora_lab < scripts/gerar_carga.sql
-- So faz INSERT: nenhum DROP, DELETE, TRUNCATE ou UPDATE direto.
-- Efeito colateral: a trigger trg_locacao_ai_status (Bimestre I) roda para
-- cada locacao ABERTA inserida e passa o carro para LOCADO.

USE locadora_lab;
SET SESSION cte_max_recursion_depth = 200000;

-- 10 mil clientes, distribuidos em 5 cidades.
-- CPF = n com zeros a esquerda (Cliente teste 4242 tem CPF 00000004242).
-- Os 6 clientes reais tem CPF e CNH com valores bem maiores, entao nao colidem.
-- CNH comeca com 9 e e-mail usa dominio proprio, pelos UNIQUE de cliente.
INSERT INTO cliente (nome, cpf, num_cnh, cat_cnh, validade_cnh, data_nascimento,
                     telefone, email, logradouro, cidade, uf, cep, status)
WITH RECURSIVE n AS (
  SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 10000
)
SELECT CONCAT('Cliente teste ', i),
       LPAD(i, 11, '0'),
       CONCAT('9', LPAD(i, 10, '0')),
       'B',
       DATE '2030-12-31',
       DATE '1970-01-01' + INTERVAL (i MOD 12000) DAY,
       CONCAT('6199', LPAD(i, 7, '0')),
       CONCAT('cliente', i, '@teste.local'),
       CONCAT('Endereco teste ', i),
       ELT(1 + i MOD 5, 'Brasilia', 'Taguatinga', 'Aguas Claras', 'Ceilandia', 'Gama'),
       'DF',
       '70000000',
       'ATIVO'
FROM n;

-- 200 mil locacoes, com clientes e carros ja existentes (inclui os 6 clientes
-- reais e todos os carros). RAND com semente fixa, uma por coluna, para a
-- carga sair igual se for refeita do zero.
--   retirada: 2023-01-01 a 2025-12-30 (1095 dias), entre 08h e 17h
--   devolucao prevista: 1 a 7 dias depois
--   valor: 100 a 499; a diaria contratada e valor / dias, para a diaria
--          multiplicada pelos dias dar o mesmo valor nas abertas
--   status: ~2% CANCELADA, ~25% ABERTA, ~73% FINALIZADA
--   FINALIZADA: devolvida na data prevista, com valor_total e km de devolucao
--   ABERTA e CANCELADA: sem devolucao e sem valor_total, como no sistema
--   filial de retirada: a filial atual do carro, como faz LocacaoModel::abrir()
-- Os carros vem de uma tabela temporaria (some ao fim da sessao): a trigger
-- atualiza veiculo, e o MySQL nao deixa a mesma instrucao ler veiculo (erro 1442).
CREATE TEMPORARY TABLE tmp_carro AS
SELECT id_veiculo, id_filial, km_atual, ROW_NUMBER() OVER (ORDER BY id_veiculo) AS k
FROM veiculo;
-- temporaria so pode aparecer uma vez por instrucao (erro 1137)
SET @n_carros = (SELECT COUNT(*) FROM tmp_carro);

INSERT INTO locacao (id_cliente, id_veiculo, id_filial_retirada, id_filial_devolucao,
                     data_retirada, data_prevista_devolucao, data_real_devolucao,
                     valor_diaria_contratada, km_retirada, km_devolucao, valor_total, status)
WITH RECURSIVE n AS (
  SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 200000
),
cli AS (SELECT id_cliente, ROW_NUMBER() OVER (ORDER BY id_cliente) AS k FROM cliente),
fil AS (SELECT id_filial, ROW_NUMBER() OVER (ORDER BY id_filial) AS k FROM filial),
sorteio AS (
  SELECT 1 + FLOOR(RAND(1) * (SELECT COUNT(*) FROM cliente)) AS k_cli,
         1 + FLOOR(RAND(2) * @n_carros) AS k_car,
         1 + FLOOR(RAND(3) * (SELECT COUNT(*) FROM filial))  AS k_fil,
         TIMESTAMP('2023-01-01 08:00:00')
           + INTERVAL FLOOR(RAND(4) * 1095) DAY
           + INTERVAL FLOOR(RAND(5) * 10) HOUR AS retirada,
         1 + FLOOR(RAND(6) * 7) AS dias,
         100 + FLOOR(RAND(7) * 400) AS valor,
         CASE WHEN RAND(8) < 0.02 THEN 'CANCELADA'
              WHEN RAND(9) < 0.255 THEN 'ABERTA'
              ELSE 'FINALIZADA' END AS status
  FROM n
)
SELECT cli.id_cliente,
       car.id_veiculo,
       car.id_filial,
       fil.id_filial,
       s.retirada,
       s.retirada + INTERVAL s.dias DAY,
       IF(s.status = 'FINALIZADA', s.retirada + INTERVAL s.dias DAY, NULL),
       ROUND(s.valor / s.dias, 2),
       car.km_atual,
       IF(s.status = 'FINALIZADA', car.km_atual + s.dias * 100, NULL),
       IF(s.status = 'FINALIZADA', s.valor, NULL),
       s.status
FROM sorteio s
JOIN cli ON cli.k = s.k_cli
JOIN tmp_carro car ON car.k = s.k_car
JOIN fil ON fil.k = s.k_fil;

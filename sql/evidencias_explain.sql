-- =====================================================================
-- Laboratorio 01 - Parte 2 - Grupo 3
-- Evidencias do Exercicio 1.2: EXPLAIN antes e depois dos indices
--
-- NAO faz parte da entrega executavel. Este script derruba indices para
-- produzir o cenario "antes" e depois os recria. Rode apenas em ambiente
-- de teste, com o banco recriado pelo Laboratorio01_Grupo3.sql.
--
-- Duas das tres consultas ja tinham indice desde o Laboratorio 01:
--   Consulta A, CPF       -> uq_cliente_cpf (restricao UNIQUE)
--   Consulta C, categoria -> idx_veiculo_categoria (id_categoria, status)
-- Por isso o cenario "antes" exige derrubar esses indices primeiro.
-- =====================================================================

USE locadora;

-- ---------------------------------------------------------------------
-- ANTES: sem nenhum dos tres indices
-- ---------------------------------------------------------------------
-- idx_veiculo_categoria comeca por id_categoria e e o indice que sustenta
-- a chave estrangeira fk_veiculo_categoria. O MySQL recusa derrubar um
-- indice necessario a uma FK (erro 1553), entao a FK sai primeiro e volta
-- depois. Esse detalhe e uma conclusao por si: coluna que participa de
-- chave estrangeira nunca fica sem indice neste modelo.
ALTER TABLE veiculo DROP FOREIGN KEY fk_veiculo_categoria;
ALTER TABLE veiculo DROP INDEX idx_veiculo_categoria;
ALTER TABLE cliente DROP INDEX uq_cliente_cpf;
ALTER TABLE locacao DROP INDEX idx_locacao_data_retirada;
ANALYZE TABLE cliente, veiculo, locacao;

SELECT 'CONSULTA A - cliente por CPF - ANTES' AS cenario;
EXPLAIN SELECT id_cliente, nome, cpf, telefone
          FROM cliente
         WHERE cpf = '07894561203';

SELECT 'CONSULTA B - locacoes por intervalo de data - ANTES' AS cenario;
EXPLAIN SELECT id_locacao, id_cliente, id_veiculo, data_retirada, valor_total
          FROM locacao
         WHERE data_retirada BETWEEN '2026-08-01' AND '2026-09-30';

SELECT 'CONSULTA C - veiculos por categoria - ANTES' AS cenario;
EXPLAIN SELECT id_veiculo, placa, marca, modelo, status
          FROM veiculo
         WHERE id_categoria = 3;

-- ---------------------------------------------------------------------
-- DEPOIS: com os tres indices
-- ---------------------------------------------------------------------
ALTER TABLE cliente ADD CONSTRAINT uq_cliente_cpf UNIQUE (cpf);
CREATE INDEX idx_veiculo_categoria     ON veiculo (id_categoria, status);
CREATE INDEX idx_locacao_data_retirada ON locacao (data_retirada);
ALTER TABLE veiculo
    ADD CONSTRAINT fk_veiculo_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON DELETE RESTRICT;
ANALYZE TABLE cliente, veiculo, locacao;

SELECT 'CONSULTA A - cliente por CPF - DEPOIS' AS cenario;
EXPLAIN SELECT id_cliente, nome, cpf, telefone
          FROM cliente
         WHERE cpf = '07894561203';

SELECT 'CONSULTA B - locacoes por intervalo de data - DEPOIS' AS cenario;
EXPLAIN SELECT id_locacao, id_cliente, id_veiculo, data_retirada, valor_total
          FROM locacao
         WHERE data_retirada BETWEEN '2026-08-01' AND '2026-09-30';

SELECT 'CONSULTA C - veiculos por categoria - DEPOIS' AS cenario;
EXPLAIN SELECT id_veiculo, placa, marca, modelo, status
          FROM veiculo
         WHERE id_categoria = 3;

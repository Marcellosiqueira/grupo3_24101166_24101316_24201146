-- 004_idx_locacao_cliente_data.sql
-- Indice composto para a Q4 (cliente + data). E o unico indice novo da Etapa 2:
-- data_retirada (idx_locacao_data_retirada), cliente.nome (idx_cliente_nome) e
-- cliente.cpf (UNIQUE uq_cliente_cpf) ja tinham indice desde o Bimestre I, e
-- repetir esses indices so traria custo de escrita. Por isso as 004, 005 e 007
-- do enunciado nao existem aqui e esta ocupa a 004.
-- up
CREATE INDEX idx_locacao_cliente_data ON locacao (id_cliente, data_retirada);

-- down
DROP INDEX idx_locacao_cliente_data ON locacao;

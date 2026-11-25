-- 002_add_cor_externa.sql
-- Expandir. No projeto a tabela de carros e veiculo, e cor ja existe (NOT NULL).
-- cor_externa nasce NULL para o codigo antigo, que so grava cor, continuar funcionando.
-- up
ALTER TABLE veiculo ADD COLUMN cor_externa VARCHAR(30) NULL;

-- down
ALTER TABLE veiculo DROP COLUMN cor_externa;

-- 003_drop_cor.sql
-- Contrair: so depois de o codigo ler e gravar apenas cor_externa e da 002a
-- tirar cor da vw_veiculos_disponiveis.
-- up
ALTER TABLE veiculo DROP COLUMN cor;

-- down
-- Volta so a estrutura: a coluna reaparece vazia (NULL). Os valores so voltam
-- pelo backup da Etapa 0 (banco/locadora_backup_parte02.sql).
ALTER TABLE veiculo ADD COLUMN cor VARCHAR(30) NULL;

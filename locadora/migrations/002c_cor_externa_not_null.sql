-- 002c_cor_externa_not_null.sql
-- Fecha o expandir e contrair: depois do backfill (scripts/backfill_cor.php)
-- todo carro tem cor_externa, e a coluna passa a ser obrigatoria. O nome 002c
-- ordena depois da 002b e antes da 003, entao roda antes de apagar cor.
-- Se ainda houver carro com cor_externa NULL, o MySQL recusa com o erro 1138
-- (Invalid use of NULL value) e o migrate.php manda rodar o backfill.
-- up
ALTER TABLE veiculo MODIFY cor_externa VARCHAR(30) NOT NULL;

-- down
ALTER TABLE veiculo MODIFY cor_externa VARCHAR(30) NULL;

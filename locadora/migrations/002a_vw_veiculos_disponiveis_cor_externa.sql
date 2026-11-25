-- 002a_vw_veiculos_disponiveis_cor_externa.sql
-- A vw_veiculos_disponiveis (Bimestre I, com o filtro de deleted_at da Parte 01)
-- le v.cor e ficaria invalida depois da 003. Recria a view lendo cor_externa.
-- O nome 002a ordena depois da 002 e antes da 003, no sort() do up e no
-- ORDER BY version DESC do down. Rodar so depois do backfill.
-- up
CREATE OR REPLACE VIEW vw_veiculos_disponiveis AS
SELECT v.id_veiculo,
       v.placa,
       v.marca,
       v.modelo,
       v.cor_externa,
       v.km_atual,
       cat.nome         AS categoria,
       cat.valor_diaria,
       f.nome           AS filial_atual
FROM veiculo v
JOIN categoria cat ON cat.id_categoria = v.id_categoria
JOIN filial    f   ON f.id_filial      = v.id_filial
WHERE v.status = 'DISPONIVEL' AND v.deleted_at IS NULL;

-- down
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
WHERE v.status = 'DISPONIVEL' AND v.deleted_at IS NULL;

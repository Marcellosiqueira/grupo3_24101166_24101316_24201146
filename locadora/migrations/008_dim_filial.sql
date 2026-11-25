-- 008_dim_filial.sql
-- Alem das tres do enunciado: o painel 4 usa a filial de retirada, que e um
-- dado da locacao (nao do carro nem do cliente), entao vira dimensao propria.
-- up
CREATE TABLE dim_filial (
  sk_filial INT AUTO_INCREMENT PRIMARY KEY,
  id_origem INT NOT NULL UNIQUE,       -- filial.id_filial
  nome      VARCHAR(80) NOT NULL,
  cidade    VARCHAR(60) NOT NULL
);

-- down
DROP TABLE dim_filial;

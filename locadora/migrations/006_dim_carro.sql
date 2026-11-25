-- 006_dim_carro.sql
-- ativo = 0 para carro excluido (soft delete): ele continua na dimensao.
-- up
CREATE TABLE dim_carro (
  sk_carro  INT AUTO_INCREMENT PRIMARY KEY,
  id_origem INT NOT NULL UNIQUE,       -- veiculo.id_veiculo
  placa     CHAR(7) NOT NULL,
  modelo    VARCHAR(60) NOT NULL,
  ativo     TINYINT(1) NOT NULL
);

-- down
DROP TABLE dim_carro;

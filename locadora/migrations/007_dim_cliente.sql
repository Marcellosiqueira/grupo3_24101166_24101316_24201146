-- 007_dim_cliente.sql
-- up
CREATE TABLE dim_cliente (
  sk_cliente INT AUTO_INCREMENT PRIMARY KEY,
  id_origem  INT NOT NULL UNIQUE,      -- cliente.id_cliente
  nome       VARCHAR(120) NOT NULL,
  cidade     VARCHAR(60) NOT NULL
);

-- down
DROP TABLE dim_cliente;

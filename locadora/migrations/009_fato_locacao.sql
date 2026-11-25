-- 009_fato_locacao.sql
-- Grao: uma linha por locacao. sk_filial e a filial de retirada.
-- Cada FOREIGN KEY cria o seu indice na fato (InnoDB).
-- up
CREATE TABLE fato_locacao (
  id_locacao INT PRIMARY KEY,          -- locacao.id_locacao (dimensao degenerada)
  sk_tempo   INT NOT NULL,             -- data de retirada
  sk_carro   INT NOT NULL,
  sk_cliente INT NOT NULL,
  sk_filial  INT NOT NULL,
  status     VARCHAR(10) NOT NULL,
  dias       INT NOT NULL,
  valor      DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_fato_tempo   FOREIGN KEY (sk_tempo)   REFERENCES dim_tempo (sk_tempo),
  CONSTRAINT fk_fato_carro   FOREIGN KEY (sk_carro)   REFERENCES dim_carro (sk_carro),
  CONSTRAINT fk_fato_cliente FOREIGN KEY (sk_cliente) REFERENCES dim_cliente (sk_cliente),
  CONSTRAINT fk_fato_filial  FOREIGN KEY (sk_filial)  REFERENCES dim_filial (sk_filial)
);

-- down
DROP TABLE fato_locacao;

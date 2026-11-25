-- 005_dim_tempo.sql
-- Modelo estrela (Etapa 3). Comeca na 005 porque so a 004 foi usada em indice.
-- up
CREATE TABLE dim_tempo (
  sk_tempo   INT PRIMARY KEY,          -- AAAAMMDD
  data       DATE NOT NULL,
  ano        SMALLINT NOT NULL,
  mes        TINYINT NOT NULL,
  nome_mes   VARCHAR(15) NOT NULL,
  ano_mes    CHAR(7) NOT NULL,
  dia_semana VARCHAR(15) NOT NULL
);

-- down
DROP TABLE dim_tempo;

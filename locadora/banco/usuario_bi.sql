-- Desafio da Etapa 3: conta do SGBD so de leitura para o BI. Rodar como root,
-- depois das migrations 005 a 009. Troque a senha; ela vai tambem em config/config.php.
CREATE USER IF NOT EXISTS 'bi_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha_bi';
GRANT SELECT ON locadora_lab.dim_tempo    TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_carro    TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_cliente  TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.dim_filial   TO 'bi_locadora'@'localhost';
GRANT SELECT ON locadora_lab.fato_locacao TO 'bi_locadora'@'localhost';
FLUSH PRIVILEGES;

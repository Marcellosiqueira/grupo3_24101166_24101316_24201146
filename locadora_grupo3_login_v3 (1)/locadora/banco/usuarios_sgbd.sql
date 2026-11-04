-- Etapa 5: usuarios do SGBD. Rodar como root, depois de migration_v2.sql.
-- Troque as senhas; a de app_locadora vai tambem em config/config.php.

CREATE USER IF NOT EXISTS 'app_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha';
GRANT SELECT, INSERT, UPDATE ON locadora.* TO 'app_locadora'@'localhost';

CREATE USER IF NOT EXISTS 'admin_locadora'@'localhost' IDENTIFIED BY 'troque_esta_senha_admin';
GRANT ALL PRIVILEGES ON locadora.* TO 'admin_locadora'@'localhost';

FLUSH PRIVILEGES;

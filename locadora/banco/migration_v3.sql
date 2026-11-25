-- Locadora v3. Login com senha escolhida por cada usuario.
-- Rodar uma vez, como root, depois de restaurar backup_locadora.sql:
--   mysql -u root -p locadora < banco/migration_v3.sql
-- Precisa de root porque app_locadora nao tem ALTER (de proposito, Etapa 5).

USE locadora;

ALTER TABLE usuarios
    MODIFY senha_hash VARCHAR(255) NULL,                       -- NULL = ainda nao escolheu a senha
    ADD COLUMN token_hash CHAR(64) NULL,                       -- SHA-256 do link de uso unico
    ADD COLUMN token_expira_em DATETIME NULL,
    ADD COLUMN deve_trocar_senha TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN tentativas_falhas TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN bloqueado_ate DATETIME NULL,
    ADD UNIQUE KEY uq_usuarios_token (token_hash);

-- As senhas de teste (admin2026 e atende2026) estao no LEIAME, ou seja, todo
-- mundo as conhece. Esses dois usuarios passam a escolher uma senha propria
-- no primeiro acesso.
UPDATE usuarios SET deve_trocar_senha = 1;

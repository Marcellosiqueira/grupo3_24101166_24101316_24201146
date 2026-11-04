-- Locadora v2. Registro do que esta etapa mudou no esquema do Bimestre I.
-- Ja esta aplicado em backup_locadora.sql: nao rodar de novo.
-- Senhas de teste: admin2026 e atende2026.

USE locadora;

-- Etapa 3: soft delete. No projeto a tabela de carros e veiculo.
ALTER TABLE veiculo ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL;

-- A view de disponiveis tambem e uma listagem: carro excluido nao aparece.
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

-- Etapa 6: usuarios do sistema.
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('admin','atendente') NOT NULL DEFAULT 'atendente',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Hashes gerados com password_hash(). Sem o primeiro admin ninguem entraria.
INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES
('Administrador de teste', 'admin@locadora.test',     '$2y$10$D56btf0dvs1v4yVTdZMZj.A52JKmY18IM4BbPEIFEnsc4pFQWFpdS', 'admin'),
('Atendente de teste',     'atendente@locadora.test', '$2y$10$7RqHFjUDcbPAhLVbPJFZEu8GBT0tmT04z9xhyuaySHtb/Ek4m24lW', 'atendente');

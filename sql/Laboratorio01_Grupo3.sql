-- =====================================================================
-- Laboratório 01 - Banco de Dados - Grupo 3
-- Script completo: criação (Etapa 4), inserção e consultas (Etapa 5)
-- SGBD: MySQL 8. Executar de uma vez, sem schema pré-selecionado.
-- =====================================================================

DROP DATABASE IF EXISTS locadora;
CREATE DATABASE locadora CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE locadora;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    cpf CHAR(11) NOT NULL,
    num_cnh CHAR(11) NOT NULL,
    cat_cnh CHAR(2) NOT NULL,
    validade_cnh DATE NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(120) NULL DEFAULT NULL,
    logradouro VARCHAR(150) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    INDEX idx_cliente_nome (nome),
    CONSTRAINT uq_cliente_cpf UNIQUE (cpf),
    CONSTRAINT uk_cliente_num_cnh UNIQUE (num_cnh),
    CONSTRAINT uk_cliente_email UNIQUE (email),
    CONSTRAINT chk_cliente_cat_cnh CHECK (cat_cnh IN ('A', 'B', 'AB', 'C', 'D', 'E')),
    CONSTRAINT chk_cliente_status CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE filial (
    id_filial INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(80) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    CONSTRAINT pk_filial PRIMARY KEY (id_filial),
    CONSTRAINT uk_filial_cnpj UNIQUE (cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(40) NOT NULL,
    descricao VARCHAR(200) NULL DEFAULT NULL,
    valor_diaria DECIMAL(10,2) NOT NULL,
    franquia_km INT NOT NULL DEFAULT 200,
    valor_km_excedente DECIMAL(10,2) NOT NULL DEFAULT 1.50,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uk_categoria_nome UNIQUE (nome),
    CONSTRAINT chk_categoria_valor_diaria CHECK (valor_diaria > 0),
    CONSTRAINT chk_categoria_franquia_km CHECK (franquia_km >= 0),
    CONSTRAINT chk_categoria_valor_km_excedente CHECK (valor_km_excedente >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT NOT NULL,
    placa CHAR(7) NOT NULL,
    chassi CHAR(17) NOT NULL,
    marca VARCHAR(40) NOT NULL,
    modelo VARCHAR(60) NOT NULL,
    ano_fabricacao SMALLINT NOT NULL,
    ano_modelo SMALLINT NOT NULL,
    cor VARCHAR(30) NOT NULL,
    combustivel VARCHAR(15) NOT NULL DEFAULT 'FLEX',
    km_atual INT NOT NULL DEFAULT 0,
    status VARCHAR(15) NOT NULL DEFAULT 'DISPONIVEL',
    id_categoria INT NOT NULL,
    id_filial INT NOT NULL,
    CONSTRAINT pk_veiculo PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa),
    CONSTRAINT uk_veiculo_chassi UNIQUE (chassi),
    INDEX idx_veiculo_categoria (id_categoria, status),
    CONSTRAINT fk_veiculo_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_veiculo_filial FOREIGN KEY (id_filial) REFERENCES filial (id_filial) ON DELETE RESTRICT,
    CONSTRAINT chk_veiculo_ano_fabricacao CHECK (ano_fabricacao >= 1990),
    CONSTRAINT chk_veiculo_ano_modelo CHECK (ano_modelo >= ano_fabricacao),
    CONSTRAINT chk_veiculo_combustivel CHECK (combustivel IN ('FLEX', 'GASOLINA', 'DIESEL', 'ELETRICO', 'HIBRIDO')),
    CONSTRAINT chk_veiculo_km_atual CHECK (km_atual >= 0),
    CONSTRAINT chk_veiculo_status CHECK (status IN ('DISPONIVEL', 'LOCADO', 'MANUTENCAO', 'INATIVO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE documento_veiculo (
    id_veiculo INT NOT NULL,
    renavam CHAR(11) NOT NULL,
    num_crlv VARCHAR(20) NOT NULL,
    ano_licenciamento SMALLINT NOT NULL,
    venc_licenciamento DATE NOT NULL,
    apolice_seguro VARCHAR(30) NULL DEFAULT NULL,
    seguradora VARCHAR(80) NULL DEFAULT NULL,
    CONSTRAINT pk_documento_veiculo PRIMARY KEY (id_veiculo),
    CONSTRAINT uk_documento_veiculo_renavam UNIQUE (renavam),
    CONSTRAINT fk_documento_veiculo_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculo (id_veiculo) ON DELETE CASCADE,
    CONSTRAINT chk_documento_veiculo_ano_licenciamento CHECK (ano_licenciamento >= 1990)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE locacao (
    id_locacao INT AUTO_INCREMENT NOT NULL,
    id_cliente INT NOT NULL,
    id_veiculo INT NOT NULL,
    id_filial_retirada INT NOT NULL,
    id_filial_devolucao INT NOT NULL,
    data_retirada DATETIME NOT NULL,
    data_prevista_devolucao DATETIME NOT NULL,
    data_real_devolucao DATETIME NULL DEFAULT NULL,
    valor_diaria_contratada DECIMAL(10,2) NOT NULL,
    km_retirada INT NOT NULL,
    km_devolucao INT NULL DEFAULT NULL,
    valor_total DECIMAL(10,2) NULL DEFAULT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'ABERTA',
    CONSTRAINT pk_locacao PRIMARY KEY (id_locacao),
    INDEX idx_locacao_aberta (data_real_devolucao),
    INDEX idx_locacao_cliente (id_cliente),
    INDEX idx_locacao_filial_ret (id_filial_retirada),
    CONSTRAINT fk_locacao_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente) ON DELETE RESTRICT,
    CONSTRAINT fk_locacao_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculo (id_veiculo) ON DELETE RESTRICT,
    CONSTRAINT fk_locacao_filial_retirada FOREIGN KEY (id_filial_retirada) REFERENCES filial (id_filial) ON DELETE RESTRICT,
    CONSTRAINT fk_locacao_filial_devolucao FOREIGN KEY (id_filial_devolucao) REFERENCES filial (id_filial) ON DELETE RESTRICT,
    CONSTRAINT chk_locacao_datas_previstas CHECK (data_prevista_devolucao > data_retirada),
    CONSTRAINT chk_locacao_valor_diaria CHECK (valor_diaria_contratada > 0),
    CONSTRAINT chk_locacao_km_retirada CHECK (km_retirada >= 0),
    CONSTRAINT chk_locacao_km_devolucao CHECK (km_devolucao IS NULL OR km_devolucao >= km_retirada),
    CONSTRAINT chk_locacao_valor_total CHECK (valor_total IS NULL OR valor_total >= 0),
    CONSTRAINT chk_locacao_status CHECK (status IN ('ABERTA', 'FINALIZADA', 'CANCELADA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE manutencao (
    id_manutencao INT AUTO_INCREMENT NOT NULL,
    id_veiculo INT NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    data_entrada DATE NOT NULL,
    data_saida DATE NULL DEFAULT NULL,
    km_manutencao INT NOT NULL,
    custo DECIMAL(10,2) NOT NULL,
    fornecedor VARCHAR(100) NOT NULL,
    CONSTRAINT pk_manutencao PRIMARY KEY (id_manutencao),
    INDEX idx_manutencao_veiculo (id_veiculo),
    CONSTRAINT fk_manutencao_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculo (id_veiculo) ON DELETE RESTRICT,
    CONSTRAINT chk_manutencao_tipo CHECK (tipo IN ('PREVENTIVA', 'CORRETIVA', 'REVISAO')),
    CONSTRAINT chk_manutencao_datas CHECK (data_saida IS NULL OR data_saida >= data_entrada),
    CONSTRAINT chk_manutencao_km CHECK (km_manutencao >= 0),
    CONSTRAINT chk_manutencao_custo CHECK (custo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------
-- 1. CARGA DE DADOS
-- ---------------------------------------------------------------------

INSERT INTO categoria (id_categoria, nome, descricao, valor_diaria, franquia_km, valor_km_excedente) VALUES
(1, 'ECONOMICO',     'Hatch compacto, ar-condicionado e direcao eletrica',     129.90, 200, 1.20),
(2, 'INTERMEDIARIO', 'Sedan compacto, porta-malas ampliado',                   189.90, 200, 1.40),
(3, 'SUV',           'Veiculo alto, cinco lugares, porta-malas grande',        289.90, 250, 1.90),
(4, 'LUXO',          'Sedan premium, cambio automatico e acabamento em couro', 549.90, 150, 3.50),
(5, 'UTILITARIO',    'Furgao de carga para transporte de volumes',             219.90, 300, 1.60);

INSERT INTO filial (id_filial, nome, cnpj, logradouro, cidade, uf, cep, telefone) VALUES
(1, 'Filial Asa Sul',      '12345678000190', 'SGAS 607 Bloco A Loja 12',       'Brasilia',     'DF', '70200670', '6132245510'),
(2, 'Filial Asa Norte',    '12345678000271', 'CLN 408 Bloco C Loja 30',        'Brasilia',     'DF', '70856530', '6132248820'),
(3, 'Filial Taguatinga',   '12345678000352', 'QNA 14 Lote 8',                  'Taguatinga',   'DF', '72110140', '6133518840'),
(4, 'Filial Aguas Claras', '12345678000433', 'Rua Copaiba Lote 15 Loja 4',     'Aguas Claras', 'DF', '71919180', '6133619070'),
(5, 'Filial Aeroporto',    '12345678000514', 'Aeroporto Internacional Setor 2','Brasilia',     'DF', '71608900', '6134647120');

INSERT INTO cliente (id_cliente, nome, cpf, num_cnh, cat_cnh, validade_cnh, data_nascimento, telefone, email, logradouro, cidade, uf, cep, data_cadastro, status) VALUES
(1, 'Marcos Vinicius Andrade',  '07894561203', '03214785690', 'B',  '2029-04-18', '1988-03-22', '61991819883', 'marcos.andrade@email.com',  'SHIN QI 5 Conjunto 3 Casa 12', 'Brasilia',     'DF', '71503035', '2025-11-04 10:12:00', 'ATIVO'),
(2, 'Patricia Nogueira Lima',   '15342768094', '07845123607', 'AB', '2028-11-02', '1992-07-09', '61984472260', 'patricia.lima@email.com',   'SQS 308 Bloco F Apartamento 204','Brasilia',    'DF', '70355060', '2026-01-19 14:40:00', 'ATIVO'),
(3, 'Rafael Bittencourt Souza', '29876543012', '01247896305', 'B',  '2030-02-27', '1985-12-14', '61996633104', 'rafael.souza@email.com',    'QNA 22 Casa 9',                'Taguatinga',   'DF', '72110220', '2026-02-27 09:05:00', 'ATIVO'),
(4, 'Camila Duarte Ferreira',   '38217459086', '09632587410', 'B',  '2029-09-30', '1995-05-30', '61987710455', 'camila.ferreira@email.com', 'Rua 12 Norte Lote 4 Ap 801',   'Aguas Claras', 'DF', '71905000', '2026-03-11 16:22:00', 'ATIVO'),
(5, 'Thiago Moreira Alencar',   '46053917822', '05478912360', 'AB', '2031-06-15', '1990-10-03', '61993328017', NULL,                        'CLN 410 Bloco B Ap 112',       'Brasilia',     'DF', '70866520', '2026-05-08 11:48:00', 'ATIVO'),
(6, 'Juliana Rezende Castro',   '51728394607', '02896547130', 'B',  '2028-08-21', '1998-01-26', '61995540982', 'juliana.castro@email.com',  'Rua das Figueiras Lote 22',    'Aguas Claras', 'DF', '71936250', '2026-06-30 08:30:00', 'ATIVO');

INSERT INTO veiculo (id_veiculo, placa, chassi, marca, modelo, ano_fabricacao, ano_modelo, cor, combustivel, km_atual, status, id_categoria, id_filial) VALUES
(1, 'JKL5C21', '9BWZZZ377VT004251', 'Toyota',    'Corolla Cross', 2024, 2025, 'Prata',    'FLEX',     19250, 'LOCADO',     3, 1),
(2, 'RTB7D45', '9BD19640TL2140233', 'Fiat',      'Argo',          2023, 2024, 'Branco',   'FLEX',     13400, 'DISPONIVEL', 1, 1),
(3, 'MQP2E88', '9BHBG51CAPP721904', 'Hyundai',   'HB20',          2024, 2024, 'Preto',    'FLEX',     15700, 'MANUTENCAO', 1, 2),
(4, 'XCV9F03', '98JMCA5H7PK118276', 'Jeep',      'Compass',       2023, 2024, 'Cinza',    'DIESEL',   23600, 'LOCADO',     3, 2),
(5, 'BND4G12', '9BGKS69X0RG205417', 'Chevrolet', 'Onix Plus',     2024, 2025, 'Prata',    'FLEX',      9980, 'DISPONIVEL', 2, 3),
(6, 'LWS8H27', 'WBA5R71090FH88251', 'BMW',       '320i',          2024, 2025, 'Preto',    'GASOLINA',  5900, 'DISPONIVEL', 4, 5),
(7, 'PDF3J56', '9BD26512MN3067148', 'Fiat',      'Fiorino',       2022, 2023, 'Branco',   'FLEX',     32200, 'DISPONIVEL', 5, 4),
(8, 'GHT6K91', '93YRBB00274108392', 'Renault',   'Kwid',          2023, 2023, 'Vermelho', 'FLEX',     27500, 'DISPONIVEL', 1, 4);

INSERT INTO documento_veiculo (id_veiculo, renavam, num_crlv, ano_licenciamento, venc_licenciamento, apolice_seguro, seguradora) VALUES
(1, '00987654321', 'CRLV2026007412', 2026, '2026-12-31', 'AP-2026-55412', 'Porto Seguro'),
(2, '01122334455', 'CRLV2026007413', 2026, '2026-12-31', 'AP-2026-55413', 'Porto Seguro'),
(3, '02233445566', 'CRLV2026007414', 2026, '2026-11-30', 'AP-2026-55414', 'Allianz'),
(4, '03344556677', 'CRLV2026007415', 2026, '2026-12-31', 'AP-2026-55415', 'Allianz'),
(5, '04455667788', 'CRLV2026007416', 2026, '2026-10-31', 'AP-2026-55416', 'Bradesco Seguros'),
(6, '05566778899', 'CRLV2026007417', 2026, '2026-12-31', 'AP-2026-55417', 'Porto Seguro'),
(7, '06677889900', 'CRLV2026007418', 2026, '2026-09-30', NULL,             NULL),
(8, '07788990011', 'CRLV2026007419', 2026, '2026-12-31', 'AP-2026-55419', 'Bradesco Seguros');

-- Locacoes 1 a 10 finalizadas, 11 e 12 em aberto.
-- As locacoes 2, 5 e 9 foram devolvidas depois da data prevista.
-- As locacoes 2, 6, 9 e 12 tem filial de devolucao diferente da de retirada.
INSERT INTO locacao (id_locacao, id_cliente, id_veiculo, id_filial_retirada, id_filial_devolucao, data_retirada, data_prevista_devolucao, data_real_devolucao, valor_diaria_contratada, km_retirada, km_devolucao, valor_total, status) VALUES
( 1, 1, 2, 1, 1, '2026-06-03 09:00:00', '2026-06-08 09:00:00', '2026-06-08 08:40:00', 129.90, 12000, 12480,  649.50, 'FINALIZADA'),
( 2, 2, 1, 1, 3, '2026-06-20 10:00:00', '2026-06-25 10:00:00', '2026-06-27 14:20:00', 289.90, 18000, 19250, 2319.20, 'FINALIZADA'),
( 3, 3, 5, 3, 3, '2026-07-02 08:00:00', '2026-07-05 08:00:00', '2026-07-05 07:30:00', 189.90,  9000,  9410,  569.70, 'FINALIZADA'),
( 4, 1, 4, 2, 2, '2026-07-10 09:00:00', '2026-07-17 09:00:00', '2026-07-17 08:50:00', 289.90, 22000, 23600, 2029.30, 'FINALIZADA'),
( 5, 4, 6, 5, 5, '2026-07-22 15:00:00', '2026-07-25 15:00:00', '2026-07-28 11:00:00', 549.90,  5000,  5900, 3299.40, 'FINALIZADA'),
( 6, 2, 3, 2, 1, '2026-08-05 10:00:00', '2026-08-10 10:00:00', '2026-08-10 09:15:00', 129.90, 15000, 15700,  649.50, 'FINALIZADA'),
( 7, 1, 7, 4, 4, '2026-08-12 08:00:00', '2026-08-19 08:00:00', '2026-08-19 07:40:00', 219.90, 31000, 32200, 1539.30, 'FINALIZADA'),
( 8, 5, 8, 4, 4, '2026-08-20 14:00:00', '2026-08-24 14:00:00', '2026-08-24 13:20:00', 129.90, 27000, 27500,  519.60, 'FINALIZADA'),
( 9, 2, 2, 1, 2, '2026-08-28 09:00:00', '2026-09-02 09:00:00', '2026-09-04 16:00:00', 129.90, 12480, 13400, 1039.20, 'FINALIZADA'),
(10, 3, 5, 3, 3, '2026-09-05 08:00:00', '2026-09-09 08:00:00', '2026-09-09 07:50:00', 189.90,  9410,  9980,  759.60, 'FINALIZADA'),
(11, 1, 1, 1, 3, '2026-09-12 09:00:00', '2026-09-19 09:00:00', NULL,                  289.90, 19250, NULL,     NULL, 'ABERTA'),
(12, 6, 4, 2, 5, '2026-09-14 10:00:00', '2026-09-21 10:00:00', NULL,                  289.90, 23600, NULL,     NULL, 'ABERTA');

-- A manutencao 7 esta em aberto, o que justifica o status MANUTENCAO do veiculo 3.
INSERT INTO manutencao (id_manutencao, id_veiculo, tipo, descricao, data_entrada, data_saida, km_manutencao, custo, fornecedor) VALUES
(1, 2, 'PREVENTIVA', 'Troca de oleo, filtro de oleo e filtro de ar',      '2026-06-10', '2026-06-11', 12480,  640.00, 'Concessionaria Sul'),
(2, 2, 'CORRETIVA',  'Substituicao das pastilhas de freio dianteiras',    '2026-09-05', '2026-09-06', 13400,  890.00, 'Auto Center Guara'),
(3, 1, 'REVISAO',    'Revisao programada de 20 mil quilometros',          '2026-06-29', '2026-07-01', 19250, 1480.00, 'Concessionaria Toyota Norte'),
(4, 5, 'PREVENTIVA', 'Alinhamento, balanceamento e rodizio de pneus',     '2026-07-08', '2026-07-08',  9410,  320.00, 'Pneus Taguatinga'),
(5, 5, 'CORRETIVA',  'Reparo no compressor do ar-condicionado',           '2026-09-10', '2026-09-12',  9980, 1250.00, 'Auto Center Guara'),
(6, 6, 'REVISAO',    'Revisao anual de garantia de fabrica',              '2026-07-30', '2026-08-02',  5900, 2890.00, 'Concessionaria BMW Sul'),
(7, 3, 'CORRETIVA',  'Troca de bateria e do alternador',                  '2026-09-15', NULL,         15700, 1720.00, 'Auto Center Guara');

-- ---------------------------------------------------------------------
-- 2. CONSULTAS OBRIGATORIAS
-- ---------------------------------------------------------------------

-- Consulta 1: locacoes em aberto, ou seja, sem data real de devolucao preenchida.
SELECT l.id_locacao,
       c.nome                                AS cliente,
       v.placa,
       CONCAT(v.marca, ' ', v.modelo)        AS veiculo,
       fr.nome                               AS filial_retirada,
       fd.nome                               AS filial_devolucao_prevista,
       l.data_retirada,
       l.data_prevista_devolucao
FROM locacao l
JOIN cliente c  ON c.id_cliente = l.id_cliente
JOIN veiculo v  ON v.id_veiculo = l.id_veiculo
JOIN filial  fr ON fr.id_filial = l.id_filial_retirada
JOIN filial  fd ON fd.id_filial = l.id_filial_devolucao
WHERE l.data_real_devolucao IS NULL
ORDER BY l.data_prevista_devolucao;

-- Consulta 2: veiculos disponiveis agrupados por categoria.
-- O LEFT JOIN mantem na saida as categorias que estao sem veiculo disponivel.
SELECT cat.nome                      AS categoria,
       cat.valor_diaria,
       COUNT(v.id_veiculo)           AS veiculos_disponiveis,
       GROUP_CONCAT(CONCAT(v.marca, ' ', v.modelo, ' (', v.placa, ')')
                    ORDER BY v.placa SEPARATOR ' | ') AS frota_disponivel
FROM categoria cat
LEFT JOIN veiculo v ON v.id_categoria = cat.id_categoria
                   AND v.status = 'DISPONIVEL'
GROUP BY cat.id_categoria, cat.nome, cat.valor_diaria
ORDER BY veiculos_disponiveis DESC, cat.nome;

-- Consulta 3: cliente que mais realizou locacoes.
-- Sem o LIMIT a consulta devolve o ranking completo dos clientes.
SELECT c.nome                 AS cliente,
       c.cpf,
       COUNT(l.id_locacao)    AS total_locacoes
FROM cliente c
JOIN locacao l ON l.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.cpf
ORDER BY total_locacoes DESC, c.nome
LIMIT 1;

-- Consulta 4: faturamento total por filial, considerando a filial de retirada
-- e apenas os contratos ja encerrados.
SELECT f.nome                  AS filial,
       f.cidade,
       COUNT(l.id_locacao)     AS locacoes_finalizadas,
       SUM(l.valor_total)      AS faturamento_total
FROM filial f
JOIN locacao l ON l.id_filial_retirada = f.id_filial
WHERE l.status = 'FINALIZADA'
GROUP BY f.id_filial, f.nome, f.cidade
ORDER BY faturamento_total DESC;

-- Consulta 5: locacoes devolvidas depois da data prevista.
SELECT l.id_locacao,
       c.nome                        AS cliente,
       v.placa,
       l.data_prevista_devolucao,
       l.data_real_devolucao,
       DATEDIFF(l.data_real_devolucao, l.data_prevista_devolucao) AS dias_de_atraso
FROM locacao l
JOIN cliente c ON c.id_cliente = l.id_cliente
JOIN veiculo v ON v.id_veiculo = l.id_veiculo
WHERE l.data_real_devolucao > l.data_prevista_devolucao
ORDER BY dias_de_atraso DESC, l.id_locacao;

-- Consulta 6 (opcional no enunciado): custo total de manutencao por veiculo.
SELECT v.placa,
       CONCAT(v.marca, ' ', v.modelo)   AS veiculo,
       COUNT(m.id_manutencao)           AS qtd_manutencoes,
       SUM(m.custo)                     AS custo_total,
       ROUND(AVG(m.custo), 2)           AS custo_medio
FROM veiculo v
JOIN manutencao m ON m.id_veiculo = v.id_veiculo
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo
ORDER BY custo_total DESC;

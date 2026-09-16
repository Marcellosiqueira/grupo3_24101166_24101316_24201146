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
    CONSTRAINT uk_cliente_cpf UNIQUE (cpf),
    CONSTRAINT uk_cliente_num_cnh UNIQUE (num_cnh),
    CONSTRAINT uk_cliente_email UNIQUE (email),
    CONSTRAINT chk_cliente_cat_cnh CHECK (cat_cnh IN ('A', 'B', 'AB', 'C', 'D', 'E')),
    CONSTRAINT chk_cliente_status CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO'))
);

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
);

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
);

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
    CONSTRAINT uk_veiculo_placa UNIQUE (placa),
    CONSTRAINT uk_veiculo_chassi UNIQUE (chassi),
    CONSTRAINT fk_veiculo_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_veiculo_filial FOREIGN KEY (id_filial) REFERENCES filial (id_filial) ON DELETE RESTRICT,
    CONSTRAINT chk_veiculo_ano_fabricacao CHECK (ano_fabricacao >= 1990),
    CONSTRAINT chk_veiculo_ano_modelo CHECK (ano_modelo >= ano_fabricacao),
    CONSTRAINT chk_veiculo_combustivel CHECK (combustivel IN ('FLEX', 'GASOLINA', 'DIESEL', 'ELETRICO', 'HIBRIDO')),
    CONSTRAINT chk_veiculo_km_atual CHECK (km_atual >= 0),
    CONSTRAINT chk_veiculo_status CHECK (status IN ('DISPONIVEL', 'LOCADO', 'MANUTENCAO', 'INATIVO'))
);

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
);

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
);

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
    CONSTRAINT fk_manutencao_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculo (id_veiculo) ON DELETE RESTRICT,
    CONSTRAINT chk_manutencao_tipo CHECK (tipo IN ('PREVENTIVA', 'CORRETIVA', 'REVISAO')),
    CONSTRAINT chk_manutencao_datas CHECK (data_saida IS NULL OR data_saida >= data_entrada),
    CONSTRAINT chk_manutencao_km CHECK (km_manutencao >= 0),
    CONSTRAINT chk_manutencao_custo CHECK (custo >= 0)
);
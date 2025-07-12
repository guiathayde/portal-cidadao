-- ================================================================
-- 1. Criação do Banco de Dados e Implementação de Restrições
-- ================================================================

-- Tabela: Cidadão
-- PK: cpf (Cadastro Único), NOT NULL, UNIQUE
-- Atributos básicos e restrições de formato
CREATE TABLE Cidadao (
    cpf            CHAR(11)     PRIMARY KEY,
    senha          VARCHAR(60)  NOT NULL,
    nome           VARCHAR(100) NOT NULL,
    data_nascimento DATE         NOT NULL CHECK (data_nascimento <= CURRENT_DATE),
    -- campos opcionais
    CONSTRAINT cpf_numerico CHECK (cpf ~ '^[0-9]{11}$')
);

-- Tabelas de contato (1:N)
CREATE TABLE Telefone (
    id       SERIAL       PRIMARY KEY,
    cpf_fk   CHAR(11)     NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    telefone VARCHAR(20)  NOT NULL,
    UNIQUE(telefone)
);

CREATE TABLE Email (
    id       SERIAL      PRIMARY KEY,
    cpf_fk   CHAR(11)    NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    email    VARCHAR(150) NOT NULL,
    UNIQUE(email)
);

-- Tabela: Ficha Médica (1:1)
CREATE TABLE Ficha_Medica (
    cpf_fk                   CHAR(11) PRIMARY KEY REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    peso                     NUMERIC(5,2)   NOT NULL CHECK (peso > 0),
    altura                   NUMERIC(4,2)   NOT NULL CHECK (altura > 0),
    tipo_sanguineo           VARCHAR(3)     NOT NULL,
    carteira_vacinacao       VARCHAR(50),
    cartao_nacional_saude    VARCHAR(50),
    patologias               TEXT
);

-- Tabela: Dependente (1:N)
CREATE TABLE Dependente (
    id                SERIAL      PRIMARY KEY,
    cpf_cidadao       CHAR(11)    NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    nome              VARCHAR(100) NOT NULL,
    grau_parentesco   VARCHAR(50)  NOT NULL
);

-- Tabela: Uso de Serviços Públicos (1:N)
CREATE TABLE Uso_Servicos (
    id           SERIAL     PRIMARY KEY,
    cpf_cidadao  CHAR(11)   NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    servico      VARCHAR(100) NOT NULL,
    data_inicio  DATE        NOT NULL,
    data_termino DATE,
    custo        NUMERIC(10,2) CHECK (custo >= 0)
);

-- Tabela: Educação (1:N)
CREATE TABLE Educacao (
    id            SERIAL      PRIMARY KEY,
    cpf_cidadao   CHAR(11)     NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    instituicao   VARCHAR(150) NOT NULL,
    nivel         VARCHAR(50)  NOT NULL,
    status        VARCHAR(50)  NOT NULL,
    matricula     VARCHAR(50)  NOT NULL UNIQUE
);

-- Tabela: Benefícios Sociais (1:N)
CREATE TABLE Beneficios_Sociais (
    registro      SERIAL      PRIMARY KEY,
    cpf_cidadao   CHAR(11)    NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    beneficio     VARCHAR(100) NOT NULL,
    data_inicio   DATE         NOT NULL,
    data_termino  DATE,
    status        VARCHAR(20)  NOT NULL,
    CHECK (data_termino IS NULL OR data_termino >= data_inicio)
);

-- Tabela: Imóvel (1:N)
CREATE TABLE Imovel (
    id               SERIAL     PRIMARY KEY,
    cpf_cidadao      CHAR(11)   NOT NULL REFERENCES Cidadao(cpf) ON DELETE SET NULL,
    matricula        VARCHAR(50) NOT NULL UNIQUE,
    proprietario     VARCHAR(150) NOT NULL,
    tipo_propriedade VARCHAR(50)  NOT NULL,
    endereco         VARCHAR(200) NOT NULL,
    valor            NUMERIC(15,2) CHECK (valor >= 0),
    area             NUMERIC(10,2) CHECK (area > 0)
);

-- Tabela: Residência (1:N)
CREATE TABLE Residencia (
    id            SERIAL    PRIMARY KEY,
    cpf_cidadao   CHAR(11)  NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    cep           CHAR(8)   NOT NULL,
    logradouro    VARCHAR(200) NOT NULL,
    numero        VARCHAR(20)  NOT NULL,
    bairro        VARCHAR(100) NOT NULL,
    complemento   VARCHAR(100)
);

-- Tabela: Ocupação (1:N)
CREATE TABLE Ocupacao (
    id            SERIAL     PRIMARY KEY,
    cpf_cidadao   CHAR(11)    NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    profissao     VARCHAR(100) NOT NULL,
    data_inicio   DATE         NOT NULL,
    data_final    DATE,
    numero_pis    VARCHAR(20)  NOT NULL UNIQUE,
    status        VARCHAR(20)  NOT NULL,
    CHECK (data_final IS NULL OR data_final >= data_inicio)
);

-- Tabela: Veículos (1:N)
CREATE TABLE Veiculos (
    id              SERIAL     PRIMARY KEY,
    cpf_cidadao     CHAR(11)   NOT NULL REFERENCES Cidadao(cpf) ON DELETE CASCADE,
    placa           VARCHAR(10) NOT NULL UNIQUE,
    modelo          VARCHAR(100) NOT NULL,
    ano             INTEGER     NOT NULL CHECK (ano >= 1900 AND ano <= extract(year from CURRENT_DATE)),
    cor             VARCHAR(30),
    estado_de_uso   VARCHAR(30)
);

-- ================================================================
-- 2. Criação de Índices
-- ================================================================

-- Índices em chaves estrangeiras para acelerar junções
CREATE INDEX idx_tel_cpf      ON Telefone(cpf_fk);
CREATE INDEX idx_email_cpf    ON Email(cpf_fk);
CREATE INDEX idx_dep_cpf      ON Dependente(cpf_cidadao);
CREATE INDEX idx_uso_cpf      ON Uso_Servicos(cpf_cidadao);
CREATE INDEX idx_edu_cpf      ON Educacao(cpf_cidadao);
CREATE INDEX idx_benf_cpf     ON Beneficios_Sociais(cpf_cidadao);
CREATE INDEX idx_imovel_cpf   ON Imovel(cpf_cidadao);
CREATE INDEX idx_resid_cpf    ON Residencia(cpf_cidadao);
CREATE INDEX idx_ocup_cpf     ON Ocupacao(cpf_cidadao);
CREATE INDEX idx_veic_cpf     ON Veiculos(cpf_cidadao);

-- Índices adicionais
CREATE INDEX idx_pis         ON Ocupacao(numero_pis);
CREATE INDEX idx_placa       ON Veiculos(placa);

-- ================================================================
-- 3. Inserção de Dados de Teste
--    (20 registros em cada tabela usando generate_series)
-- ================================================================

-- 3.1 Cidadãos
INSERT INTO Cidadao(cpf, senha, nome, data_nascimento)
SELECT
    LPAD((10000000000 + gs)::TEXT, 11, '0') AS cpf,
    'Senha@' || gs,
    'Cidadao ' || gs,
    (CURRENT_DATE - (20 + gs) * INTERVAL '1 year')::DATE
FROM generate_series(1,20) AS gs;

-- 3.2 Telefones e Emails
INSERT INTO Telefone(cpf_fk, telefone)
SELECT cpf, '+55 11 9' || LPAD((1000000 + gs)::TEXT, 7, '0')
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

INSERT INTO Email(cpf_fk, email)
SELECT cpf, 'user' || gs || '@exemplo.com'
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.3 Ficha Médica
INSERT INTO Ficha_Medica(cpf_fk, peso, altura, tipo_sanguineo)
SELECT cpf, 60 + gs % 20, 1.60 + (gs % 30) * 0.01, 'O+'
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.4 Dependentes
INSERT INTO Dependente(cpf_cidadao, nome, grau_parentesco)
SELECT cpf, 'Dependente '||gs, 'Filho(a)'
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.5 Uso de Serviços
INSERT INTO Uso_Servicos(cpf_cidadao, servico, data_inicio, custo)
SELECT cpf, 'Serviço '||gs, CURRENT_DATE - gs, gs * 10.50
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.6 Educação
INSERT INTO Educacao(cpf_cidadao, instituicao, nivel, status, matricula)
SELECT cpf, 'Uni '||gs, 'Graduação', 'Ativo', 'MTR'||gs
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.7 Benefícios Sociais
INSERT INTO Beneficios_Sociais(cpf_cidadao, beneficio, data_inicio, status)
SELECT cpf, 'Bolsa '||gs, CURRENT_DATE - (gs * 30), 'Ativo'
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.8 Imóveis
INSERT INTO Imovel(cpf_cidadao, matricula, proprietario, tipo_propriedade, endereco, valor, area)
SELECT cpf, 'MAT'||gs, 'Proprietário '||gs, 'Residencial', 'Rua Exemplo '||gs, gs * 100000.00, gs * 50.0
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.9 Residências
INSERT INTO Residencia(cpf_cidadao, cep, logradouro, numero, bairro)
SELECT cpf, LPAD((10000000+gs)::TEXT,8,'0'), 'Rua '||gs, gs::TEXT, 'Bairro '||gs
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.10 Ocupações
INSERT INTO Ocupacao(cpf_cidadao, profissao, data_inicio, status, numero_pis)
SELECT cpf, 'Profissão '||gs, CURRENT_DATE - (gs * 365), 'Ativo', 'PIS'||LPAD(gs::TEXT,8,'0')
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- 3.11 Veículos
INSERT INTO Veiculos(cpf_cidadao, placa, modelo, ano)
SELECT cpf, 'AAA'||LPAD(gs::TEXT,4,'0'), 'Modelo '||gs, 2000 + (gs % 20)
FROM Cidadao, generate_series(1,20) AS gs
WHERE Cidadao.cpf LIKE LPAD((10000000000 + gs)::TEXT,11,'0');

-- ================================================================
-- 4. Procedures, Functions e Triggers
-- ================================================================

-- Function para calcular idade
CREATE OR REPLACE FUNCTION calcular_idade(data_nascimento DATE)
RETURNS INT LANGUAGE sql IMMUTABLE AS $$
    SELECT DATE_PART('year', AGE(data_nascimento))::INT;
$$;

-- Trigger: atualiza log de inserções em Cidadao
CREATE TABLE Log_Cidadao (
    id       SERIAL PRIMARY KEY,
    cpf      CHAR(11),
    operacao VARCHAR(10),
    ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION trg_log_cidadao()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Log_Cidadao(cpf, operacao)
    VALUES (NEW.cpf, TG_OP);
    RETURN NEW;
END;
$$;

CREATE TRIGGER log_insert_cidadao
AFTER INSERT ON Cidadao
FOR EACH ROW EXECUTE FUNCTION trg_log_cidadao();

-- Trigger de verificação de término de benefício
CREATE OR REPLACE FUNCTION trg_check_beneficios()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.data_termino IS NOT NULL AND NEW.data_termino < NEW.data_inicio THEN
        RAISE EXCEPTION 'Data de término (%) não pode ser anterior à data de início (%)', NEW.data_termino, NEW.data_inicio;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER check_beneficios
BEFORE INSERT OR UPDATE ON Beneficios_Sociais
FOR EACH ROW EXECUTE FUNCTION trg_check_beneficios();
-- Trigger: Proteção de Dados

-- Função que verifica se um cidadão possui benefícios ativos antes de ser excluído.
CREATE OR REPLACE FUNCTION trg_verificar_exclusao_cidadao()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN


   IF EXISTS (
       SELECT 1
       FROM Beneficios_Sociais
       WHERE cpf_cidadao = OLD.cpf AND status = 'Ativo'
   ) THEN
       -- Se encontrar um benefício ativo, a operação de DELETE é cancelada
       RAISE EXCEPTION 'Não é possível excluir o cidadão com CPF % pois ele possui benefícios sociais ativos.', OLD.cpf;
   END IF;
   RETURN OLD;
END;
$$;
-- Cria o gatilho que será acionado ANTES de uma operação de DELETE na tabela Cidadao.
CREATE TRIGGER protecao_exclusao_cidadao_com_beneficio
BEFORE DELETE ON Cidadao
FOR EACH ROW EXECUTE FUNCTION trg_verificar_exclusao_cidadao();

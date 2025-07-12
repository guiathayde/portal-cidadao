-- Limpar dados existentes (se houver)
DELETE FROM Veiculos;
DELETE FROM Ocupacao;
DELETE FROM Residencia;
DELETE FROM Imovel;
DELETE FROM Beneficios_Sociais;
DELETE FROM Educacao;
DELETE FROM Uso_Servicos;
DELETE FROM Dependente;
DELETE FROM Ficha_Medica;
DELETE FROM Email;
DELETE FROM Telefone;
DELETE FROM Cidadao;
-- Resetar sequências
ALTER SEQUENCE telefone_id_seq RESTART WITH 1;
ALTER SEQUENCE email_id_seq RESTART WITH 1;
ALTER SEQUENCE dependente_id_seq RESTART WITH 1;
ALTER SEQUENCE uso_servicos_id_seq RESTART WITH 1;
ALTER SEQUENCE educacao_id_seq RESTART WITH 1;
ALTER SEQUENCE beneficios_sociais_registro_seq RESTART WITH 1;
ALTER SEQUENCE imovel_id_seq RESTART WITH 1;
ALTER SEQUENCE residencia_id_seq RESTART WITH 1;
ALTER SEQUENCE ocupacao_id_seq RESTART WITH 1;
ALTER SEQUENCE veiculos_id_seq RESTART WITH 1;
-- ================================================================
-- 1. CIDADÃOS - 100 registros
-- ================================================================
INSERT INTO Cidadao(cpf, senha, nome, data_nascimento)
SELECT LPAD((10000000000 + gs)::TEXT, 11, '0') AS cpf,
  '$2b$10$' || MD5(random()::TEXT) AS senha,
  -- Hash simulado
  CASE
    WHEN gs % 10 = 0 THEN 'Ana ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 1 THEN 'João ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 2 THEN 'Maria ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 3 THEN 'Pedro ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 4 THEN 'Carlos ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 5 THEN 'Mariana ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 6 THEN 'Lucas ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 7 THEN 'Fernanda ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    WHEN gs % 10 = 8 THEN 'Rafael ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
    ELSE 'Juliana ' || CASE
      gs % 5
      WHEN 0 THEN 'Silva'
      WHEN 1 THEN 'Santos'
      WHEN 2 THEN 'Oliveira'
      WHEN 3 THEN 'Souza'
      ELSE 'Lima'
    END
  END AS nome,
  (
    CURRENT_DATE - (18 + (gs % 50)) * INTERVAL '1 year' - (gs % 365) * INTERVAL '1 day'
  )::DATE AS data_nascimento
FROM generate_series(1, 100) AS gs;
-- ================================================================
-- 2. TELEFONES - 250 registros (alguns cidadãos têm múltiplos)
-- ================================================================
INSERT INTO Telefone(cpf_fk, telefone)
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_fk,
  CASE
    WHEN gs % 3 = 0 THEN '+55 11 9' || LPAD((10000000 + gs)::TEXT, 8, '0')
    WHEN gs % 3 = 1 THEN '+55 21 9' || LPAD((20000000 + gs)::TEXT, 8, '0')
    ELSE '+55 47 9' || LPAD((30000000 + gs)::TEXT, 8, '0')
  END AS telefone
FROM generate_series(1, 250) AS gs;
-- ================================================================
-- 3. EMAILS - 180 registros
-- ================================================================
INSERT INTO Email(cpf_fk, email)
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_fk,
  CASE
    WHEN gs % 5 = 0 THEN 'user' || gs || '@gmail.com'
    WHEN gs % 5 = 1 THEN 'pessoa' || gs || '@hotmail.com'
    WHEN gs % 5 = 2 THEN 'cliente' || gs || '@yahoo.com'
    WHEN gs % 5 = 3 THEN 'cidadao' || gs || '@outlook.com'
    ELSE 'contato' || gs || '@exemplo.com'
  END AS email
FROM generate_series(1, 180) AS gs;
-- ================================================================
-- 4. FICHA MÉDICA - 100 registros (1:1 com cidadão)
-- ================================================================
INSERT INTO Ficha_Medica(
    cpf_fk,
    peso,
    altura,
    tipo_sanguineo,
    carteira_vacinacao,
    cartao_nacional_saude,
    patologias
  )
SELECT LPAD((10000000000 + gs)::TEXT, 11, '0') AS cpf_fk,
  (50 + (gs % 60) + (gs % 10) * 0.5)::NUMERIC(5, 2) AS peso,
  (1.50 + (gs % 40) * 0.01)::NUMERIC(4, 2) AS altura,
  CASE
    gs % 8
    WHEN 0 THEN 'A+'
    WHEN 1 THEN 'A-'
    WHEN 2 THEN 'B+'
    WHEN 3 THEN 'B-'
    WHEN 4 THEN 'AB+'
    WHEN 5 THEN 'AB-'
    WHEN 6 THEN 'O+'
    ELSE 'O-'
  END AS tipo_sanguineo,
  'CART' || LPAD(gs::TEXT, 6, '0') AS carteira_vacinacao,
  'CNS' || LPAD((gs * 123456)::TEXT, 15, '0') AS cartao_nacional_saude,
  CASE
    WHEN gs % 10 = 0 THEN 'Hipertensão'
    WHEN gs % 10 = 1 THEN 'Diabetes'
    WHEN gs % 10 = 2 THEN 'Asma'
    WHEN gs % 10 = 3 THEN NULL
    ELSE 'Nenhuma patologia conhecida'
  END AS patologias
FROM generate_series(1, 100) AS gs;
-- ================================================================
-- 5. DEPENDENTES - 200 registros
-- ================================================================
INSERT INTO Dependente(cpf_cidadao, nome, grau_parentesco)
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 10
    WHEN 0 THEN 'João ' || CASE
      gs % 3
      WHEN 0 THEN 'Filho'
      WHEN 1 THEN 'Junior'
      ELSE 'Neto'
    END
    WHEN 1 THEN 'Maria ' || CASE
      gs % 3
      WHEN 0 THEN 'Filha'
      WHEN 1 THEN 'Clara'
      ELSE 'Eduarda'
    END
    WHEN 2 THEN 'Pedro ' || CASE
      gs % 3
      WHEN 0 THEN 'Filho'
      WHEN 1 THEN 'Junior'
      ELSE 'Neto'
    END
    WHEN 3 THEN 'Ana ' || CASE
      gs % 3
      WHEN 0 THEN 'Filha'
      WHEN 1 THEN 'Paula'
      ELSE 'Beatriz'
    END
    WHEN 4 THEN 'Carlos ' || CASE
      gs % 3
      WHEN 0 THEN 'Filho'
      WHEN 1 THEN 'Junior'
      ELSE 'Neto'
    END
    WHEN 5 THEN 'Fernanda ' || CASE
      gs % 3
      WHEN 0 THEN 'Filha'
      WHEN 1 THEN 'Silva'
      ELSE 'Santos'
    END
    WHEN 6 THEN 'Lucas ' || CASE
      gs % 3
      WHEN 0 THEN 'Filho'
      WHEN 1 THEN 'Junior'
      ELSE 'Neto'
    END
    WHEN 7 THEN 'Juliana ' || CASE
      gs % 3
      WHEN 0 THEN 'Filha'
      WHEN 1 THEN 'Silva'
      ELSE 'Santos'
    END
    WHEN 8 THEN 'Rafael ' || CASE
      gs % 3
      WHEN 0 THEN 'Filho'
      WHEN 1 THEN 'Junior'
      ELSE 'Neto'
    END
    ELSE 'Mariana ' || CASE
      gs % 3
      WHEN 0 THEN 'Filha'
      WHEN 1 THEN 'Silva'
      ELSE 'Santos'
    END
  END AS nome,
  CASE
    gs % 6
    WHEN 0 THEN 'Filho(a)'
    WHEN 1 THEN 'Cônjuge'
    WHEN 2 THEN 'Pai/Mãe'
    WHEN 3 THEN 'Irmão(ã)'
    WHEN 4 THEN 'Neto(a)'
    ELSE 'Outro'
  END AS grau_parentesco
FROM generate_series(1, 200) AS gs;
-- ================================================================
-- 6. USO DE SERVIÇOS - 300 registros
-- ================================================================
INSERT INTO Uso_Servicos(
    cpf_cidadao,
    servico,
    data_inicio,
    data_termino,
    custo
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 12
    WHEN 0 THEN 'Consulta Médica'
    WHEN 1 THEN 'Serviço de Limpeza Urbana'
    WHEN 2 THEN 'Transporte Público'
    WHEN 3 THEN 'Educação Infantil'
    WHEN 4 THEN 'Saúde Básica'
    WHEN 5 THEN 'Segurança Pública'
    WHEN 6 THEN 'Coleta de Lixo'
    WHEN 7 THEN 'Iluminação Pública'
    WHEN 8 THEN 'Pavimentação'
    WHEN 9 THEN 'Cultura e Lazer'
    WHEN 10 THEN 'Esporte'
    ELSE 'Assistência Social'
  END AS servico,
  (CURRENT_DATE - (gs % 365) * INTERVAL '1 day')::DATE AS data_inicio,
  CASE
    WHEN gs % 5 = 0 THEN (CURRENT_DATE - (gs % 100) * INTERVAL '1 day')::DATE
    ELSE NULL
  END AS data_termino,
  (gs % 500 + 10.50)::NUMERIC(10, 2) AS custo
FROM generate_series(1, 300) AS gs;
-- ================================================================
-- 7. EDUCAÇÃO - 150 registros
-- ================================================================
INSERT INTO Educacao(
    cpf_cidadao,
    instituicao,
    nivel,
    STATUS,
    matricula
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 10
    WHEN 0 THEN 'Universidade Federal de São Carlos'
    WHEN 1 THEN 'Escola Estadual Pedro Alvares Cabral'
    WHEN 2 THEN 'Instituto Federal de São Paulo'
    WHEN 3 THEN 'Universidade Estadual Paulista'
    WHEN 4 THEN 'Faculdade de Tecnologia'
    WHEN 5 THEN 'Colégio Técnico Industrial'
    WHEN 6 THEN 'Universidade de São Paulo'
    WHEN 7 THEN 'Escola Municipal João Silva'
    WHEN 8 THEN 'Centro Universitário'
    ELSE 'Escola Técnica Estadual'
  END AS instituicao,
  CASE
    gs % 5
    WHEN 0 THEN 'Ensino Fundamental'
    WHEN 1 THEN 'Ensino Médio'
    WHEN 2 THEN 'Ensino Técnico'
    WHEN 3 THEN 'Graduação'
    ELSE 'Pós-graduação'
  END AS nivel,
  CASE
    gs % 4
    WHEN 0 THEN 'Ativo'
    WHEN 1 THEN 'Concluído'
    WHEN 2 THEN 'Trancado'
    ELSE 'Cancelado'
  END AS STATUS,
  'MAT' || LPAD(gs::TEXT, 8, '0') AS matricula
FROM generate_series(1, 150) AS gs;
-- ================================================================
-- 8. BENEFÍCIOS SOCIAIS - 220 registros
-- ================================================================
INSERT INTO Beneficios_Sociais(
    cpf_cidadao,
    beneficio,
    data_inicio,
    data_termino,
    STATUS
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 8
    WHEN 0 THEN 'Bolsa Família'
    WHEN 1 THEN 'Auxílio Emergencial'
    WHEN 2 THEN 'Benefício de Prestação Continuada'
    WHEN 3 THEN 'Auxílio Brasil'
    WHEN 4 THEN 'Seguro Desemprego'
    WHEN 5 THEN 'Vale Alimentação'
    WHEN 6 THEN 'Auxílio Creche'
    ELSE 'Tarifa Social de Energia'
  END AS beneficio,
  (CURRENT_DATE - (gs % 730) * INTERVAL '1 day')::DATE AS data_inicio,
  CASE
    WHEN gs % 7 = 0 THEN (CURRENT_DATE + (gs % 180) * INTERVAL '1 day')::DATE
    ELSE NULL
  END AS data_termino,
  CASE
    gs % 3
    WHEN 0 THEN 'Ativo'
    WHEN 1 THEN 'Suspenso'
    ELSE 'Cancelado'
  END AS STATUS
FROM generate_series(1, 220) AS gs;
-- ================================================================
-- 9. IMÓVEIS - 120 registros
-- ================================================================
INSERT INTO Imovel(
    cpf_cidadao,
    matricula,
    proprietario,
    tipo_propriedade,
    endereco,
    valor,
    area
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  'MATR' || LPAD(gs::TEXT, 8, '0') AS matricula,
  CASE
    gs % 5
    WHEN 0 THEN 'José Silva Santos'
    WHEN 1 THEN 'Maria Oliveira Lima'
    WHEN 2 THEN 'João Pedro Souza'
    WHEN 3 THEN 'Ana Carolina Silva'
    ELSE 'Carlos Eduardo Santos'
  END AS proprietario,
  CASE
    gs % 4
    WHEN 0 THEN 'Residencial'
    WHEN 1 THEN 'Comercial'
    WHEN 2 THEN 'Industrial'
    ELSE 'Misto'
  END AS tipo_propriedade,
  CASE
    gs % 20
    WHEN 0 THEN 'Rua das Flores, ' || gs
    WHEN 1 THEN 'Avenida Brasil, ' || gs
    WHEN 2 THEN 'Rua São Paulo, ' || gs
    WHEN 3 THEN 'Rua Rio de Janeiro, ' || gs
    WHEN 4 THEN 'Avenida Paulista, ' || gs
    WHEN 5 THEN 'Rua Augusta, ' || gs
    WHEN 6 THEN 'Rua Oscar Freire, ' || gs
    WHEN 7 THEN 'Avenida Faria Lima, ' || gs
    WHEN 8 THEN 'Rua Consolação, ' || gs
    WHEN 9 THEN 'Rua Liberdade, ' || gs
    WHEN 10 THEN 'Avenida Rebouças, ' || gs
    WHEN 11 THEN 'Rua Teodoro Sampaio, ' || gs
    WHEN 12 THEN 'Rua Haddock Lobo, ' || gs
    WHEN 13 THEN 'Avenida Ibirapuera, ' || gs
    WHEN 14 THEN 'Rua Pamplona, ' || gs
    WHEN 15 THEN 'Rua Bela Cintra, ' || gs
    WHEN 16 THEN 'Avenida Angélica, ' || gs
    WHEN 17 THEN 'Rua Estados Unidos, ' || gs
    WHEN 18 THEN 'Rua Alameda Santos, ' || gs
    ELSE 'Rua Brigadeiro Luís Antônio, ' || gs
  END AS endereco,
  (50000 + (gs % 500) * 1000)::NUMERIC(15, 2) AS valor,
  (30 + (gs % 200))::NUMERIC(10, 2) AS area
FROM generate_series(1, 120) AS gs;
-- ================================================================
-- 10. RESIDÊNCIAS - 130 registros
-- ================================================================
INSERT INTO Residencia(
    cpf_cidadao,
    cep,
    logradouro,
    numero,
    bairro,
    complemento
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  LPAD((13560000 + gs)::TEXT, 8, '0') AS cep,
  CASE
    gs % 15
    WHEN 0 THEN 'Rua das Palmeiras'
    WHEN 1 THEN 'Avenida Central'
    WHEN 2 THEN 'Rua dos Trabalhadores'
    WHEN 3 THEN 'Rua São João'
    WHEN 4 THEN 'Avenida Kennedy'
    WHEN 5 THEN 'Rua Presidente Vargas'
    WHEN 6 THEN 'Rua Dom Pedro II'
    WHEN 7 THEN 'Avenida Getúlio Vargas'
    WHEN 8 THEN 'Rua Tiradentes'
    WHEN 9 THEN 'Rua Quinze de Novembro'
    WHEN 10 THEN 'Avenida São Carlos'
    WHEN 11 THEN 'Rua Carlos Botelho'
    WHEN 12 THEN 'Rua Nove de Julho'
    WHEN 13 THEN 'Avenida Integração'
    ELSE 'Rua Voluntários da Pátria'
  END AS logradouro,
  (gs % 2000 + 1)::TEXT AS numero,
  CASE
    gs % 10
    WHEN 0 THEN 'Centro'
    WHEN 1 THEN 'Vila Nery'
    WHEN 2 THEN 'Jardim Paulista'
    WHEN 3 THEN 'Santa Mônica'
    WHEN 4 THEN 'Cidade Jardim'
    WHEN 5 THEN 'Vila Monteiro'
    WHEN 6 THEN 'Parque Arnold Schimidt'
    WHEN 7 THEN 'Jardim Carvalho'
    WHEN 8 THEN 'Vila Prado'
    ELSE 'Cruzeiro do Sul'
  END AS bairro,
  CASE
    WHEN gs % 5 = 0 THEN 'Apartamento ' || (gs % 100 + 1)
    WHEN gs % 5 = 1 THEN 'Casa ' || (gs % 20 + 1)
    WHEN gs % 5 = 2 THEN 'Bloco ' || CHR(65 + (gs % 5))
    ELSE NULL
  END AS complemento
FROM generate_series(1, 130) AS gs;
-- ================================================================
-- 11. OCUPAÇÕES - 140 registros
-- ================================================================
INSERT INTO Ocupacao(
    cpf_cidadao,
    profissao,
    data_inicio,
    data_final,
    numero_pis,
    STATUS
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 20
    WHEN 0 THEN 'Desenvolvedor de Software'
    WHEN 1 THEN 'Professor'
    WHEN 2 THEN 'Médico'
    WHEN 3 THEN 'Enfermeiro'
    WHEN 4 THEN 'Engenheiro'
    WHEN 5 THEN 'Advogado'
    WHEN 6 THEN 'Contador'
    WHEN 7 THEN 'Vendedor'
    WHEN 8 THEN 'Mecânico'
    WHEN 9 THEN 'Eletricista'
    WHEN 10 THEN 'Auxiliar Administrativo'
    WHEN 11 THEN 'Recepcionista'
    WHEN 12 THEN 'Motorista'
    WHEN 13 THEN 'Cozinheiro'
    WHEN 14 THEN 'Garçom'
    WHEN 15 THEN 'Segurança'
    WHEN 16 THEN 'Limpeza'
    WHEN 17 THEN 'Jardineiro'
    WHEN 18 THEN 'Pedreiro'
    ELSE 'Autônomo'
  END AS profissao,
  (CURRENT_DATE - (gs % 1095) * INTERVAL '1 day')::DATE AS data_inicio,
  CASE
    WHEN gs % 6 = 0 THEN (CURRENT_DATE - (gs % 100) * INTERVAL '1 day')::DATE
    ELSE NULL
  END AS data_final,
  'PIS' || LPAD(gs::TEXT, 8, '0') AS numero_pis,
  CASE
    gs % 4
    WHEN 0 THEN 'Ativo'
    WHEN 1 THEN 'Inativo'
    WHEN 2 THEN 'Aposentado'
    ELSE 'Desempregado'
  END AS STATUS
FROM generate_series(1, 140) AS gs;
-- ================================================================
-- 12. VEÍCULOS - 110 registros
-- ================================================================
INSERT INTO Veiculos(
    cpf_cidadao,
    placa,
    modelo,
    ano,
    cor,
    estado_de_uso
  )
SELECT LPAD(
    (10000000000 + ((gs -1) % 100 + 1))::TEXT,
    11,
    '0'
  ) AS cpf_cidadao,
  CASE
    gs % 3
    WHEN 0 THEN CHR(65 + (gs % 26)) || CHR(65 + ((gs + 1) % 26)) || CHR(65 + ((gs + 2) % 26)) || LPAD((gs % 10000)::TEXT, 4, '0')
    WHEN 1 THEN CHR(65 + (gs % 26)) || CHR(65 + ((gs + 1) % 26)) || CHR(65 + ((gs + 2) % 26)) || '-' || LPAD((gs % 10000)::TEXT, 4, '0')
    ELSE CHR(65 + (gs % 26)) || CHR(65 + ((gs + 1) % 26)) || CHR(65 + ((gs + 2) % 26)) || LPAD((gs % 1000)::TEXT, 4, '0')
  END AS placa,
  CASE
    gs % 25
    WHEN 0 THEN 'Honda Civic'
    WHEN 1 THEN 'Toyota Corolla'
    WHEN 2 THEN 'Volkswagen Gol'
    WHEN 3 THEN 'Chevrolet Onix'
    WHEN 4 THEN 'Fiat Palio'
    WHEN 5 THEN 'Ford Ka'
    WHEN 6 THEN 'Hyundai HB20'
    WHEN 7 THEN 'Nissan March'
    WHEN 8 THEN 'Renault Sandero'
    WHEN 9 THEN 'Peugeot 208'
    WHEN 10 THEN 'Citroën C3'
    WHEN 11 THEN 'Kia Picanto'
    WHEN 12 THEN 'Mitsubishi Lancer'
    WHEN 13 THEN 'Suzuki Swift'
    WHEN 14 THEN 'Volkswagen Fox'
    WHEN 15 THEN 'Chevrolet Prisma'
    WHEN 16 THEN 'Fiat Siena'
    WHEN 17 THEN 'Ford Fiesta'
    WHEN 18 THEN 'Honda Fit'
    WHEN 19 THEN 'Toyota Yaris'
    WHEN 20 THEN 'Volkswagen Polo'
    WHEN 21 THEN 'Chevrolet Cruze'
    WHEN 22 THEN 'Fiat Punto'
    WHEN 23 THEN 'Ford Focus'
    ELSE 'Hyundai i30'
  END AS modelo,
  (2000 + (gs % 25))::INTEGER AS ano,
  CASE
    gs % 10
    WHEN 0 THEN 'Branco'
    WHEN 1 THEN 'Preto'
    WHEN 2 THEN 'Prata'
    WHEN 3 THEN 'Vermelho'
    WHEN 4 THEN 'Azul'
    WHEN 5 THEN 'Cinza'
    WHEN 6 THEN 'Amarelo'
    WHEN 7 THEN 'Verde'
    WHEN 8 THEN 'Marrom'
    ELSE 'Bege'
  END AS cor,
  CASE
    gs % 5
    WHEN 0 THEN 'Novo'
    WHEN 1 THEN 'Seminovo'
    WHEN 2 THEN 'Usado'
    WHEN 3 THEN 'Muito Usado'
    ELSE 'Precisa Reparo'
  END AS estado_de_uso
FROM generate_series(1, 110) AS gs;
-- ================================================================
-- CONFIRMAÇÃO DOS DADOS INSERIDOS
-- ================================================================
SELECT 'Dados inseridos com sucesso!' AS STATUS;
-- Verificar contagem de registros
SELECT (
    SELECT COUNT(*)
    FROM Cidadao
  ) AS cidadaos,
  (
    SELECT COUNT(*)
    FROM Telefone
  ) AS telefones,
  (
    SELECT COUNT(*)
    FROM Email
  ) AS emails,
  (
    SELECT COUNT(*)
    FROM Ficha_Medica
  ) AS fichas_medicas,
  (
    SELECT COUNT(*)
    FROM Dependente
  ) AS dependentes,
  (
    SELECT COUNT(*)
    FROM Uso_Servicos
  ) AS uso_servicos,
  (
    SELECT COUNT(*)
    FROM Educacao
  ) AS educacao,
  (
    SELECT COUNT(*)
    FROM Beneficios_Sociais
  ) AS beneficios,
  (
    SELECT COUNT(*)
    FROM Imovel
  ) AS imoveis,
  (
    SELECT COUNT(*)
    FROM Residencia
  ) AS residencias,
  (
    SELECT COUNT(*)
    FROM Ocupacao
  ) AS ocupacoes,
  (
    SELECT COUNT(*)
    FROM Veiculos
  ) AS veiculos;

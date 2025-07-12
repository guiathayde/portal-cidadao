-- ================================================================
-- SQL Queries com Três Entidades e Duas Relações
-- Portal do Cidadão - Projeto PIBD UFSCar
-- ================================================================
-- ================================================================
-- Query 1: Cidadãos com suas Propriedades e Veículos
-- Relacionamentos: Cidadao (1:N) Imovel (1:N) Veiculos
-- Objetivo: Listar cidadãos e seus bens (imóveis e veículos)
-- ================================================================
-- Query 1A: Cidadãos com pelo menos um imóvel e um veículo
SELECT c.cpf,
  c.nome AS nome_cidadao,
  c.data_nascimento,
  i.matricula AS imovel_matricula,
  i.tipo_propriedade,
  i.endereco AS endereco_imovel,
  i.valor AS valor_imovel,
  v.placa,
  v.modelo AS modelo_veiculo,
  v.ano AS ano_veiculo,
  v.cor
FROM Cidadao c
  INNER JOIN Imovel i ON c.cpf = i.cpf_cidadao
  INNER JOIN Veiculos v ON c.cpf = v.cpf_cidadao
ORDER BY c.nome,
  i.valor DESC,
  v.ano DESC;
-- Query 1B: Estatísticas de patrimônio por cidadão
SELECT c.cpf,
  c.nome AS nome_cidadao,
  COUNT(DISTINCT i.id) AS total_imoveis,
  COUNT(DISTINCT v.id) AS total_veiculos,
  COALESCE(SUM(i.valor), 0) AS valor_total_imoveis,
  ROUND(AVG(v.ano), 0) AS ano_medio_veiculos
FROM Cidadao c
  LEFT JOIN Imovel i ON c.cpf = i.cpf_cidadao
  LEFT JOIN Veiculos v ON c.cpf = v.cpf_cidadao
GROUP BY c.cpf,
  c.nome
HAVING COUNT(DISTINCT i.id) > 0
  AND COUNT(DISTINCT v.id) > 0
ORDER BY valor_total_imoveis DESC;
-- ================================================================
-- Query 2: Cidadãos com Educação e Benefícios Sociais
-- Relacionamentos: Cidadao (1:N) Educacao (1:N) Beneficios_Sociais
-- Objetivo: Analisar perfil educacional e social dos cidadãos
-- ================================================================
-- Query 2A: Cidadãos com educação ativa e benefícios sociais
SELECT c.cpf,
  c.nome AS nome_cidadao,
  EXTRACT(
    YEAR
    FROM AGE(c.data_nascimento)
  ) AS idade,
  e.instituicao,
  e.nivel AS nivel_educacao,
  e.status AS status_educacao,
  e.matricula,
  b.beneficio,
  b.data_inicio AS inicio_beneficio,
  b.status AS status_beneficio
FROM Cidadao c
  INNER JOIN Educacao e ON c.cpf = e.cpf_cidadao
  INNER JOIN Beneficios_Sociais b ON c.cpf = b.cpf_cidadao
WHERE e.status = 'Ativo'
  AND b.status = 'Ativo'
ORDER BY c.nome,
  e.nivel,
  b.data_inicio DESC;
-- Query 2B: Análise de benefícios por nível educacional
SELECT e.nivel AS nivel_educacao,
  COUNT(DISTINCT c.cpf) AS total_cidadaos,
  COUNT(DISTINCT b.registro) AS total_beneficios,
  ROUND(
    AVG(
      EXTRACT(
        YEAR
        FROM AGE(c.data_nascimento)
      )
    ),
    1
  ) AS idade_media,
  STRING_AGG(DISTINCT b.beneficio, ', ') AS tipos_beneficios
FROM Cidadao c
  INNER JOIN Educacao e ON c.cpf = e.cpf_cidadao
  INNER JOIN Beneficios_Sociais b ON c.cpf = b.cpf_cidadao
WHERE e.status = 'Ativo'
  AND b.status = 'Ativo'
GROUP BY e.nivel
ORDER BY total_cidadaos DESC;
-- ================================================================
-- Query 3: Cidadãos com Ficha Médica e Dependentes
-- Relacionamentos: Cidadao (1:1) Ficha_Medica (1:N) Dependente
-- Objetivo: Perfil familiar e de saúde dos cidadãos
-- ================================================================
-- Query 3A: Cidadãos com ficha médica e seus dependentes
SELECT c.cpf,
  c.nome AS nome_cidadao,
  EXTRACT(
    YEAR
    FROM AGE(c.data_nascimento)
  ) AS idade_cidadao,
  fm.peso,
  fm.altura,
  fm.tipo_sanguineo,
  fm.cartao_nacional_saude,
  ROUND(fm.peso / (fm.altura * fm.altura), 2) AS imc,
  d.nome AS nome_dependente,
  d.grau_parentesco
FROM Cidadao c
  INNER JOIN Ficha_Medica fm ON c.cpf = fm.cpf_fk
  INNER JOIN Dependente d ON c.cpf = d.cpf_cidadao
ORDER BY c.nome,
  d.grau_parentesco,
  d.nome;
-- Query 3B: Estatísticas de saúde e família
SELECT c.cpf,
  c.nome AS nome_cidadao,
  fm.tipo_sanguineo,
  ROUND(fm.peso / (fm.altura * fm.altura), 2) AS imc,
  CASE
    WHEN fm.peso / (fm.altura * fm.altura) < 18.5 THEN 'Abaixo do peso'
    WHEN fm.peso / (fm.altura * fm.altura) BETWEEN 18.5 AND 24.9 THEN 'Peso normal'
    WHEN fm.peso / (fm.altura * fm.altura) BETWEEN 25 AND 29.9 THEN 'Sobrepeso'
    ELSE 'Obesidade'
  END AS classificacao_imc,
  COUNT(d.id) AS total_dependentes,
  STRING_AGG(DISTINCT d.grau_parentesco, ', ') AS tipos_dependentes
FROM Cidadao c
  INNER JOIN Ficha_Medica fm ON c.cpf = fm.cpf_fk
  INNER JOIN Dependente d ON c.cpf = d.cpf_cidadao
GROUP BY c.cpf,
  c.nome,
  fm.tipo_sanguineo,
  fm.peso,
  fm.altura
ORDER BY total_dependentes DESC,
  imc;
-- ================================================================
-- Queries Adicionais para Análise Combinada
-- ================================================================
-- Query Bonus: Perfil completo do cidadão (múltiplas entidades)
SELECT c.cpf,
  c.nome AS nome_cidadao,
  EXTRACT(
    YEAR
    FROM AGE(c.data_nascimento)
  ) AS idade,
  COUNT(DISTINCT i.id) AS total_imoveis,
  COUNT(DISTINCT v.id) AS total_veiculos,
  COUNT(DISTINCT e.id) AS total_educacao,
  COUNT(DISTINCT b.registro) AS total_beneficios,
  COUNT(DISTINCT d.id) AS total_dependentes,
  CASE
    WHEN fm.cpf_fk IS NOT NULL THEN 'Sim'
    ELSE 'Não'
  END AS possui_ficha_medica
FROM Cidadao c
  LEFT JOIN Imovel i ON c.cpf = i.cpf_cidadao
  LEFT JOIN Veiculos v ON c.cpf = v.cpf_cidadao
  LEFT JOIN Educacao e ON c.cpf = e.cpf_cidadao
  LEFT JOIN Beneficios_Sociais b ON c.cpf = b.cpf_cidadao
  LEFT JOIN Dependente d ON c.cpf = d.cpf_cidadao
  LEFT JOIN Ficha_Medica fm ON c.cpf = fm.cpf_fk
GROUP BY c.cpf,
  c.nome,
  c.data_nascimento,
  fm.cpf_fk
ORDER BY c.nome;
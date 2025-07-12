# Portal do Cidadão - Consultas SQL Complexas

Sistema web desenvolvido para demonstrar consultas SQL complexas envolvendo múltiplas entidades e relacionamentos. Projeto desenvolvido para a disciplina de Projeto Integrado de Banco de Dados (PIBD) da UFSCar.

## 🎯 Objetivo

O sistema apresenta três consultas SQL distintas, cada uma envolvendo três entidades com dois relacionamentos, demonstrando diferentes cenários de uso e análise de dados:

1. **Patrimônio**: Relaciona cidadãos com seus bens (imóveis e veículos)
2. **Educação e Benefícios**: Analisa o perfil educacional e social dos cidadãos
3. **Saúde e Família**: Combina informações médicas e familiares

## 🏗️ Arquitetura do Sistema

### Tecnologias Utilizadas

- **Next.js 15** - Framework React para desenvolvimento web
- **TypeScript** - Tipagem estática para JavaScript
- **PostgreSQL** - Sistema de gerenciamento de banco de dados
- **Tailwind CSS** - Framework CSS para estilização
- **Node.js** - Runtime JavaScript

### Estrutura do Projeto

```
portal-cidadao/
├── db/
│   ├── setup.sql          # Script de criação do banco
│   └── queries.sql        # Consultas SQL documentadas
├── src/
│   ├── app/
│   │   ├── consultas/     # Páginas das consultas
│   │   │   ├── patrimonio/
│   │   │   ├── educacao-beneficios/
│   │   │   └── saude-familia/
│   │   ├── cidadaos/      # Lista de cidadãos
│   │   └── layout.tsx     # Layout da aplicação
│   ├── components/        # Componentes reutilizáveis
│   │   ├── Pagination.tsx      # Componente de paginação
│   │   └── PaginatedTable.tsx  # Tabela com paginação
│   └── lib/
│       ├── pg.ts          # Configuração do PostgreSQL
│       └── pagination.ts  # Utilitários de paginação
└── README.md
```

## 📊 Consultas SQL Implementadas

### 1. Consulta de Patrimônio

**Entidades:** Cidadao, Imovel, Veiculos  
**Relacionamentos:** Cidadao (1:N) Imovel, Cidadao (1:N) Veiculos

#### Query 1A: Cidadãos com Imóveis e Veículos

```sql
SELECT
    c.cpf,
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
ORDER BY c.nome, i.valor DESC, v.ano DESC;
```

#### Query 1B: Estatísticas de Patrimônio

```sql
SELECT
    c.cpf,
    c.nome AS nome_cidadao,
    COUNT(DISTINCT i.id) AS total_imoveis,
    COUNT(DISTINCT v.id) AS total_veiculos,
    COALESCE(SUM(i.valor), 0) AS valor_total_imoveis,
    ROUND(AVG(v.ano), 0) AS ano_medio_veiculos
FROM Cidadao c
LEFT JOIN Imovel i ON c.cpf = i.cpf_cidadao
LEFT JOIN Veiculos v ON c.cpf = v.cpf_cidadao
GROUP BY c.cpf, c.nome
HAVING COUNT(DISTINCT i.id) > 0 AND COUNT(DISTINCT v.id) > 0
ORDER BY valor_total_imoveis DESC;
```

### 2. Consulta de Educação e Benefícios

**Entidades:** Cidadao, Educacao, Beneficios_Sociais  
**Relacionamentos:** Cidadao (1:N) Educacao, Cidadao (1:N) Beneficios_Sociais

#### Query 2A: Cidadãos com Educação Ativa e Benefícios

```sql
SELECT
    c.cpf,
    c.nome AS nome_cidadao,
    EXTRACT(YEAR FROM AGE(c.data_nascimento)) AS idade,
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
WHERE e.status = 'Ativo' AND b.status = 'Ativo'
ORDER BY c.nome, e.nivel, b.data_inicio DESC;
```

#### Query 2B: Análise por Nível Educacional

```sql
SELECT
    e.nivel AS nivel_educacao,
    COUNT(DISTINCT c.cpf) AS total_cidadaos,
    COUNT(DISTINCT b.registro) AS total_beneficios,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(c.data_nascimento))), 1) AS idade_media,
    STRING_AGG(DISTINCT b.beneficio, ', ') AS tipos_beneficios
FROM Cidadao c
INNER JOIN Educacao e ON c.cpf = e.cpf_cidadao
INNER JOIN Beneficios_Sociais b ON c.cpf = b.cpf_cidadao
WHERE e.status = 'Ativo' AND b.status = 'Ativo'
GROUP BY e.nivel
ORDER BY total_cidadaos DESC;
```

### 3. Consulta de Saúde e Família

**Entidades:** Cidadao, Ficha_Medica, Dependente  
**Relacionamentos:** Cidadao (1:1) Ficha_Medica, Cidadao (1:N) Dependente

#### Query 3A: Cidadãos com Ficha Médica e Dependentes

```sql
SELECT
    c.cpf,
    c.nome AS nome_cidadao,
    EXTRACT(YEAR FROM AGE(c.data_nascimento)) AS idade_cidadao,
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
ORDER BY c.nome, d.grau_parentesco, d.nome;
```

#### Query 3B: Estatísticas de Saúde e Família

```sql
SELECT
    c.cpf,
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
GROUP BY c.cpf, c.nome, fm.tipo_sanguineo, fm.peso, fm.altura
ORDER BY total_dependentes DESC, imc;
```

## 🚀 Como Executar

### Pré-requisitos

- Node.js 18+ instalado
- PostgreSQL 12+ instalado e configurado
- Git para clonar o repositório

### Configuração do Banco de Dados

1. Execute o script `db/setup.sql` no PostgreSQL:

```bash
psql -U postgres -d postgres -f db/setup.sql
```

2. Configure as credenciais do banco em `src/lib/pg.ts`:

```typescript
export const poolConfig: PoolConfig = {
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'sua_senha',
  port: 5432,
};
```

### Executando a Aplicação

1. Clone o repositório:

```bash
git clone <url-do-repositorio>
cd portal-cidadao
```

2. Instale as dependências:

```bash
npm install
```

3. Execute em modo de desenvolvimento:

```bash
npm run dev
```

4. Acesse no navegador:

```
http://localhost:3000
```

## 📋 Funcionalidades

### Interface Web

- **Página Principal**: Navegação entre as diferentes consultas
- **Consulta de Patrimônio**: Visualização de bens dos cidadãos
- **Consulta de Educação e Benefícios**: Análise do perfil educacional e social
- **Consulta de Saúde e Família**: Informações médicas e familiares
- **Paginação Avançada**: Navegação eficiente através de grandes volumes de dados
- **Design Responsivo**: Adaptável a diferentes tamanhos de tela

### Características Técnicas

- **Consultas SQL Complexas**: Envolvendo múltiplas JOINs e agregações
- **Tipagem TypeScript**: Interface tipada para os dados
- **Tratamento de Erros**: Exibição de erros de conexão ou consulta
- **Documentação Inline**: Explicação das consultas nas páginas
- **Performance**: Consultas paralelas para melhor desempenho
- **Paginação Inteligente**: Componente reutilizável com navegação otimizada

## 🔧 Componentes de Paginação

### PaginatedTable Component

Componente reutilizável que oferece:

- **Navegação por páginas**: Botões "Anterior" e "Próxima"
- **Navegação direta**: Clique em números de página específicos
- **Indicadores visuais**: Mostra página atual e total de registros
- **Configuração flexível**: Diferentes números de itens por página
- **Renderização customizada**: Colunas com formatação específica

### Pagination Component

- **Navegação inteligente**: Mostra páginas relevantes com "..."
- **Controles de estado**: Desabilita botões quando necessário
- **Informações contextuais**: Exibe contadores de registros
- **Design responsivo**: Adapta-se a diferentes tamanhos de tela

### Estrutura de Paginação

```typescript
interface PaginationData<T> {
  data: T[];
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  startIndex: number;
  endIndex: number;
}
```

## 🎨 Interface do Usuário

### Página Principal

- Cards de navegação para cada consulta
- Explicação do objetivo de cada consulta
- Design limpo e moderno com Tailwind CSS

### Páginas de Consulta

- Documentação da consulta SQL
- Tabelas com os resultados
- Formatação adequada dos dados
- Navegação de volta para página principal

## 📊 Banco de Dados

### Estrutura das Tabelas

O sistema utiliza as seguintes tabelas principais:

- **Cidadao**: Informações básicas dos cidadãos
- **Imovel**: Propriedades dos cidadãos
- **Veiculos**: Veículos dos cidadãos
- **Educacao**: Informações educacionais
- **Beneficios_Sociais**: Benefícios recebidos
- **Ficha_Medica**: Dados médicos
- **Dependente**: Familiares dependentes

### Relacionamentos

- Cidadao → Imovel (1:N)
- Cidadao → Veiculos (1:N)
- Cidadao → Educacao (1:N)
- Cidadao → Beneficios_Sociais (1:N)
- Cidadao → Ficha_Medica (1:1)
- Cidadao → Dependente (1:N)

## 🔧 Desenvolvimento

### Estrutura do Código

- **Server Components**: Páginas que fazem consultas no servidor
- **Database Connection**: Pool de conexões PostgreSQL
- **Type Safety**: Interfaces TypeScript para os dados
- **Error Handling**: Tratamento de erros de banco de dados

### Padrões Utilizados

- **Async/Await**: Para operações assíncronas
- **Parallel Queries**: Consultas paralelas quando possível
- **Responsive Design**: Layout adaptativo
- **Clean Code**: Código limpo e documentado

## 📝 Conclusão

Este sistema demonstra a implementação de consultas SQL complexas em uma aplicação web moderna, mostrando como relacionar múltiplas entidades e apresentar os dados de forma clara e intuitiva. O projeto serve como exemplo prático de integração entre banco de dados relacional e interface web responsiva.

## 👥 Autor

Desenvolvido para a disciplina de Projeto Integrado de Banco de Dados (PIBD) da UFSCar.

---

_Este projeto foi desenvolvido com foco educacional, demonstrando conceitos de banco de dados relacional e desenvolvimento web moderno._

import Link from 'next/link';
import pool, { SaudeFamilia, SaudeStats } from '@/lib/pg';
import PaginatedTable from '@/components/PaginatedTable';

export default async function SaudeFamiliaPage() {
  let saudeData: SaudeFamilia[] = [];
  let saudeStats: SaudeStats[] = [];
  let error: string | null = null;

  try {
    // Query 3A: Cidadãos com ficha médica e seus dependentes
    const saudeQuery = `
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
    `;

    // Query 3B: Estatísticas de saúde e família
    const statsQuery = `
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
    `;

    const [saudeResult, statsResult] = await Promise.all([
      pool.query(saudeQuery),
      pool.query(statsQuery),
    ]);

    saudeData = saudeResult.rows;
    saudeStats = statsResult.rows;
  } catch (err) {
    error = err instanceof Error ? err.message : 'Erro ao executar consulta';
  }

  // Pre-format data for PaginatedTable
  const saudeStatsFormatted = saudeStats.map((item) => ({
    ...item,
    imc:
      item?.imc && !isNaN(Number(item.imc))
        ? Number(item.imc).toFixed(2)
        : 'N/A',
  }));

  const saudeDataFormatted = saudeData.map((item) => ({
    nome_cidadao: item.nome_cidadao,
    idade_cidadao: `${item.idade_cidadao} anos`,
    dados_fisicos: `${item.peso}kg - ${item.altura}m\nIMC: ${item.imc}\nTipo: ${item.tipo_sanguineo}`,
    cartao_nacional_saude: item.cartao_nacional_saude,
    nome_dependente: item.nome_dependente,
    grau_parentesco: item.grau_parentesco,
  }));

  return (
    <div className="min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="max-w-7xl mx-auto">
        <div className="mb-8">
          <Link
            href="/"
            className="text-blue-600 hover:text-blue-800 mb-4 inline-flex items-center"
          >
            ← Voltar ao início
          </Link>
          <h1 className="text-3xl font-bold mb-4 text-gray-900 dark:text-white">
            Consulta de Saúde e Família
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Relacionamento entre Cidadãos, Ficha Médica e Dependentes
          </p>
        </div>

        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-8">
            <strong>Erro:</strong> {error}
          </div>
        )}

        {/* SQL Query Documentation */}
        <div className="bg-gray-50 dark:bg-gray-800 p-6 rounded-lg border border-gray-200 dark:border-gray-700 mb-8">
          <h2 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">
            Documentação das Consultas SQL
          </h2>

          <div className="space-y-4">
            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                Query 3A: Cidadãos com Ficha Médica e Dependentes
              </h3>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Entidades:</strong> Cidadao, Ficha_Medica, Dependente
              </p>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Relacionamentos:</strong> Cidadao (1:1) Ficha_Medica,
                Cidadao (1:N) Dependente
              </p>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Listar cidadãos com suas informações
                médicas e dependentes, incluindo cálculo do IMC e detalhes
                familiares.
              </p>
            </div>

            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                Query 3B: Estatísticas de Saúde e Família
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Analisar o perfil de saúde (IMC e
                classificação) e estrutura familiar dos cidadãos, incluindo
                contagem e tipos de dependentes.
              </p>
            </div>
          </div>
        </div>

        {/* Estatísticas de Saúde e Família */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Estatísticas de Saúde e Família
          </h2>
          <PaginatedTable
            data={saudeStatsFormatted}
            columns={[
              { key: 'nome_cidadao', label: 'Nome Cidadão' },
              { key: 'tipo_sanguineo', label: 'Tipo Sanguíneo' },
              { key: 'imc', label: 'IMC' },
              { key: 'classificacao_imc', label: 'Classificação IMC' },
              { key: 'total_dependentes', label: 'Total Dependentes' },
              { key: 'tipos_dependentes', label: 'Tipos Dependentes' },
            ]}
            itemsPerPage={8}
          />
        </div>

        {/* Detalhes de Saúde e Família */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Detalhes de Saúde e Família por Cidadão
          </h2>
          <PaginatedTable
            data={saudeDataFormatted}
            columns={[
              { key: 'nome_cidadao', label: 'Nome Cidadão' },
              { key: 'idade_cidadao', label: 'Idade' },
              { key: 'dados_fisicos', label: 'Dados Saúde' },
              { key: 'cartao_nacional_saude', label: 'CNS' },
              { key: 'nome_dependente', label: 'Dependente' },
              { key: 'grau_parentesco', label: 'Parentesco' },
            ]}
            itemsPerPage={10}
          />
        </div>
      </main>
    </div>
  );
}

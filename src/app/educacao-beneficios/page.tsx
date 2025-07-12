import Link from 'next/link';
import pool, { EducacaoBeneficios, EducacaoStats } from '@/lib/pg';
import PaginatedTable from '@/components/PaginatedTable';

export default async function EducacaoBeneficiosPage() {
  let educacaoData: EducacaoBeneficios[] = [];
  let educacaoStats: EducacaoStats[] = [];
  let error: string | null = null;

  try {
    // Query 2A: Cidadãos com educação ativa e benefícios sociais
    const educacaoQuery = `
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
    `;

    // Query 2B: Análise de benefícios por nível educacional
    const statsQuery = `
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
    `;

    const [educacaoResult, statsResult] = await Promise.all([
      pool.query(educacaoQuery),
      pool.query(statsQuery),
    ]);

    educacaoData = educacaoResult.rows;
    educacaoStats = statsResult.rows;
  } catch (err) {
    error = err instanceof Error ? err.message : 'Erro ao executar consulta';
  }

  // Pre-format data for PaginatedTable
  const educacaoStatsFormatted = educacaoStats.map((item) => ({
    ...item,
    idade_media: `${item.idade_media} anos`,
  }));

  const educacaoDataFormatted = educacaoData.map((item) => ({
    nome_cidadao: item.nome_cidadao,
    idade: `${item.idade} anos`,
    nivel_educacao: `${item.nivel_educacao}\n${item.instituicao}\nMat: ${item.matricula}`,
    beneficio: `${item.beneficio}\n${item.status_beneficio}`,
    inicio_beneficio: new Date(item.inicio_beneficio).toLocaleDateString(
      'pt-BR'
    ),
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
            Consulta de Educação e Benefícios
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Relacionamento entre Cidadãos, Educação e Benefícios Sociais
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
                Query 2A: Cidadãos com Educação Ativa e Benefícios Sociais
              </h3>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Entidades:</strong> Cidadao, Educacao,
                Beneficios_Sociais
              </p>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Relacionamentos:</strong> Cidadao (1:N) Educacao,
                Cidadao (1:N) Beneficios_Sociais
              </p>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Listar cidadãos que possuem educação
                ativa e benefícios sociais ativos, analisando o perfil
                educacional e social dos beneficiários.
              </p>
            </div>

            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                Query 2B: Análise de Benefícios por Nível Educacional
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Analisar a distribuição de benefícios
                sociais por nível educacional, incluindo estatísticas de idade e
                tipos de benefícios recebidos.
              </p>
            </div>
          </div>
        </div>

        {/* Análise por Nível Educacional */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Análise de Benefícios por Nível Educacional
          </h2>
          <PaginatedTable
            data={educacaoStatsFormatted}
            columns={[
              { key: 'nivel_educacao', label: 'Nível Educacional' },
              { key: 'total_cidadaos', label: 'Total Cidadãos' },
              { key: 'total_beneficios', label: 'Total Benefícios' },
              { key: 'idade_media', label: 'Idade Média' },
              { key: 'tipos_beneficios', label: 'Tipos de Benefícios' },
            ]}
            itemsPerPage={8}
          />
        </div>

        {/* Detalhes de Educação e Benefícios */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Detalhes de Educação e Benefícios por Cidadão
          </h2>
          <PaginatedTable
            data={educacaoDataFormatted}
            columns={[
              { key: 'nome_cidadao', label: 'Nome Cidadão' },
              { key: 'idade', label: 'Idade' },
              { key: 'nivel_educacao', label: 'Educação' },
              { key: 'beneficio', label: 'Benefício' },
              { key: 'inicio_beneficio', label: 'Início Benefício' },
            ]}
            itemsPerPage={10}
          />
        </div>
      </main>
    </div>
  );
}

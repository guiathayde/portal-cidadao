import Link from 'next/link';
import pool, { PatrimonioResult, PatrimonioStats } from '@/lib/pg';
import PaginatedTable from '@/components/PaginatedTable';

export default async function PatrimonioPage() {
  let patrimonioData: PatrimonioResult[] = [];
  let patrimonioStats: PatrimonioStats[] = [];
  let error: string | null = null;

  try {
    // Query 1A: Cidadãos com pelo menos um imóvel e um veículo
    const patrimonioQuery = `
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
    `;

    // Query 1B: Estatísticas de patrimônio por cidadão
    const statsQuery = `
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
    `;

    const [patrimonioResult, statsResult] = await Promise.all([
      pool.query(patrimonioQuery),
      pool.query(statsQuery),
    ]);

    patrimonioData = patrimonioResult.rows;
    patrimonioStats = statsResult.rows;
  } catch (err) {
    error = err instanceof Error ? err.message : 'Erro ao executar consulta';
  }

  // Format data for display
  const formattedStats = patrimonioStats.map((stat) => ({
    cpf: stat.cpf,
    nome_cidadao: stat.nome_cidadao,
    total_imoveis: stat.total_imoveis.toString(),
    total_veiculos: stat.total_veiculos.toString(),
    valor_total_imoveis: `R$ ${stat.valor_total_imoveis.toLocaleString(
      'pt-BR',
      { minimumFractionDigits: 2 }
    )}`,
    ano_medio_veiculos: stat.ano_medio_veiculos.toString(),
  }));

  const formattedPatrimonio = patrimonioData.map((item) => ({
    nome_cidadao: item.nome_cidadao,
    imovel: `${item.tipo_propriedade} - ${item.endereco_imovel}`,
    valor: `R$ ${item.valor_imovel.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
    })}`,
    veiculo: `${item.modelo_veiculo} (${item.placa} - ${item.cor})`,
    ano: item.ano_veiculo.toString(),
  }));

  // Pre-format data for PaginatedTable
  const patrimonioStatsFormatted = patrimonioStats.map((item) => ({
    ...item,
    valor_total_imoveis: `R$ ${item.valor_total_imoveis.toLocaleString(
      'pt-BR',
      {
        minimumFractionDigits: 2,
      }
    )}`,
  }));

  const patrimonioDataFormatted = patrimonioData.map((item) => ({
    nome_cidadao: item.nome_cidadao,
    tipo_propriedade: `${item.tipo_propriedade}\n${item.endereco_imovel}`,
    valor_imovel: `R$ ${item.valor_imovel.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
    })}`,
    modelo_veiculo: `${item.modelo_veiculo}\n${item.placa} - ${item.cor}`,
    ano_veiculo: item.ano_veiculo,
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
            Consulta de Patrimônio
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Relacionamento entre Cidadãos, Imóveis e Veículos
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
                Query 1A: Cidadãos com Imóveis e Veículos
              </h3>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Entidades:</strong> Cidadao, Imovel, Veiculos
              </p>
              <p className="text-gray-600 dark:text-gray-400 mb-2">
                <strong>Relacionamentos:</strong> Cidadao (1:N) Imovel, Cidadao
                (1:N) Veiculos
              </p>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Listar todos os cidadãos que possuem
                pelo menos um imóvel e um veículo, mostrando os detalhes de seus
                bens.
              </p>
            </div>

            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-2">
                Query 1B: Estatísticas de Patrimônio
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                <strong>Objetivo:</strong> Calcular estatísticas agregadas do
                patrimônio de cada cidadão, incluindo total de imóveis,
                veículos, valor total dos imóveis e ano médio dos veículos.
              </p>
            </div>
          </div>
        </div>

        {/* Estatísticas de Patrimônio */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Estatísticas de Patrimônio por Cidadão
          </h2>
          <PaginatedTable
            data={patrimonioStatsFormatted}
            columns={[
              { key: 'cpf', label: 'CPF' },
              { key: 'nome_cidadao', label: 'Nome' },
              { key: 'total_imoveis', label: 'Total Imóveis' },
              { key: 'total_veiculos', label: 'Total Veículos' },
              { key: 'valor_total_imoveis', label: 'Valor Total Imóveis' },
              { key: 'ano_medio_veiculos', label: 'Ano Médio Veículos' },
            ]}
            itemsPerPage={8}
          />
        </div>

        {/* Detalhes do Patrimônio */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            Detalhes do Patrimônio
          </h2>
          <PaginatedTable
            data={patrimonioDataFormatted}
            columns={[
              { key: 'nome_cidadao', label: 'Nome Cidadão' },
              { key: 'tipo_propriedade', label: 'Imóvel' },
              { key: 'valor_imovel', label: 'Valor' },
              { key: 'modelo_veiculo', label: 'Veículo' },
              { key: 'ano_veiculo', label: 'Ano' },
            ]}
            itemsPerPage={10}
          />
        </div>
      </main>
    </div>
  );
}

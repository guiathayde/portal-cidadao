import { Pool } from 'pg';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { poolConfig } from '@/lib/pg';

export default async function CitizenDetailsPage({
  params,
}: {
  params: Promise<{ cpf: string }>;
}) {
  const { cpf } = await params;

  const pool = new Pool(poolConfig);
  const { rows: citizens } = await pool.query(
    'SELECT * FROM cidadao WHERE cpf = $1',
    [cpf]
  );

  if (!citizens || citizens.length === 0) {
    notFound();
  }

  const citizen = citizens[0];

  return (
    <div className="min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="max-w-4xl mx-auto">
        <div className="mb-8">
          <Link
            href="/cidadaos"
            className="text-blue-600 hover:text-blue-800 mb-4 inline-flex items-center"
          >
            ← Voltar para lista de cidadãos
          </Link>
          <h1 className="text-3xl font-bold mb-4 text-gray-900 dark:text-white">
            Detalhes do Cidadão
          </h1>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h2 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">
                Informações Pessoais
              </h2>
              <div className="space-y-3">
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    CPF:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.cpf}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Nome:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.nome}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Data de Nascimento:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {new Date(citizen.data_nascimento).toLocaleDateString(
                      'pt-BR'
                    )}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Gênero:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.genero}
                  </span>
                </div>
              </div>
            </div>

            <div>
              <h2 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">
                Contato
              </h2>
              <div className="space-y-3">
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Email:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.email}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Telefone:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.telefone}
                  </span>
                </div>
              </div>
            </div>

            <div className="md:col-span-2">
              <h2 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">
                Endereço
              </h2>
              <div className="space-y-3">
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Logradouro:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.endereco}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-gray-700 dark:text-gray-300">
                    Bairro:
                  </span>
                  <span className="ml-2 text-gray-900 dark:text-white">
                    {citizen.bairro}
                  </span>
                </div>
                <div className="flex gap-6">
                  <div>
                    <span className="font-medium text-gray-700 dark:text-gray-300">
                      CEP:
                    </span>
                    <span className="ml-2 text-gray-900 dark:text-white">
                      {citizen.cep}
                    </span>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700 dark:text-gray-300">
                      Cidade:
                    </span>
                    <span className="ml-2 text-gray-900 dark:text-white">
                      {citizen.cidade}
                    </span>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700 dark:text-gray-300">
                      Estado:
                    </span>
                    <span className="ml-2 text-gray-900 dark:text-white">
                      {citizen.estado}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

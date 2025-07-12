import { Pool } from 'pg';
import Link from 'next/link';
import { poolConfig } from '@/lib/pg';
import CitizensTable from '@/components/CitizensTable';

export default async function CitizensPage() {
  const pool = new Pool(poolConfig);
  const { rows: citizens } = await pool.query(
    'SELECT * FROM cidadao ORDER BY nome'
  );

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
            Lista de Cidadãos
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Todos os cidadãos cadastrados no sistema
          </p>
        </div>

        <CitizensTable citizens={citizens} />
      </main>
    </div>
  );
}

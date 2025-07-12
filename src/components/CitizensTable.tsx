'use client';

import { useRouter } from 'next/navigation';
import PaginatedTable from './PaginatedTable';

interface Citizen {
  cpf: string;
  nome: string;
  data_nascimento: string;
  genero: string;
  email: string;
  telefone: string;
  endereco: string;
  bairro: string;
  cep: string;
  cidade: string;
  estado: string;
}

interface CitizensTableProps {
  citizens: Citizen[];
}

export default function CitizensTable({ citizens }: CitizensTableProps) {
  const router = useRouter();

  const handleRowClick = (citizen: Citizen) => {
    router.push(`/cidadaos/${citizen.cpf}`);
  };

  // Pre-format data for the table
  const formattedCitizens = citizens.map((citizen) => ({
    ...citizen,
    data_nascimento: new Date(citizen.data_nascimento).toLocaleDateString(
      'pt-BR'
    ),
    endereco_completo: `${citizen.endereco}, ${citizen.bairro}, ${citizen.cidade} - ${citizen.estado}`,
    email: citizen.email,
    telefone: citizen.telefone,
  }));

  const columns = [
    { key: 'cpf', label: 'CPF' },
    { key: 'nome', label: 'Nome' },
    { key: 'data_nascimento', label: 'Data de Nascimento' },
    { key: 'genero', label: 'Gênero' },
    { key: 'endereco_completo', label: 'Endereço' },
    { key: 'email', label: 'Email' },
    { key: 'telefone', label: 'Telefone' },
  ];

  return (
    <div className="space-y-4">
      <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
        <p className="text-sm text-blue-800 dark:text-blue-200 flex items-center">
          <svg
            className="w-4 h-4 mr-2"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Clique em qualquer linha para ver os detalhes completos do cidadão
        </p>
      </div>

      <PaginatedTable
        data={formattedCitizens}
        columns={columns}
        itemsPerPage={15}
        onRowClick={handleRowClick}
      />
    </div>
  );
}

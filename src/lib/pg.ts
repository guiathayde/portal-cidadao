import { Pool, PoolConfig } from 'pg';

export const poolConfig: PoolConfig = {
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'postgres',
  port: 5432,
};

const pool = new Pool(poolConfig);

export default pool;

// Types for our queries
export interface PatrimonioResult {
  cpf: string;
  nome_cidadao: string;
  data_nascimento: string;
  imovel_matricula: string;
  tipo_propriedade: string;
  endereco_imovel: string;
  valor_imovel: number;
  placa: string;
  modelo_veiculo: string;
  ano_veiculo: number;
  cor: string;
}

export interface PatrimonioStats {
  cpf: string;
  nome_cidadao: string;
  total_imoveis: number;
  total_veiculos: number;
  valor_total_imoveis: number;
  ano_medio_veiculos: number;
}

export interface EducacaoBeneficios {
  cpf: string;
  nome_cidadao: string;
  idade: number;
  instituicao: string;
  nivel_educacao: string;
  status_educacao: string;
  matricula: string;
  beneficio: string;
  inicio_beneficio: string;
  status_beneficio: string;
}

export interface EducacaoStats {
  nivel_educacao: string;
  total_cidadaos: number;
  total_beneficios: number;
  idade_media: number;
  tipos_beneficios: string;
}

export interface SaudeFamilia {
  cpf: string;
  nome_cidadao: string;
  idade_cidadao: number;
  peso: number;
  altura: number;
  tipo_sanguineo: string;
  cartao_nacional_saude: string;
  imc: number;
  nome_dependente: string;
  grau_parentesco: string;
}

export interface SaudeStats {
  cpf: string;
  nome_cidadao: string;
  tipo_sanguineo: string;
  imc: number;
  classificacao_imc: string;
  total_dependentes: number;
  tipos_dependentes: string;
}

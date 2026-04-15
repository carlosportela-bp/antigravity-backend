export interface Usuario {
  id: number;
  nome: string;
  email: string;
  perfil: 'Jadiel' | 'Admin' | 'Atendente';
  meta_faturamento?: number;
}

export interface Cliente {
  id: number;
  nome_completo: string;
  cpf: string;
  rg?: string;
  telefone_whatsapp?: string;
  puf: string;
  categoria_servico: string;
  valor_contrato: number;
  status_pagamento: string;
  status_caso: 'Triagem' | 'Protocolado' | 'Em Andamento' | 'Concluído';
  notas?: string;
  atendente_id?: number;
  data_cadastro?: string;
}

export interface Documento {
  id: number;
  cliente_id: number;
  nome_arquivo: string;
  tipo_arquivo: 'PDF' | 'IMG' | 'MP4' | 'AUDIO';
  mime_type: string;
  data_upload: string;
}

export interface Transacao {
  id: number;
  cliente_id?: number;
  descricao: string;
  valor: number;
  tipo: 'Entrada' | 'Saída';
  data_transacao: string;
  nome_cliente?: string;
}

export interface Stats {
  totalClientes: number;
  faturamento: number;
  saldo: number;
}

export interface DashboardAggregate {
  area: { name: string; value: number }[];
  status: { name: string; value: number }[];
}

export interface LogAtividade {
  id: number;
  usuario_id: number;
  usuario_nome: string;
  acao: 'INSERT' | 'UPDATE' | 'DELETE';
  tabela_afetada: string;
  dados_antigos?: any;
  dados_novos?: any;
  data_hora: string;
}

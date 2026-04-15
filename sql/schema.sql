-- Script SQL para Banco de Dados Escritório Jadiel (PostgreSQL)
-- Objetivo: Suporte ao front-end SaaS jurídico/financeiro

-- 1. Criação de Tipos Enumerados (Enums)
CREATE TYPE perfil_usuario AS ENUM ('Jadiel', 'Admin', 'Atendente');
CREATE TYPE categoria_servico AS ENUM ('APOSENTADORIA', 'PENSÃO', 'LOAS/BPC', 'SAQUE FGTS', 'EMPRÉSTIMOS', 'CARTÃO DE CRÉDITO', 'OUTROS');
CREATE TYPE status_pagamento AS ENUM ('Em dia', 'Inadimplente', 'Finalizado');
CREATE TYPE tipo_arquivo AS ENUM ('PDF', 'MP4', 'IMG');

-- 2. Tabela de Usuários (Controle de Acessos)
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha TEXT NOT NULL, -- Deve conter o hash da senha
    perfil perfil_usuario NOT NULL,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela de Clientes (Dados Cadastrais e Financeiros)
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL, -- Formato: 000.000.000-00 ou apenas números
    rg VARCHAR(20),
    telefone_whatsapp VARCHAR(20),
    puf VARCHAR(100) NOT NULL, -- Requisito obrigatório
    categoria_servico categoria_servico NOT NULL,
    valor_contrato DECIMAL(12, 2) DEFAULT 0.00,
    status_pagamento status_pagamento DEFAULT 'Em dia',
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabela de Documentos (Arquivos Binários - BYTEA)
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
    nome_arquivo VARCHAR(255) NOT NULL,
    tipo_arquivo VARCHAR(50) NOT NULL, -- PDF, IMG, MP4, AUDIO
    mime_type VARCHAR(100),
    arquivo_binario BYTEA, -- Armazenamento direto no Postgres
    url_storage TEXT DEFAULT 'DATABASE_BIN', -- Legado/Fallback
    data_upload TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabela de Logs de Atividades (Auditoria com Undo)
CREATE TABLE logs_atividades (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    acao VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    tabela_afetada VARCHAR(100) NOT NULL,
    dados_antigos JSONB, -- Estado anterior (para Undo)
    dados_novos JSONB,   -- Estado posterior
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Índices para Otimização de Busca
CREATE INDEX idx_clientes_cpf ON clientes(cpf);
CREATE INDEX idx_clientes_nome ON clientes(nome_completo);

-- 7. Lógica de Auditoria Seletiva com Captura de Dados (Trigger)
CREATE OR REPLACE FUNCTION fn_registrar_log()
RETURNS TRIGGER AS $$
DECLARE
    v_perfil VARCHAR(50);
    v_usuario_id INTEGER;
BEGIN
    BEGIN
        v_usuario_id := current_setting('app.current_user_id', true)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        RETURN NEW;
    END;

    IF v_usuario_id IS NOT NULL THEN
        SELECT perfil INTO v_perfil FROM usuarios WHERE id = v_usuario_id;

        IF v_perfil IN ('Admin', 'Atendente') THEN
            IF (TG_OP = 'DELETE') THEN
                INSERT INTO logs_atividades (usuario_id, acao, tabela_afetada, dados_antigos)
                VALUES (v_usuario_id, TG_OP, TG_TABLE_NAME, row_to_json(OLD));
            ELSIF (TG_OP = 'UPDATE') THEN
                INSERT INTO logs_atividades (usuario_id, acao, tabela_afetada, dados_antigos, dados_novos)
                VALUES (v_usuario_id, TG_OP, TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
            ELSIF (TG_OP = 'INSERT') THEN
                INSERT INTO logs_atividades (usuario_id, acao, tabela_afetada, dados_novos)
                VALUES (v_usuario_id, TG_OP, TG_TABLE_NAME, row_to_json(NEW));
            END IF;
        END IF;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicando o trigger nas tabelas principais
CREATE TRIGGER trg_log_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION fn_registrar_log();

CREATE TRIGGER trg_log_documentos
AFTER INSERT OR UPDATE OR DELETE ON documentos
FOR EACH ROW EXECUTE FUNCTION fn_registrar_log();

-- 8. Tabela de Transações Financeiras (Caixa/Movimentações)
CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id) ON DELETE SET NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(12, 2) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Entrada', 'Saída')),
    data_transacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_transacoes
AFTER INSERT OR UPDATE OR DELETE ON transacoes
FOR EACH ROW EXECUTE FUNCTION fn_registrar_log();

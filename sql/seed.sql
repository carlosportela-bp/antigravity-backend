-- Script de Semente (Seed) para o Escritório Jadiel
-- Execute este script no pgAdmin após criar o schema.

-- 1. Inserir Usuários de Teste (Senha em texto plano para o exemplo, em produção use hash)
INSERT INTO usuarios (nome, email, senha, perfil) VALUES 
('Jadiel Siqueira', 'jadiel@escritorio.com', '123456', 'Jadiel'),
('Administrador', 'admin@escritorio.com', 'admin123', 'Admin'),
('Atendente Paula', 'paula@escritorio.com', 'paula123', 'Atendente');

-- 2. Inserir Clientes de Teste
INSERT INTO clientes (nome_completo, cpf, rg, telefone_whatsapp, puf, categoria_servico, valor_contrato, status_pagamento) VALUES 
('Carlos Alberto da Silva', '123.456.789-00', '12.345.678-9', '(11) 98888-7777', 'PRO-2024-001', 'Aposentadoria', 2500.00, 'Em dia'),
('Maria Eduarda Santos', '987.654.321-11', '98.765.432-1', '(11) 97777-6666', 'PRO-2024-002', 'LOAS_BPC', 1800.00, 'Inadimplente'),
('João Pereira da Luz', '456.789.123-22', '45.678.912-3', '(11) 96666-5555', 'PRO-2024-003', 'Saque_FGTS', 500.00, 'Finalizado');

-- 3. Inserir Documentos de Teste
INSERT INTO documentos (cliente_id, nome_arquivo, tipo_arquivo, url_storage) VALUES 
(1, 'Contrato_Aposentadoria.pdf', 'PDF', 'https://storage.link/pdf1'),
(1, 'Foto_RG.jpg', 'IMG', 'https://storage.link/img1'),
(2, 'Video_Depoimento.mp4', 'MP4', 'https://storage.link/video1');

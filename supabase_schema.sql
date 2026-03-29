-- ============================================================
-- ZAPFLOW - AÇAÍ BRAZUCA
-- Script completo do banco de dados Supabase
-- Execute no SQL Editor do seu projeto Supabase
-- ============================================================

-- ===============================
-- 1. EMPRESAS
-- ===============================
CREATE TABLE IF NOT EXISTS empresas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  email TEXT,
  telefone TEXT,
  endereco TEXT,
  cnpj TEXT,
  logo_url TEXT,
  plano TEXT DEFAULT 'gratuito',
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 2. USUÁRIOS
-- ===============================
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY,  -- mesmo id do auth.users
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT DEFAULT 'atendente', -- admin | atendente | financeiro
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 3. CLIENTES
-- ===============================
CREATE TABLE IF NOT EXISTS clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  telefone TEXT,
  email TEXT,
  endereco TEXT,
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 4. CONVERSAS
-- ===============================
CREATE TABLE IF NOT EXISTS conversas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES clientes(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'ativo', -- ativo | arquivado | encerrado
  ultima_mensagem TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 5. MENSAGENS
-- ===============================
CREATE TABLE IF NOT EXISTS mensagens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversa_id UUID REFERENCES conversas(id) ON DELETE CASCADE,
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  remetente TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  tipo TEXT DEFAULT 'enviado', -- enviado | recebido
  lida BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 6. PRODUTOS
-- ===============================
CREATE TABLE IF NOT EXISTS produtos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco NUMERIC(10,2) NOT NULL DEFAULT 0,
  categoria TEXT DEFAULT 'Outros',
  estoque INTEGER,
  ativo BOOLEAN DEFAULT true,
  imagem_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 7. PEDIDOS
-- ===============================
CREATE TABLE IF NOT EXISTS pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'aberto', -- aberto | em_preparo | finalizado | cancelado
  total NUMERIC(10,2) DEFAULT 0,
  observacoes TEXT,
  forma_pagamento TEXT, -- dinheiro | pix | cartao_debito | cartao_credito
  desconto NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 8. ITENS DO PEDIDO
-- ===============================
CREATE TABLE IF NOT EXISTS itens_pedido (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID REFERENCES pedidos(id) ON DELETE CASCADE,
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES produtos(id) ON DELETE SET NULL,
  nome TEXT NOT NULL,
  quantidade INTEGER NOT NULL DEFAULT 1,
  preco_unitario NUMERIC(10,2) NOT NULL,
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ===============================
-- 9. FINANCEIRO
-- ===============================
CREATE TABLE IF NOT EXISTS financeiro (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  pedido_id UUID REFERENCES pedidos(id) ON DELETE SET NULL,
  tipo TEXT NOT NULL, -- receber | pagar
  descricao TEXT NOT NULL,
  valor NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'pendente', -- pendente | pago | cancelado
  categoria TEXT,
  data_vencimento TIMESTAMPTZ,
  data_pagamento TIMESTAMPTZ,
  forma_pagamento TEXT,
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) - Isolamento multi-tenant
-- ============================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversas ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensagens ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE financeiro ENABLE ROW LEVEL SECURITY;

-- Função helper para pegar empresa_id do usuário autenticado
CREATE OR REPLACE FUNCTION get_empresa_id()
RETURNS UUID AS $$
  SELECT empresa_id FROM usuarios WHERE id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- Políticas: usuário acessa apenas dados da sua empresa

-- EMPRESAS
CREATE POLICY "empresa_own" ON empresas
  FOR ALL USING (id = get_empresa_id());

-- USUARIOS
CREATE POLICY "usuarios_empresa" ON usuarios
  FOR ALL USING (empresa_id = get_empresa_id());

-- CLIENTES
CREATE POLICY "clientes_empresa" ON clientes
  FOR ALL USING (empresa_id = get_empresa_id());

-- CONVERSAS
CREATE POLICY "conversas_empresa" ON conversas
  FOR ALL USING (empresa_id = get_empresa_id());

-- MENSAGENS
CREATE POLICY "mensagens_empresa" ON mensagens
  FOR ALL USING (empresa_id = get_empresa_id());

-- PRODUTOS
CREATE POLICY "produtos_empresa" ON produtos
  FOR ALL USING (empresa_id = get_empresa_id());

-- PEDIDOS
CREATE POLICY "pedidos_empresa" ON pedidos
  FOR ALL USING (empresa_id = get_empresa_id());

-- ITENS PEDIDO
CREATE POLICY "itens_empresa" ON itens_pedido
  FOR ALL USING (empresa_id = get_empresa_id());

-- FINANCEIRO
CREATE POLICY "financeiro_empresa" ON financeiro
  FOR ALL USING (empresa_id = get_empresa_id());

-- ============================================================
-- REALTIME - Habilitar para mensagens em tempo real
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE mensagens;
ALTER PUBLICATION supabase_realtime ADD TABLE pedidos;
ALTER PUBLICATION supabase_realtime ADD TABLE conversas;

-- ============================================================
-- ÍNDICES para performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_clientes_empresa ON clientes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_conversas_empresa ON conversas(empresa_id);
CREATE INDEX IF NOT EXISTS idx_conversas_cliente ON conversas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_mensagens_conversa ON mensagens(conversa_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_empresa ON pedidos(empresa_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_itens_pedido ON itens_pedido(pedido_id);
CREATE INDEX IF NOT EXISTS idx_financeiro_empresa ON financeiro(empresa_id);
CREATE INDEX IF NOT EXISTS idx_produtos_empresa ON produtos(empresa_id);

-- ============================================================
-- DADOS INICIAIS DE EXEMPLO (AÇAÍ BRAZUCA)
-- ⚠️  Rode isso DEPOIS de criar sua conta no sistema
--     Substitua 'SEU_EMPRESA_ID' pelo ID real da empresa
-- ============================================================

-- Exemplo de produtos (descomente e ajuste o empresa_id):
/*
INSERT INTO produtos (empresa_id, nome, descricao, preco, categoria, ativo) VALUES
  ('SEU_EMPRESA_ID', 'Açaí 300ml', 'Açaí cremoso com granola', 12.00, 'Açaí', true),
  ('SEU_EMPRESA_ID', 'Açaí 500ml', 'Açaí cremoso com granola e frutas', 18.00, 'Açaí', true),
  ('SEU_EMPRESA_ID', 'Açaí 700ml', 'Açaí cremoso família', 24.00, 'Açaí', true),
  ('SEU_EMPRESA_ID', 'Açaí 1L', 'Açaí cremoso 1 litro', 32.00, 'Açaí', true),
  ('SEU_EMPRESA_ID', 'Água Mineral', 'Garrafa 500ml', 3.00, 'Bebida', true),
  ('SEU_EMPRESA_ID', 'Refrigerante Lata', 'Coca-Cola, Guaraná ou Sprite', 6.00, 'Bebida', true),
  ('SEU_EMPRESA_ID', 'Granola Extra', 'Porção extra de granola', 2.00, 'Adicional', true),
  ('SEU_EMPRESA_ID', 'Leite Ninho', 'Cobertura de leite ninho', 2.00, 'Adicional', true),
  ('SEU_EMPRESA_ID', 'Banana', 'Fatias de banana', 1.50, 'Adicional', true),
  ('SEU_EMPRESA_ID', 'Morango', 'Fatias de morango fresco', 2.00, 'Adicional', true),
  ('SEU_EMPRESA_ID', 'Combo Casal', 'Açaí 500ml + 2 Refrigerantes', 28.00, 'Combo', true),
  ('SEU_EMPRESA_ID', 'Combo Família', 'Açaí 1L + 4 Refrigerantes', 48.00, 'Combo', true);
*/

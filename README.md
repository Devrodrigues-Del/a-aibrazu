# ⚡ ZapFlow — Açaí Brazuca
> Sistema de Atendimento, Vendas e Gestão estilo WhatsApp

---

## 🚀 Como Rodar (Passo a Passo)

### 1. Criar projeto no Supabase
1. Acesse [supabase.com](https://supabase.com) e crie uma conta gratuita
2. Clique em **"New Project"** e preencha:
   - Nome: `zapflow-acai-brazuca`
   - Senha do banco: (anote em local seguro)
   - Região: South America (São Paulo)
3. Aguarde o projeto ser criado (~1 min)

### 2. Configurar o banco de dados
1. No painel do Supabase, vá em **SQL Editor**
2. Clique em **"New Query"**
3. Cole todo o conteúdo do arquivo `supabase_schema.sql`
4. Clique em **"Run"** (▶️)

### 3. Pegar as credenciais
1. Vá em **Settings → API**
2. Copie:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon public** → `VITE_SUPABASE_ANON_KEY`

### 4. Configurar o projeto
```bash
# Copiar variáveis de ambiente
cp .env.example .env

# Edite o .env e cole suas credenciais
```

### 5. Instalar e rodar
```bash
npm install
npm run dev
```
Acesse: **http://localhost:3000**

### 6. Criar sua conta
1. Na tela de login, clique em **"Criar Conta"**
2. Preencha seus dados (o nome da empresa já vem com "Açaí Brazuca")
3. Confirme o e-mail (cheque sua caixa de entrada)
4. Faça login e comece a usar!

---

## 📦 Deploy na Vercel (grátis)

```bash
# 1. Instale a CLI da Vercel
npm i -g vercel

# 2. Faça login
vercel login

# 3. Deploy
vercel --prod
```

Ou conecte o repositório no [vercel.com](https://vercel.com) e adicione as variáveis de ambiente:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

---

## 🗂️ Estrutura do Projeto

```
zapflow/
├── public/
│   └── logo.jpg              # Logo Açaí Brazuca
├── src/
│   ├── components/
│   │   ├── Chat/
│   │   │   └── NovaConversaModal.jsx
│   │   └── Pedidos/
│   │       ├── NovoPedidoModal.jsx
│   │       └── ComandaModal.jsx
│   ├── hooks/
│   │   └── useAuth.jsx        # Context de autenticação
│   ├── lib/
│   │   └── supabase.js        # Client Supabase
│   ├── pages/
│   │   ├── AppLayout.jsx      # Layout principal
│   │   ├── AuthPage.jsx       # Login / Registro
│   │   ├── ChatPage.jsx       # Atendimento (WhatsApp)
│   │   ├── DashboardPage.jsx  # Dashboard com gráficos
│   │   ├── ClientesPage.jsx   # Gestão de clientes
│   │   ├── ProdutosPage.jsx   # Catálogo de produtos
│   │   ├── FinanceiroPage.jsx # Financeiro completo
│   │   └── ConfigPage.jsx     # Configurações
│   ├── styles/
│   │   └── global.css         # Tema roxo Açaí Brazuca
│   ├── App.jsx
│   └── main.jsx
├── supabase_schema.sql        # Script do banco
├── .env.example               # Modelo de variáveis
├── vercel.json                # Config deploy
└── package.json
```

---

## ✨ Funcionalidades

| Módulo | Funcionalidades |
|--------|----------------|
| 💬 Chat | Atendimento estilo WhatsApp, mensagens em tempo real, histórico |
| 🛒 Pedidos | Criar pedido na conversa, múltiplos produtos, status |
| 🧾 Comanda | Recibo térmico, imprimir, PDF, enviar WhatsApp |
| 📊 Dashboard | KPIs, gráfico de vendas, top produtos, filtros |
| 👥 Clientes | Cadastro completo, histórico de pedidos, WhatsApp direto |
| 🛍️ Produtos | Catálogo com categorias, estoque, ativar/desativar |
| 💰 Financeiro | A receber, a pagar, fluxo de caixa, relatórios |
| ⚙️ Config | Dados da empresa, usuários, planos, integrações |

---

## 🎨 Tema
- Cores: **Roxo** (#7c3aed) + **Verde** (#6abf4b) — identidade Açaí Brazuca
- Fundo escuro elegante
- Logo integrada em toda interface

---

## 🔐 Segurança
- Row Level Security (RLS) ativo em todas as tabelas
- Cada empresa vê apenas seus próprios dados
- Autenticação via Supabase Auth

---

*Desenvolvido com ❤️ para Açaí Brazuca*

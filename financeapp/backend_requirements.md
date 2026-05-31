# Backend Requirements — FinanciApp

> Documento gerado a partir de auditoria técnica completa do aplicativo Flutter.
> Objetivo: fornecer especificação suficiente para que um desenvolvedor backend implemente a API e o banco de dados do zero.

---

## Sumário

1. [Auditoria do Estado Atual](#1-auditoria-do-estado-atual)
2. [Visão Geral da API](#2-visão-geral-da-api)
3. [Autenticação](#3-autenticação)
4. [Usuários](#4-usuários)
5. [Categorias](#5-categorias)
6. [Movimentações](#6-movimentações)
7. [Investimentos](#7-investimentos)
8. [Dashboard](#8-dashboard)
9. [Relatórios](#9-relatórios)
10. [Notificações](#10-notificações)
11. [Configurações](#11-configurações)
12. [Modelagem do Banco de Dados](#12-modelagem-do-banco-de-dados)

---

## 1. Auditoria do Estado Atual

### 1.1 O que o app já tem (funcional)

| Área | Status | Observação |
|---|---|---|
| Listagem de transações | ✅ Funcional | Dados mockados em memória |
| Adição de transações | ✅ Funcional | Persiste apenas em memória, perdido ao reiniciar |
| Exclusão de transações | ✅ Funcional | Apenas delete, sem soft delete |
| Dashboard com cards de resumo | ✅ Funcional | Cálculos corretos, trendPercent hardcoded (6.2%) |
| Gráfico de fluxo semanal | ✅ Funcional | Últimos 7 dias |
| Gráfico barras Relatórios | ✅ Funcional | Últimos 6 meses |
| Gráfico pizza Relatórios | ✅ Funcional | Gastos por categoria do mês atual |
| Insight de gastos | ✅ Funcional | Comparação mês atual vs anterior |
| Histórico com filtros | ✅ Funcional | Filtro por tipo e mês/ano |
| Criação de categorias (UI) | ✅ UI pronta | Não persiste, sem backend |
| Formatação BRL | ✅ Funcional | BankAmountFormatter + CurrencyFormatter |
| Localização pt_BR | ✅ Funcional | intl configurado |

### 1.2 O que está incompleto ou ausente

| Área | Status | Impacto |
|---|---|---|
| Autenticação | ❌ Ausente | Bloqueante — sem login/cadastro/sessão |
| Persistência de dados | ❌ Ausente | Dados perdidos ao reiniciar o app |
| Edição de transações | ❌ Ausente | Não há `update()` no repository/controller |
| Abas de período (Semana/Mês/Ano) no Relatórios | ❌ Não funcional | UI existe, lógica ausente |
| Tela de Perfil | ❌ Placeholder | Menu Mais completamente sem ação |
| Contas bancárias | ❌ Ausente | Item no menu, sem tela |
| Metas de economia | ❌ Ausente | Item no menu, sem tela |
| Investimentos (módulo dedicado) | ❌ Ausente | Apenas categoria genérica |
| Notificações push | ❌ Ausente | Interface abstrata, sem implementação |
| Transações recorrentes | ❌ Ausente | Não modelado |
| Parcelamentos | ❌ Ausente | Não modelado |
| Paginação | ❌ Ausente | `getAll()` carrega tudo |
| Busca/pesquisa de transações | ❌ Ausente | Não modelado |
| Autenticação com rota guard | ❌ Ausente | `routes.dart` é placeholder vazio |
| Armazenamento local (cache/offline) | ❌ Ausente | `StorageService` é interface abstrata |
| Testes automatizados | ❌ Ausente | Nenhum arquivo de teste |
| Tendência real no BalanceCard | ❌ Hardcoded | Sempre exibe 6.2% |
| Upload de avatar | ❌ Ausente | Não modelado |

### 1.3 Débitos técnicos críticos a corrigir junto com o backend

- `TransactionCategory` é um `enum` fixo. Categorias personalizadas precisam ser persistidas no backend e carregadas dinamicamente no app.
- `TransactionController` precisa de método `update()` para edição.
- `AppRoutes` define constantes de rota mas a navegação usa `MaterialPageRoute` direto — inconsistência.
- `BalanceCard.trendPercent` precisa ser calculado pelo backend (% de variação do saldo mês a mês).
- `getRecent()` ordena todos os registros em memória — ineficiente com dados reais; o backend deve retornar já ordenado e paginado.
- A tela de Histórico permite navegar para meses futuros sem restrição — o backend deve retornar listas vazias e o app deve tratar esse estado.

---

## 2. Visão Geral da API

### 2.1 Objetivo

Fornecer uma API RESTful (ou GraphQL) que persista e processe todos os dados financeiros do usuário, garantindo segurança, isolamento de dados por usuário e os cálculos necessários para dashboard e relatórios.

### 2.2 Responsabilidades da API

- Autenticar e autorizar usuários com JWT
- Persistir e recuperar usuários, categorias, transações, investimentos e configurações
- Calcular agregações (totais, médias, tendências) de forma eficiente no servidor
- Enviar notificações push via FCM/APNS
- Gerenciar categorias padrão do sistema e categorias personalizadas por usuário
- Processar regras de recorrência de transações
- Fornecer dados pré-calculados para dashboard e relatórios (evitar cálculos pesados no cliente)

### 2.3 Tecnologias recomendadas

| Camada | Recomendação | Alternativa |
|---|---|---|
| Linguagem | Node.js (TypeScript) / Go | Python (FastAPI) |
| Framework | NestJS / Fastify | Express, Django |
| Banco de dados principal | PostgreSQL | MySQL |
| Cache | Redis | Memcached |
| Autenticação | JWT (access + refresh token) | — |
| Notificações | Firebase Cloud Messaging (FCM) | OneSignal |
| Upload de arquivos | AWS S3 / Cloudflare R2 | Supabase Storage |
| ORM | Prisma (Node) / GORM (Go) | TypeORM |
| Docs | OpenAPI / Swagger | — |

### 2.4 Convenções gerais

- Todas as rotas protegidas requerem header `Authorization: Bearer <access_token>`
- Todos os valores monetários são armazenados e transmitidos em **centavos (inteiro)** para evitar problemas de ponto flutuante
- Datas são sempre em formato **ISO 8601** (`YYYY-MM-DDTHH:mm:ssZ`) em UTC
- O app opera com fuso horário do usuário — o backend deve armazenar o offset ou usar UTC + conversão no cliente
- Paginação padrão: `page` e `limit` como query params; resposta inclui `total`, `page`, `limit`, `totalPages`
- Erros retornam `{ "error": "CÓDIGO_ERRO", "message": "Descrição legível" }`
- IDs são UUIDs v4

---

## 3. Autenticação

### 3.1 Cadastro

**Objetivo:** Criar uma nova conta de usuário.

**Dados de entrada:**
- `name` (string, obrigatório) — nome completo, mínimo 2 caracteres, máximo 100
- `email` (string, obrigatório) — email válido, único no sistema
- `password` (string, obrigatório) — mínimo 8 caracteres, deve conter letra e número
- `timezone` (string, opcional) — fuso horário IANA (ex: `America/Sao_Paulo`); padrão `America/Sao_Paulo`

**Dados de saída:**
- `user` — objeto usuário completo (sem senha)
- `accessToken` — JWT com expiração curta (15 minutos)
- `refreshToken` — token de longa duração (30 dias), deve ser armazenado de forma segura

**Regras de negócio:**
- Email deve ser único; retornar erro `EMAIL_ALREADY_EXISTS` se duplicado
- Senha deve ser armazenada com hash bcrypt (cost ≥ 12)
- Ao cadastrar, criar automaticamente as categorias padrão do sistema para o usuário
- Enviar email de verificação de conta (opcional na v1, obrigatório na v2)

**Validações:**
- `name`: não vazio, sem caracteres especiais excessivos
- `email`: formato RFC 5322 válido
- `password`: ≥ 8 chars, pelo menos 1 letra e 1 número

---

### 3.2 Login

**Objetivo:** Autenticar um usuário existente e iniciar sessão.

**Dados de entrada:**
- `email` (string, obrigatório)
- `password` (string, obrigatório)
- `deviceToken` (string, opcional) — token FCM para notificações push

**Dados de saída:**
- `user` — objeto usuário completo
- `accessToken` — JWT (15 min)
- `refreshToken` — token de sessão (30 dias)

**Regras de negócio:**
- Após 5 tentativas falhas consecutivas, bloquear conta por 15 minutos (rate limiting por IP + por email)
- Registrar `last_login_at` no usuário
- Se `deviceToken` fornecido, associá-lo ao usuário para notificações
- Access token deve incluir no payload: `userId`, `email`, `iat`, `exp`

**Validações:**
- Retornar sempre `INVALID_CREDENTIALS` (nunca indicar se é email ou senha errado)

---

### 3.3 Logout

**Objetivo:** Invalidar a sessão atual do usuário.

**Dados de entrada:**
- `refreshToken` (string, obrigatório no body) — para invalidação explícita

**Dados de saída:**
- `{ "success": true }`

**Regras de negócio:**
- Adicionar o `refreshToken` a uma blacklist (Redis com TTL igual ao tempo restante do token)
- Remover `deviceToken` do usuário para parar notificações push
- O access token continua válido até expirar — por isso o TTL curto é importante

---

### 3.4 Refresh Token

**Objetivo:** Renovar o access token sem novo login.

**Dados de entrada:**
- `refreshToken` (string, obrigatório)

**Dados de saída:**
- `accessToken` — novo JWT (15 min)
- `refreshToken` — novo refresh token (rotação de tokens)

**Regras de negócio:**
- Verificar que o refresh token não está na blacklist
- Verificar que o refresh token não expirou
- Rotacionar: invalidar o refresh token antigo e emitir um novo (proteção contra roubo)
- Se refresh token inválido ou expirado, retornar `401 UNAUTHORIZED` — o app deve redirecionar para login

---

### 3.5 Recuperação de Senha

**Etapa 1 — Solicitar reset:**
- Entrada: `email`
- Comportamento: enviar email com link/código de reset independentemente de o email existir (evitar enumeração de usuários)
- O código/token deve expirar em 1 hora
- Máximo de 3 solicitações por hora por email

**Etapa 2 — Redefinir senha:**
- Entrada: `token` (do email), `newPassword`
- Validar token e expiração
- Atualizar senha com novo hash
- Invalidar todos os refresh tokens do usuário (forçar relogin em todos os dispositivos)

---

### 3.6 Exclusão de Conta

**Objetivo:** Excluir permanentemente a conta e todos os dados associados.

**Dados de entrada:**
- `password` (string, obrigatório) — confirmação de segurança

**Regras de negócio:**
- Verificar senha antes de excluir
- Soft delete: marcar conta como `deleted_at` e anonimizar dados pessoais
- Hard delete: remover após 30 dias (job agendado)
- Invalidar todos os tokens ativos
- Enviar email de confirmação de exclusão

---

## 4. Usuários

### 4.1 Obter perfil do usuário autenticado

**Dados de saída:**
```
{
  id, name, email, avatarUrl,
  phone, timezone, createdAt,
  stats: {
    totalTransactions, monthsTracked, categoriesCreated
  }
}
```

---

### 4.2 Atualizar perfil

**Campos atualizáveis:**
- `name` (string)
- `phone` (string, formato E.164)
- `timezone` (string IANA)
- `avatarUrl` (string, URL após upload separado)

**Regras:**
- Email não pode ser alterado via este endpoint (fluxo separado com verificação)
- Alteração de senha via fluxo próprio (requer senha atual)

---

### 4.3 Upload de avatar

**Entrada:** arquivo de imagem (multipart/form-data)

**Regras:**
- Formatos aceitos: JPG, PNG, WebP
- Tamanho máximo: 5 MB
- Fazer resize para 256×256 px no servidor
- Armazenar em storage de objetos (S3/R2)
- Retornar a URL pública

---

### 4.4 Alterar senha

**Entrada:** `currentPassword`, `newPassword`

**Regras:**
- Validar senha atual
- Invalidar todos os refresh tokens após troca (exceto o dispositivo atual)

---

### 4.5 Alterar email

**Fluxo:**
1. Usuário solicita mudança com `newEmail` e `password`
2. Enviar email de verificação para o novo endereço
3. Confirmar via token
4. Atualizar email no banco

---

## 5. Categorias

As categorias têm dois tipos: **padrão do sistema** (criadas na seed do banco, iguais para todos) e **personalizadas** (criadas pelo usuário via app).

### 5.1 Listar categorias

**Parâmetros de filtro (query):**
- `type` (opcional) — `income`, `expense`, `investment`
- `includeSystem` (boolean, padrão `true`) — incluir categorias padrão

**Dados de saída:** lista de categorias ordenadas por `name`

```
[{
  id, name, type, icon, color,
  isSystem,   // true = padrão, false = personalizada
  userId,     // null se system
  transactionCount,  // quantas transações usam esta categoria
  createdAt
}]
```

**Regras:**
- O app mostra categorias do sistema + categorias personalizadas do usuário autenticado
- Categorias de outros usuários nunca são visíveis

---

### 5.2 Criar categoria personalizada

**Dados de entrada:**
- `name` (string, obrigatório) — máximo 22 caracteres (limite definido no app)
- `type` (enum: `income | expense | investment`, obrigatório)
- `icon` (string, obrigatório) — nome do ícone Material Icons
- `color` (string, obrigatório) — hex color `#RRGGBB`

**Regras de negócio:**
- Nome único por usuário + tipo (não pode ter duas categorias "Alimentação" em "expense")
- Limite de 50 categorias personalizadas por usuário
- Não é possível criar categorias com o mesmo nome das categorias padrão do sistema

**Validações:**
- `color`: formato hex válido `^#[0-9A-Fa-f]{6}$`
- `icon`: deve ser um nome válido da lista de ícones suportados pelo app
- `name`: sem caracteres especiais maliciosos (XSS)

---

### 5.3 Editar categoria personalizada

**Campos atualizáveis:** `name`, `icon`, `color`

**Regras:**
- Não é possível editar `type` de uma categoria (mudaria o histórico)
- Não é possível editar categorias do sistema
- Apenas o dono pode editar

---

### 5.4 Excluir categoria personalizada

**Regras:**
- Não é possível excluir categorias do sistema
- Apenas o dono pode excluir
- Se a categoria possui transações vinculadas, perguntar o que fazer:
  - `reassign_to`: ID de categoria destino (mover todas as transações)
  - `keep_as_deleted`: manter referência histórica (soft delete, categoria não aparece mais para seleção mas transações antigas continuam com ela)
- Padrão se não especificado: `keep_as_deleted`

---

### 5.5 Categorias padrão do sistema (seed)

As categorias abaixo devem existir como dados iniciais no banco. Todas têm `is_system = true` e `user_id = NULL`.

**Gastos (expense):**
- Alimentação (icon: restaurant, color: #F59E0B)
- Moradia (icon: home, color: #3B82F6)
- Transporte (icon: directions_car, color: #42A5F5)
- Saúde (icon: favorite, color: #EC407A)
- Lazer (icon: sports_esports, color: #9961FF)
- Compras (icon: shopping_bag, color: #FF9800)
- Educação (icon: school, color: #66BB6A)
- Outros (icon: category, color: #7B8099)

**Entradas (income):**
- Salário (icon: account_balance_wallet, color: #1BDE7A)
- Freelance (icon: laptop_mac, color: #00BCD4)
- Outros (icon: category, color: #7B8099)

**Investimentos (investment):**
- Investimento (icon: trending_up, color: #9961FF)
- Outros (icon: category, color: #7B8099)

---

## 6. Movimentações

### 6.1 Modelo de dados de uma movimentação

```
{
  id,
  userId,
  title,           // string, máximo 100 chars
  amount,          // inteiro em centavos (ex: R$ 45,90 = 4590)
  type,            // income | expense | investment
  categoryId,      // UUID → categories
  date,            // datetime com timezone
  description,     // string opcional, máximo 500 chars
  recurrenceId,    // UUID → transaction_recurrences (se recorrente)
  installmentId,   // UUID → transaction_installments (se parcelado)
  installmentNumber, // número da parcela (1, 2, 3...)
  totalInstallments, // total de parcelas
  bankAccountId,   // UUID → bank_accounts (opcional)
  createdAt,
  updatedAt,
  deletedAt        // soft delete
}
```

---

### 6.2 Listar movimentações

**Parâmetros de filtro (query):**
- `year` (inteiro) — obrigatório ou `startDate`/`endDate`
- `month` (inteiro, 1–12) — opcional; se ausente, retorna o ano inteiro
- `startDate` / `endDate` — filtro por range de data (alternativo a year/month)
- `type` (enum) — `income | expense | investment | all`
- `categoryId` (UUID) — filtrar por categoria
- `bankAccountId` (UUID) — filtrar por conta
- `search` (string) — busca por título ou descrição (ILIKE)
- `page` (inteiro, padrão 1)
- `limit` (inteiro, padrão 20, máximo 100)
- `sort` (enum) — `date_desc | date_asc | amount_desc | amount_asc`; padrão `date_desc`

**Dados de saída:**
```
{
  data: [Transaction[]],
  pagination: { total, page, limit, totalPages },
  summary: {
    totalIncome,
    totalExpenses,
    totalInvestments,
    balance    // income - expenses
  }
}
```

**Regras:**
- Retornar apenas transações do usuário autenticado
- Soft deleted não aparecem por padrão (incluir param `includeDeleted=true` para admin)
- `summary` é calculado no servidor com base nos filtros aplicados

---

### 6.3 Obter movimentação por ID

**Dados de saída:** objeto Transaction completo com categoria expandida

---

### 6.4 Criar movimentação

**Dados de entrada:**
- `title` (string, obrigatório)
- `amount` (inteiro em centavos, obrigatório, > 0)
- `type` (enum, obrigatório)
- `categoryId` (UUID, obrigatório)
- `date` (datetime, obrigatório)
- `description` (string, opcional)
- `bankAccountId` (UUID, opcional)
- `recurrence` (objeto opcional):
  - `frequency`: `daily | weekly | monthly | yearly`
  - `endDate`: data final (opcional); sem ela é "até cancelar"
- `installments` (objeto opcional):
  - `total`: número de parcelas (2–48)
  - `firstDate`: data da primeira parcela

**Regras de negócio:**
- Se `recurrence` fornecido: criar registro em `transaction_recurrences` e gerar a primeira ocorrência
- Se `installments` fornecido: criar registro em `transaction_installments` e gerar todas as N parcelas de uma vez com datas calculadas (mensal)
- `recurrence` e `installments` são mutuamente exclusivos
- Transações futuras (date > now) são válidas (planejamento)
- `amount` máximo: 999.999.999 centavos (R$ 9.999.999,99 — limite definido no app)

---

### 6.5 Editar movimentação

**Campos atualizáveis:** `title`, `amount`, `categoryId`, `date`, `description`, `bankAccountId`

**Regras:**
- Para transações recorrentes, perguntar escopo:
  - `only_this`: editar só esta ocorrência
  - `this_and_future`: editar esta e todas as futuras
  - `all`: editar todas as ocorrências
- Para transações parceladas: editar apenas a parcela específica

---

### 6.6 Excluir movimentação

**Regras:**
- Soft delete (marcar `deleted_at`)
- Para recorrentes: mesmo escopo de edição (`only_this`, `this_and_future`, `all`)
- Hard delete disponível apenas via solicitação explícita do usuário ou na exclusão de conta

---

### 6.7 Obter movimentações recentes

**Parâmetros:** `limit` (padrão 5, máximo 20)

**Dados de saída:** lista das últimas N transações (qualquer tipo), ordenadas por `date DESC`

---

### 6.8 Transações Recorrentes

**Regras de processamento:**
- Um job agendado (cron) deve rodar diariamente para gerar as próximas ocorrências de transações recorrentes
- Gerar com antecedência de 30 dias
- Se `endDate` atingido, marcar a recorrência como `status = completed`
- O usuário pode pausar (`status = paused`) ou cancelar uma recorrência

---

### 6.9 Parcelamentos

**Regras:**
- Ao criar, gerar todas as parcelas de uma vez com `date` calculado (ex: dia 5 de cada mês)
- Cada parcela é uma `Transaction` independente com `installment_number` e `total_installments`
- Excluir uma parcela não afeta as outras
- Exibir no app: "2/6" indicando parcela atual / total

---

## 7. Investimentos

> Módulo ausente no app atual. A estrutura de dados abaixo deve ser criada no backend e exposta para um módulo de investimentos que será implementado no frontend.

### 7.1 Ativos de investimento

Representa um tipo de ativo no portfólio do usuário (ex: "ITSA4", "Tesouro Selic 2029").

**Campos:**
- `id`, `userId`
- `name` — nome do ativo (ex: "ITSA4", "CDB Banco X")
- `ticker` — código opcional (ex: "ITSA4")
- `type` — `stocks | fixed_income | crypto | funds | real_estate | other`
- `institution` — corretora/banco (string)
- `currency` — padrão `BRL`
- `notes` (opcional)
- `createdAt`

---

### 7.2 Aportes (entradas de investimento)

Cada vez que o usuário aporta em um ativo.

**Campos:**
- `id`, `userId`, `assetId`
- `amount` (inteiro em centavos)
- `quantity` (decimal) — quantidade de cotas/ações compradas (opcional)
- `unitPrice` (inteiro em centavos) — preço por unidade (opcional)
- `date`
- `transactionId` — vínculo opcional com uma `Transaction` do tipo investment
- `notes` (opcional)

---

### 7.3 Valorização / Posição atual

A API deve fornecer um endpoint de posição atual do portfólio:

**Dados de saída (por ativo):**
```
{
  assetId, name, type,
  totalInvested,      // soma dos aportes em centavos
  currentValue,       // valor atual (informado manualmente ou via integração)
  returnAmount,       // currentValue - totalInvested
  returnPercent,      // (returnAmount / totalInvested) * 100
  quantity,           // total de cotas
  lastUpdatedAt
}
```

**Dados de saída (portfólio total):**
```
{
  totalInvested,
  currentValue,
  returnAmount,
  returnPercent,
  allocationByType: [{ type, value, percent }]
}
```

---

### 7.4 Histórico de evolução patrimonial

**Parâmetros:** `period` (enum: `3m | 6m | 1y | all`)

**Dados de saída:** série temporal com `date` e `totalInvested` por ponto

---

## 8. Dashboard

> O app calcula tudo em memória a partir dos dados mockados. Com backend, o dashboard deve ser fornecido via endpoints dedicados com dados pré-calculados para melhor performance.

### 8.1 Resumo do mês atual

**Dados de saída:**
```
{
  period: { year, month },
  balance: {
    current,          // saldo = income - expense
    trend: {
      percent,        // variação % em relação ao mês anterior
      direction       // up | down | neutral
    }
  },
  income: {
    total,
    transactionCount
  },
  expenses: {
    total,
    transactionCount
  },
  investments: {
    total,
    transactionCount
  }
}
```

**Regras de cálculo:**
- `balance = income.total - expenses.total` (investimentos não entram no saldo)
- `trend.percent = ((currentBalance - previousBalance) / abs(previousBalance)) * 100`
- Se mês anterior tem saldo zero, trend é `neutral`

---

### 8.2 Fluxo diário (gráfico de barras semanal)

**Parâmetros:** `startDate`, `endDate` (range de 7 dias por padrão)

**Dados de saída:**
```
[{
  date,           // YYYY-MM-DD
  income,         // total em centavos
  expense,        // total em centavos
  dayOfWeek       // 0=Dom ... 6=Sáb
}]
```

---

### 8.3 Transações recentes

**Parâmetros:** `limit` (padrão 5)

**Dados de saída:** lista de transações com categoria expandida, ordenadas por `date DESC`

---

## 9. Relatórios

### 9.1 Gráfico de Entradas vs Gastos por período

**Parâmetros:**
- `period` (enum: `week | month | year`, obrigatório)
  - `week`: últimas 4 semanas (agrupado por semana)
  - `month`: últimos 6 meses (agrupado por mês)
  - `year`: últimos 3 anos (agrupado por ano)
- `referenceDate` (date, opcional) — data de referência; padrão hoje

**Dados de saída:**
```
[{
  label,         // ex: "Jan", "Fev", "2024", "Sem 1"
  startDate,
  endDate,
  income,
  expense,
  investment
}]
```

---

### 9.2 Gastos por categoria

**Parâmetros:**
- `year` (inteiro, obrigatório)
- `month` (inteiro, opcional; se ausente, considera o ano inteiro)
- `type` (enum: `expense | income | investment`; padrão `expense`)

**Dados de saída:**
```
{
  total,
  categories: [{
    categoryId, categoryName, categoryColor,
    amount,
    percent,        // amount / total * 100
    transactionCount
  }],
  // Apenas as top N (configurável), demais agrupados em "Outros"
  topN: 5
}
```

---

### 9.3 Insight de gastos

**Dados de saída:**
```
{
  currentMonth: { expense, income, balance },
  previousMonth: { expense, income, balance },
  expenseVariation: {
    amount,     // diferença em centavos
    percent,    // variação %
    direction   // up | down | neutral
  },
  message,      // texto gerado no servidor (ex: "Você gastou 12% menos que no mês anterior")
  sentiment     // positive | negative | neutral
}
```

---

### 9.4 Relatório por período customizado

**Parâmetros:** `startDate`, `endDate`, `groupBy` (enum: `day | week | month`)

**Dados de saída:** série temporal + totais por tipo + breakdown por categoria

---

### 9.5 Relatório de investimentos

**Parâmetros:** `period` (enum: `3m | 6m | 1y | all`)

**Dados de saída:**
```
{
  totalInvested,
  evolution: [{date, value}],
  byType: [{type, amount, percent}],
  byCategory: [{categoryId, categoryName, amount, percent}]
}
```

---

## 10. Notificações

### 10.1 Registro de dispositivo

**Dados de entrada:**
- `deviceToken` (string) — token FCM/APNS
- `platform` (enum: `android | ios`)

**Regras:**
- Um usuário pode ter múltiplos dispositivos
- Ao fazer logout, remover o token do dispositivo

---

### 10.2 Eventos que disparam notificações

| Evento | Trigger | Mensagem |
|---|---|---|
| Meta de gastos atingida | 80% do limite mensal gasto | "Você já usou 80% do seu orçamento de [categoria]" |
| Meta de gastos excedida | 100% atingido | "Limite de [categoria] excedido este mês" |
| Transação recorrente gerada | Criação da ocorrência | "Lançamento automático: [título] - R$ [valor]" |
| Próxima parcela | 1 dia antes da data | "Amanhã vence a parcela [N/total] de [título]" |
| Meta de economia atingida | Saldo acumulado ≥ meta | "Parabéns! Você atingiu sua meta de [nome]" |
| Resumo semanal | Todo domingo | Resumo de gastos da semana |
| Resumo mensal | Dia 1 do mês | Resumo do mês anterior |

---

### 10.3 Preferências de notificação

O usuário deve poder ativar/desativar cada tipo de notificação individualmente. Estas preferências são persistidas no banco (tabela `user_settings`).

---

## 11. Configurações

### 11.1 Preferências do usuário

**Campos persistidos:**
- `theme` — `dark | light | system` (padrão `dark`)
- `currency` — código ISO (padrão `BRL`)
- `language` — locale (padrão `pt_BR`)
- `timezone` — fuso IANA (padrão `America/Sao_Paulo`)
- `weekStartsOn` — `0=domingo | 1=segunda` (padrão `1`)
- Notificações (objeto):
  - `weeklyReport` (boolean)
  - `monthlyReport` (boolean)
  - `spendingAlerts` (boolean)
  - `recurringReminders` (boolean)
  - `installmentReminders` (boolean)
  - `goalAlerts` (boolean)

---

### 11.2 Metas de economia

> Módulo a ser implementado no frontend. Backend já deve suportar os dados.

**Campos:**
- `id`, `userId`
- `name` — ex: "Viagem para Europa"
- `targetAmount` (inteiro em centavos)
- `currentAmount` (inteiro em centavos) — calculado ou atualizado manualmente
- `deadline` (date, opcional)
- `icon` (string)
- `color` (string hex)
- `status` — `active | completed | cancelled`
- `createdAt`, `updatedAt`

---

### 11.3 Contas bancárias

> Módulo a ser implementado no frontend.

**Campos:**
- `id`, `userId`
- `name` — ex: "Nubank", "Bradesco"
- `type` — `checking | savings | investment | wallet | other`
- `institution` (string)
- `initialBalance` (inteiro em centavos)
- `color` (string hex)
- `icon` (string)
- `isDefault` (boolean)
- `createdAt`

---

## 12. Modelagem do Banco de Dados

### Convenções

- Todos os IDs são `UUID` (versão 4)
- `created_at` e `updated_at` em todas as tabelas (auto-gerenciados pelo banco)
- `deleted_at` nas tabelas com soft delete
- Valores monetários armazenados em `BIGINT` (centavos)
- Campos de texto `VARCHAR` com limites definidos
- Campos de data `TIMESTAMPTZ` (com fuso horário)

---

### Tabela: `users`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK, NOT NULL | Identificador único |
| `name` | VARCHAR(100) | NOT NULL | Nome completo |
| `email` | VARCHAR(254) | NOT NULL, UNIQUE | Email de acesso |
| `password_hash` | VARCHAR(255) | NOT NULL | Hash bcrypt da senha |
| `avatar_url` | VARCHAR(500) | NULL | URL do avatar |
| `phone` | VARCHAR(20) | NULL | Telefone formato E.164 |
| `timezone` | VARCHAR(50) | NOT NULL, DEFAULT `America/Sao_Paulo` | Fuso IANA |
| `email_verified_at` | TIMESTAMPTZ | NULL | Data de verificação do email |
| `last_login_at` | TIMESTAMPTZ | NULL | Último acesso |
| `status` | VARCHAR(20) | NOT NULL, DEFAULT `active` | `active`, `suspended`, `deleted` |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT now() | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL, DEFAULT now() | — |
| `deleted_at` | TIMESTAMPTZ | NULL | Soft delete |

**Índices:**
- `idx_users_email` UNIQUE on `(email)` where `deleted_at IS NULL`

---

### Tabela: `refresh_tokens`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | Dono do token |
| `token_hash` | VARCHAR(255) | NOT NULL, UNIQUE | Hash SHA-256 do token |
| `device_token` | VARCHAR(500) | NULL | Token FCM associado |
| `expires_at` | TIMESTAMPTZ | NOT NULL | Validade |
| `revoked_at` | TIMESTAMPTZ | NULL | Data de revogação |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |

**Índices:**
- `idx_refresh_tokens_user_id` on `(user_id)`
- `idx_refresh_tokens_hash` UNIQUE on `(token_hash)`

---

### Tabela: `password_reset_tokens`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id | — |
| `token_hash` | VARCHAR(255) | NOT NULL | Hash do token enviado por email |
| `expires_at` | TIMESTAMPTZ | NOT NULL | 1 hora após criação |
| `used_at` | TIMESTAMPTZ | NULL | Marcado ao usar |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |

---

### Tabela: `device_tokens`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `token` | VARCHAR(500) | NOT NULL | Token FCM/APNS |
| `platform` | VARCHAR(10) | NOT NULL | `android` ou `ios` |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

**Índices:**
- `idx_device_tokens_user_id` on `(user_id)` where `is_active = true`
- `idx_device_tokens_token` UNIQUE on `(token)`

---

### Tabela: `categories`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NULL | NULL = categoria do sistema |
| `name` | VARCHAR(22) | NOT NULL | Limite definido no app |
| `type` | VARCHAR(15) | NOT NULL | `income`, `expense`, `investment` |
| `icon` | VARCHAR(100) | NOT NULL | Nome do ícone Material |
| `color` | VARCHAR(7) | NOT NULL | Hex `#RRGGBB` |
| `is_system` | BOOLEAN | NOT NULL, DEFAULT false | true = padrão do sistema |
| `sort_order` | SMALLINT | NOT NULL, DEFAULT 0 | Ordem de exibição |
| `deleted_at` | TIMESTAMPTZ | NULL | Soft delete (personalizadas) |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

**Índices:**
- `idx_categories_user_id` on `(user_id)` where `deleted_at IS NULL`
- `idx_categories_type` on `(type)`
- `UNIQUE (user_id, name, type)` where `deleted_at IS NULL` — nome único por usuário+tipo

**Relacionamentos:**
- `user_id` → `users.id` (NULL para categorias do sistema)

---

### Tabela: `bank_accounts`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `name` | VARCHAR(100) | NOT NULL | Ex: "Nubank" |
| `type` | VARCHAR(20) | NOT NULL | `checking`, `savings`, `investment`, `wallet`, `other` |
| `institution` | VARCHAR(100) | NULL | Nome do banco |
| `initial_balance` | BIGINT | NOT NULL, DEFAULT 0 | Saldo inicial em centavos |
| `color` | VARCHAR(7) | NULL | Hex color |
| `icon` | VARCHAR(100) | NULL | Nome do ícone |
| `is_default` | BOOLEAN | NOT NULL, DEFAULT false | Conta padrão |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |
| `deleted_at` | TIMESTAMPTZ | NULL | — |

**Índices:**
- `idx_bank_accounts_user_id` on `(user_id)` where `deleted_at IS NULL`

---

### Tabela: `transaction_recurrences`

Configuração de uma regra de recorrência. As transações geradas apontam para esta tabela.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `frequency` | VARCHAR(10) | NOT NULL | `daily`, `weekly`, `monthly`, `yearly` |
| `start_date` | DATE | NOT NULL | Primeira ocorrência |
| `end_date` | DATE | NULL | Última ocorrência (NULL = sem fim) |
| `status` | VARCHAR(10) | NOT NULL, DEFAULT `active` | `active`, `paused`, `completed`, `cancelled` |
| `next_occurrence_date` | DATE | NULL | Calculado — próxima data a gerar |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

---

### Tabela: `transaction_installments`

Configuração de um parcelamento. As parcelas geradas apontam para esta tabela.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `total_installments` | SMALLINT | NOT NULL | Número total de parcelas |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |

---

### Tabela: `transactions`

Tabela principal. Centraliza todos os tipos de movimentação.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `title` | VARCHAR(100) | NOT NULL | Título da transação |
| `amount` | BIGINT | NOT NULL, CHECK > 0 | Valor em centavos |
| `type` | VARCHAR(15) | NOT NULL | `income`, `expense`, `investment` |
| `category_id` | UUID | FK → categories.id, NOT NULL | — |
| `bank_account_id` | UUID | FK → bank_accounts.id, NULL | Conta vinculada |
| `date` | TIMESTAMPTZ | NOT NULL | Data/hora da transação |
| `description` | VARCHAR(500) | NULL | Descrição opcional |
| `recurrence_id` | UUID | FK → transaction_recurrences.id, NULL | Se recorrente |
| `installment_id` | UUID | FK → transaction_installments.id, NULL | Se parcelado |
| `installment_number` | SMALLINT | NULL | Número da parcela atual |
| `total_installments` | SMALLINT | NULL | Total de parcelas (desnormalizado para exibição) |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |
| `deleted_at` | TIMESTAMPTZ | NULL | Soft delete |

**Índices:**
- `idx_transactions_user_id_date` on `(user_id, date DESC)` where `deleted_at IS NULL`
- `idx_transactions_user_type_date` on `(user_id, type, date DESC)` where `deleted_at IS NULL`
- `idx_transactions_category_id` on `(category_id)`
- `idx_transactions_recurrence_id` on `(recurrence_id)` where `recurrence_id IS NOT NULL`
- `idx_transactions_installment_id` on `(installment_id)` where `installment_id IS NOT NULL`
- `idx_transactions_user_year_month` on `(user_id, EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date))` where `deleted_at IS NULL`

**Relacionamentos:**
- `user_id` → `users.id`
- `category_id` → `categories.id`
- `bank_account_id` → `bank_accounts.id`
- `recurrence_id` → `transaction_recurrences.id`
- `installment_id` → `transaction_installments.id`

**Restrições:**
- `recurrence_id` e `installment_id` são mutuamente exclusivos (CHECK constraint ou validação na API)

---

### Tabela: `investment_assets`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `name` | VARCHAR(100) | NOT NULL | Nome do ativo |
| `ticker` | VARCHAR(20) | NULL | Código do ativo (ex: ITSA4) |
| `type` | VARCHAR(20) | NOT NULL | `stocks`, `fixed_income`, `crypto`, `funds`, `real_estate`, `other` |
| `institution` | VARCHAR(100) | NULL | Corretora/banco |
| `currency` | VARCHAR(3) | NOT NULL, DEFAULT `BRL` | ISO 4217 |
| `notes` | TEXT | NULL | — |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |
| `deleted_at` | TIMESTAMPTZ | NULL | — |

**Índices:**
- `idx_investment_assets_user_id` on `(user_id)` where `deleted_at IS NULL`

---

### Tabela: `investment_entries`

Cada aporte realizado pelo usuário em um ativo.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `asset_id` | UUID | FK → investment_assets.id, NOT NULL | — |
| `transaction_id` | UUID | FK → transactions.id, NULL | Vínculo com transação |
| `amount` | BIGINT | NOT NULL, CHECK > 0 | Valor aportado em centavos |
| `quantity` | DECIMAL(18,8) | NULL | Cotas/ações adquiridas |
| `unit_price` | BIGINT | NULL | Preço unitário em centavos |
| `date` | TIMESTAMPTZ | NOT NULL | Data do aporte |
| `notes` | VARCHAR(500) | NULL | — |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |

**Índices:**
- `idx_investment_entries_asset_id` on `(asset_id)`
- `idx_investment_entries_user_date` on `(user_id, date DESC)`

---

### Tabela: `investment_valuations`

Posição atual de um ativo (atualizada manualmente ou via integração futura).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `asset_id` | UUID | FK → investment_assets.id, NOT NULL | — |
| `current_value` | BIGINT | NOT NULL | Valor atual total em centavos |
| `valuation_date` | DATE | NOT NULL | Data de referência |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |

**Índice:** `UNIQUE (asset_id, valuation_date)`

---

### Tabela: `financial_goals`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `name` | VARCHAR(100) | NOT NULL | Ex: "Viagem" |
| `target_amount` | BIGINT | NOT NULL, CHECK > 0 | Meta em centavos |
| `current_amount` | BIGINT | NOT NULL, DEFAULT 0 | Progresso atual |
| `deadline` | DATE | NULL | — |
| `icon` | VARCHAR(100) | NULL | — |
| `color` | VARCHAR(7) | NULL | Hex color |
| `status` | VARCHAR(15) | NOT NULL, DEFAULT `active` | `active`, `completed`, `cancelled` |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

**Índices:**
- `idx_financial_goals_user_id` on `(user_id)` where `status = 'active'`

---

### Tabela: `user_settings`

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL, UNIQUE | — |
| `theme` | VARCHAR(10) | NOT NULL, DEFAULT `dark` | `dark`, `light`, `system` |
| `currency` | VARCHAR(3) | NOT NULL, DEFAULT `BRL` | ISO 4217 |
| `language` | VARCHAR(10) | NOT NULL, DEFAULT `pt_BR` | Locale |
| `timezone` | VARCHAR(50) | NOT NULL, DEFAULT `America/Sao_Paulo` | — |
| `week_starts_on` | SMALLINT | NOT NULL, DEFAULT 1 | 0=Dom, 1=Seg |
| `notif_weekly_report` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `notif_monthly_report` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `notif_spending_alerts` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `notif_recurring_reminders` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `notif_installment_reminders` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `notif_goal_alerts` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

---

### Tabela: `spending_limits`

Limites mensais de gasto por categoria (base para notificações de alerta).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `category_id` | UUID | FK → categories.id, NOT NULL | — |
| `monthly_limit` | BIGINT | NOT NULL, CHECK > 0 | Limite mensal em centavos |
| `alert_at_percent` | SMALLINT | NOT NULL, DEFAULT 80 | Percentual para alertar |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | — |
| `created_at` | TIMESTAMPTZ | NOT NULL | — |
| `updated_at` | TIMESTAMPTZ | NOT NULL | — |

**Índice:** `UNIQUE (user_id, category_id)` where `is_active = true`

---

### Tabela: `notification_logs`

Registro de notificações enviadas (para evitar duplicatas e para auditoria).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | UUID | PK | — |
| `user_id` | UUID | FK → users.id, NOT NULL | — |
| `type` | VARCHAR(50) | NOT NULL | `spending_alert`, `goal_reached`, `recurring`, etc. |
| `title` | VARCHAR(200) | NOT NULL | Título da notificação |
| `body` | VARCHAR(500) | NOT NULL | Corpo da mensagem |
| `reference_id` | UUID | NULL | ID do objeto relacionado |
| `sent_at` | TIMESTAMPTZ | NOT NULL | — |
| `read_at` | TIMESTAMPTZ | NULL | — |

**Índice:** `idx_notification_logs_user_id` on `(user_id, sent_at DESC)`

---

### Diagrama de Relacionamentos (textual)

```
users
  ├── 1:N → refresh_tokens
  ├── 1:N → device_tokens
  ├── 1:N → categories (user_id nullable — NULL = sistema)
  ├── 1:N → bank_accounts
  ├── 1:N → transactions
  │           ├── N:1 → categories
  │           ├── N:1 → bank_accounts (opcional)
  │           ├── N:1 → transaction_recurrences (opcional)
  │           └── N:1 → transaction_installments (opcional)
  ├── 1:N → investment_assets
  │           └── 1:N → investment_entries
  │                         └── N:1 → transactions (opcional)
  │           └── 1:N → investment_valuations
  ├── 1:N → financial_goals
  ├── 1:N → spending_limits
  │           └── N:1 → categories
  ├── 1:1 → user_settings
  └── 1:N → notification_logs
```

---

## Apêndice — Observações para Implementação

### Segurança
- Todas as queries devem filtrar por `user_id` do token JWT — nunca confiar em IDs enviados pelo cliente sem validar a propriedade
- Rate limiting nas rotas de auth (login, register, password reset)
- Não expor stack traces ou mensagens de erro do banco na API
- Usar `HTTPS` apenas em produção
- Tokens JWT assinados com chave assimétrica RS256 (não HS256)

### Performance
- Criar índices compostos nas queries mais frequentes (`user_id + date`, `user_id + type + date`)
- Dashboard e relatórios devem usar views materializadas ou cache Redis (TTL: 5 minutos)
- Paginação obrigatória em todos os endpoints de listagem
- Evitar `SELECT *` — selecionar apenas colunas necessárias

### Jobs agendados necessários
| Job | Frequência | Descrição |
|---|---|---|
| `generate_recurrences` | Diariamente 00:01 | Gerar próximas ocorrências de transações recorrentes |
| `check_spending_limits` | Diariamente | Verificar limites atingidos e enviar push |
| `send_weekly_report` | Domingo 08:00 | Relatório semanal por push |
| `send_monthly_report` | Dia 1 08:00 | Relatório mensal por push |
| `send_installment_reminders` | Diariamente | Lembrar parcelas com vencimento amanhã |
| `cleanup_deleted_users` | Semanalmente | Hard delete de usuários com `deleted_at` > 30 dias |
| `cleanup_expired_tokens` | Diariamente | Limpar refresh tokens expirados |

### Versionamento da API
- Usar prefixo de versão: `/api/v1/`
- Manter compatibilidade retroativa ao evoluir endpoints

---

*Documento gerado em 2026-05-31. Revisão recomendada a cada sprint conforme o app evolui.*

# Code Review — FinanciApp
> Análise técnica completa do estado atual do projeto Flutter.
> Data: 2026-05-31 · Revisão: pós todas as implementações de UI/UX.

---

## 1. Resumo Executivo

| Dimensão | Nota | Justificativa |
|---|---|---|
| **Arquitetura** | 6.5 / 10 | Estrutura correta mas com skeleton auth sem implementação, CRUD incompleto, Service Locator manual sem injeção real |
| **Qualidade de Código** | 6.0 / 10 | Boas práticas parciais: widgets privados bem separados em alguns arquivos, mas código duplicado, widgets criados e nunca usados, valores hardcoded |
| **Organização** | 7.5 / 10 | Feature-first bem aplicado, nomenclatura consistente, design system sólido |
| **Escalabilidade** | 5.5 / 10 | Funciona bem até ~200 transações; enum fixo de categorias, controller único, sem testes e sem paginação são bloqueantes para escalar |

---

## 2. Problemas Encontrados

### 🔴 Críticos

---

#### C-01 — `CreateCategoryScreen` não persiste dados
**Arquivo:** `lib/features/categories/presentation/screens/create_category_screen.dart:100`

**Problema:** O botão "Criar categoria" executa apenas `Navigator.pop(context)`. Nenhuma categoria criada é salva em lugar algum.

**Impacto:** Funcionalidade completamente quebrada do ponto de vista do usuário. A tela existe, permite interação, mas ao sair o resultado é descartado silenciosamente.

**Causa:** `TransactionCategory` é um `enum` fixo e imutável. Não existe mecanismo de persistência para categorias dinâmicas.

**Solução:** Criar `CategoryRepository` e `CategoryController` análogos aos de transações. O `enum TransactionCategory` precisa ser substituído por uma entidade `Category` com `id`, `name`, `icon`, `color` e `type`. Enquanto o backend não existe, criar `MockCategoryRepository`. A `CreateCategoryScreen` deve chamar `categoryController.add(newCategory)`.

---

#### C-02 — Abas de período em Relatórios completamente não funcionais
**Arquivo:** `lib/features/reports/presentation/screens/reports_screen.dart:9,19`

**Problema:** O widget `_PeriodTabs` renderiza e aceita cliques (`_period` muda de estado), mas `_buildBarSection()` e `_buildPieSection()` ignoram completamente `_period`. Os dados mostrados são sempre os mesmos independente do que o usuário seleciona.

**Impacto:** O usuário clica nas abas "Semana", "Mês", "Ano" e nada muda. Isso quebra a confiança na interface — parece um bug grave ou um app inacabado.

**Causa:** A lógica de filtro por período nunca foi implementada para conectar `_period` às queries.

**Solução:**
```dart
// Semana: últimas 4 semanas (agrupado por semana)
// Mês: últimos 6 meses (agrupado por mês — comportamento atual)
// Ano: últimos 3 anos (agrupado por ano)
```
Criar método `_buildGroups()` que retorna diferentes datasets com base em `_period`, e passar para `_buildBarSection`. O `_buildPieSection` também deve filtrar por período.

---

#### C-03 — Autenticação não existe
**Arquivos:** `auth_service.dart`, `auth_repository.dart`, `routes.dart`, `dio_client.dart`

**Problema:** Todo o módulo de autenticação é composto por interfaces abstratas sem implementação. Não existem telas de login/cadastro. O router não tem guarda de rotas (`routes.dart` está completamente vazio). Qualquer pessoa com o app instalado acessa todos os dados.

**Impacto:** Bloqueante para produção. Dados sensíveis (financeiros) sem qualquer autenticação.

**Causa:** Funcionalidade nunca foi implementada — apenas o esqueleto foi criado.

**Solução:** Implementar `AuthController`, telas de `LoginScreen` e `RegisterScreen`, rota guard no GoRouter (`redirect` callback) e armazenamento do token via `flutter_secure_storage`.

---

#### C-04 — Operação de Update ausente em toda a stack
**Arquivos:** `transaction_repository.dart:1`, `transaction_controller.dart:1`, `mock_transaction_repository.dart:1`

**Problema:** A interface `TransactionRepository` não declara `update()`. O controller não tem `update()`. A `TransactionTile` tem botão de "mais opções" que chama diretamente `onDelete` — sem possibilidade de edição.

**Impacto:** O usuário não consegue corrigir um valor errado, mudar uma categoria ou ajustar uma data. Delete e recriação manual é a única alternativa.

**Solução:**
```dart
// TransactionRepository
void update(Transaction transaction);

// MockTransactionRepository
@override
void update(Transaction t) {
  final idx = _data.indexWhere((d) => d.id == t.id);
  if (idx != -1) _data[idx] = t;
}

// TransactionController
void update(Transaction t) {
  _repo.update(t);
  notifyListeners();
}
```
Criar `EditTransactionScreen` acessível via toque longo ou ícone na `TransactionTile`.

---

### 🟠 Altos

---

#### A-01 — `trendPercent` hardcoded em `BalanceCard`
**Arquivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart:44`

**Problema:** `BalanceCard(balance: balance, trendPercent: 6.2)` — o valor `6.2` é um literal fixo. O card sempre exibe "+6.2% este mês" independentemente dos dados reais.

**Impacto:** Informação falsa exibida ao usuário. Viola a confiabilidade do app financeiro.

**Causa:** O cálculo real da tendência não foi implementado.

**Solução:**
```dart
final prevBalance = ctrl.getTotalByType(TransactionType.income, year: now.year, month: now.month - 1)
                  - ctrl.getTotalByType(TransactionType.expense, year: now.year, month: now.month - 1);
final trend = prevBalance != 0 ? ((balance - prevBalance) / prevBalance.abs() * 100) : 0.0;
BalanceCard(balance: balance, trendPercent: trend)
```

---

#### A-02 — `HistoryScreen` permite navegar para meses futuros
**Arquivo:** `lib/features/transactions/presentation/screens/history_screen.dart:29`

**Problema:** O botão `→` em `_MonthSelector` não tem limite superior. O usuário pode navegar para meses que não existem (2027, 2030…), vendo apenas "Nenhuma transação neste período".

**Impacto:** UX confusa. Usuário pode pensar que há um bug ou que os dados sumiram.

**Solução:**
```dart
void _next() {
  final now = DateTime.now();
  if (_month.year < now.year || (_month.year == now.year && _month.month < now.month)) {
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }
}
```
Também desabilitar o ícone visualmente quando no mês atual.

---

#### A-03 — `TransactionTile` usa ícone errado para deletar sem confirmação
**Arquivo:** `lib/features/transactions/presentation/widgets/transaction_tile.dart:47`

**Problema:** `Icons.more_horiz_rounded` (três pontos horizontais) é universalmente reconhecido como "mais opções / menu contextual". No código, tocar nesse ícone executa imediatamente `onDelete()` sem qualquer diálogo de confirmação.

**Impacto duplo:**
1. **UX:** Usuário que toca nos três pontos esperando um menu perde a transação imediatamente.
2. **Dado perdido:** Sem confirmação, deleção acidental é irreversível.

**Solução:** Implementar `showModalBottomSheet` ou `AlertDialog` de confirmação antes de executar `onDelete`. Considerar mudar o ícone para `Icons.delete_outline_rounded` ou usar swipe-to-delete (`Dismissible`).

---

#### A-04 — `_TypeSelector` duplicado em dois arquivos
**Arquivos:** `add_transaction_screen.dart:135` e `create_category_screen.dart:196`

**Problema:** A classe `_TypeSelector` foi implementada duas vezes com código idêntico (mesma lógica, mesmos estilos, mesma estrutura).

**Impacto:** Qualquer mudança de design precisa ser aplicada em dois lugares. Inconsistências vão surgir quando um for atualizado e o outro não.

**Solução:** Mover para `lib/features/transactions/presentation/widgets/type_selector.dart` e importar em ambas as telas.

---

#### A-05 — Comportamento inconsistente de `ListenableBuilder`
**Arquivos:** `dashboard_screen.dart`, `history_screen.dart`, `reports_screen.dart`

**Problema:** Cada uma dessas telas envolve o `Scaffold` inteiro em um `ListenableBuilder`. Qualquer adição ou deleção de transação reconstrói a tela inteira, incluindo `AppBar`, `SafeArea`, `CustomScrollView` e todos os widgets filhos — mesmo os que não dependem dos dados.

**Impacto:** Performance degradada. Em dispositivos mais lentos, o usuário pode perceber janks ao adicionar transações.

**Solução:** Mover o `ListenableBuilder` para envolver apenas os widgets que realmente dependem dos dados:
```dart
// Em vez de:
return ListenableBuilder(
  listenable: Injector.transactionController,
  builder: (context, _) => Scaffold(...)  // reconstrói tudo
);

// Preferir:
return Scaffold(
  body: ListenableBuilder(
    listenable: Injector.transactionController,
    builder: (context, _) => ...  // reconstrói só o conteúdo
  )
);
```

---

#### A-06 — `Injector` como static Service Locator sem suporte a testes
**Arquivo:** `lib/core/di/service_locator.dart`

**Problema:** `Injector.transactionController` e `Injector.transactionRepository` são campos `static late final`. Não há mecanismo para:
- Substituir dependências em testes
- Registrar implementações alternativas em runtime
- Injeção com escopo (por sessão de usuário)
- Lazy initialization (controladores são criados na startup mesmo se não usados)

**Impacto:** Impossível escrever testes unitários para os controllers e screens sem modificar o código de produção. Violarão SOLID quando o projeto crescer.

**Solução:** Migrar para `get_it` (service locator maduro com suporte a reset e factory) ou `provider`/`riverpod` (DI por árvore de widgets com suporte nativo a testing via `overrides`).

---

### 🟡 Médios

---

#### M-01 — 5 widgets de core nunca utilizados (dead code)
**Arquivos:** `app_card.dart`, `app_scaffold.dart`, `custom_button.dart`, `custom_input.dart`, `loading_widget.dart`

**Problema:** Esses arquivos foram criados como parte da estrutura inicial mas nenhum widget dentro deles é importado ou usado em qualquer tela.

**Impacto:** Aumenta o tamanho da base de código sem valor. Confunde contribuidores ("este componente é para usar ou está obsoleto?"). O `loading_widget.dart` em particular deveria estar sendo usado nas telas mas não está.

**Solução:** Ou deletar completamente esses arquivos ou começar a utilizá-los onde são relevantes. O `custom_button.dart` deveria substituir os `ElevatedButton` inline nas telas. O `loading_widget.dart` deveria ser exibido durante operações de rede futuras.

---

#### M-02 — `AppRoutes`, `route_names.dart` e `date_formatter.dart` nunca usados
**Arquivos:** `app_constants.dart` (AppRoutes), `route_names.dart`, `core/utils/date_formatter.dart`

**Problema:** `AppRoutes.home` e `AppRoutes.addTransaction` são constantes definidas mas nunca referenciadas. `route_names.dart` tem constantes de rotas independentes (`home`, `addTransaction`, `login`, `register`) que também não são usadas. `date_formatter.dart` define formatações de data mas todas as telas usam `DateFormat` de `intl` diretamente.

**Impacto:** Dead code, confusão sobre qual constante usar, overhead de manutenção.

**Solução:** Consolidar em um único arquivo de rotas e garantir uso consistente.

---

#### M-03 — `DashboardScreen._Header` hardcodea o nome "Ian"
**Arquivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart:87`

**Problema:** `Text('$greeting, Ian', style: AppTextStyles.h2)` — o nome do usuário está hardcoded.

**Impacto:** Quando a autenticação for implementada, essa linha precisa ser lembrada e atualizada.

**Solução:** Usar `User` entity via controller: `'$greeting, ${user.name.split(' ').first}'`.

---

#### M-04 — `BalanceCard` usa cores fora do `AppColors`
**Arquivo:** `lib/features/dashboard/presentation/widgets/balance_card.dart:19`

**Problema:** O gradiente usa `Color(0xFF1A2140)` e `Color(0xFF242B52)` diretamente, cores que não existem em `AppColors`.

**Impacto:** Se o tema do app mudar, esses valores ficam esquecidos e divergem do restante.

**Solução:** Adicionar `static const cardGradientStart = Color(0xFF1A2140)` e `cardGradientEnd = Color(0xFF242B52)` em `AppColors`.

---

#### M-05 — `FlowChart` duplica cálculo de período já feito no Dashboard
**Arquivos:** `dashboard_screen.dart:29` e `flow_chart.dart:65`

**Problema:** `dashboard_screen.dart` calcula `weekTxs = ctrl.getByDateRange(now.subtract(Duration(days: 6)), now)` e passa para `FlowChart`. Internamente, `FlowChart._buildGroups()` re-filtra cada transação por `day.year == t.date.year && ...` para agrupar por dia.

**Impacto menor mas real:** Filtragem O(7*n) onde n = transações da semana, feita a cada rebuild do widget.

**Solução:** O `FlowChart` poderia receber dados já agrupados por dia, ou o controller poderia oferecer `getDailyTotals(startDate, endDate)`.

---

#### M-06 — `more_screen.dart` com dados hardcoded de perfil
**Arquivo:** `lib/features/profile/presentation/screens/more_screen.dart:57`

**Problema:** `CircleAvatar` com texto `'I'` hardcoded, nome `'Ian'` hardcoded, email `'ian@email.com'` hardcoded.

**Solução:** Ler do `User` entity futuro, ou via `StorageService` para as chaves já definidas em `StorageKeys`.

---

#### M-07 — `cupertino_icons` no pubspec sem uso
**Arquivo:** `pubspec.yaml:34`

**Problema:** `cupertino_icons: ^1.0.8` é dependência declarada mas o projeto usa exclusivamente `Icons.*` (Material).

**Solução:** Remover da seção `dependencies`.

---

#### M-08 — Comparação de `Color` inconsistente
**Arquivos:** `create_category_screen.dart` e `color_picker_screen.dart`

**Problema:** Em `_quickColors()` usa-se `c.value != _selectedColor.value`, mas no `Wrap` do build usa `_selectedColor.value == c.value`. Em `ColorPickerScreen` também usa `.value`. `Color` em Flutter implementa `==` por valor, então `c == _selectedColor` é equivalente e mais idiomático.

**Solução:** Usar `==` consistentemente: `final active = _selectedColor == c`.

---

#### M-09 — `_DashedChipBorder` em arquivo errado
**Arquivo:** `lib/features/transactions/presentation/screens/add_transaction_screen.dart`

**Problema:** `_DashedChipBorder` é um `CustomPainter` genérico (não específico de transações) que deveria estar em `core/widgets/`. Está escondido num arquivo de screen de 400+ linhas.

**Solução:** Mover para `lib/core/widgets/dashed_border_painter.dart` e importar.

---

#### M-10 — `add_transaction_screen.dart` com fechamento de chaves inconsistente
**Arquivo:** `lib/features/transactions/presentation/screens/add_transaction_screen.dart:150`

**Problema:** A adição da constraint de responsividade foi feita adicionando `Center + ConstrainedBox` antes do `SingleChildScrollView` e depois adicionando fechamentos extras `),),),` no final, resultando em indentação completamente desalinhada com o restante do arquivo.

**Impacto:** Legibilidade ruim. Dificulta manutenção.

**Solução:** Reestruturar o método `build()` inteiro com indentação consistente.

---

### 🟢 Baixos

---

#### B-01 — `getRecent()` ordena O(n log n) a cada chamada
**Arquivo:** `lib/features/transactions/presentation/controllers/transaction_controller.dart:21`

**Problema:** `_repo.getAll().toList()..sort(...)` carrega todas as transações em memória e ordena toda vez que o widget renderiza.

**Solução:** `_repo.getAll()` poderia já retornar ordenado, ou criar índice no mock repo.

---

#### B-02 — `IndexedStack` mantém 4 screens em memória
**Arquivo:** `lib/features/navigation/presentation/screens/main_nav_screen.dart`

**Problema:** Todas as 4 telas permanecem na árvore de widgets simultaneamente. Isso é intencional (preserva estado de scroll, filtros, etc.) mas significa que os 4 `ListenableBuilder` ativam em qualquer mudança de transação — mesmo se o usuário está em outra aba.

**Impacto atual:** Baixo (4 telas simples). Impacto futuro: Pode ser relevante com telas de investimentos e metas.

**Solução futura:** Se performance se tornar problema, usar `AutomaticKeepAliveClientMixin` com `PageView` como alternativa que só mantém a aba ativa.

---

#### B-03 — `dio_client.dart` vazio com comentário de exemplo
**Arquivo:** `lib/core/network/dio_client.dart`

**Problema:** O arquivo contém apenas um comentário de exemplo sem código funcional. Ao mesmo tempo, `api_client.dart` define a interface. Quando for implementar o backend, qual usar?

**Solução:** Ou deletar `dio_client.dart` e deixar apenas `api_client.dart`, ou implementar `DioApiClient implements ApiClient`.

---

#### B-04 — Ausência total de testes
**Diretório:** `test/`

**Problema:** Nenhum arquivo de teste existe. Isso significa que qualquer refatoração, especialmente a troca do mock repository por uma implementação real, não tem garantia de não quebrar comportamentos.

**Impacto:** Médio agora, crítico quando o projeto crescer e um segundo desenvolvedor entrar.

**Prioridade de testes:**
1. `TransactionController` (regras de negócio)
2. `MockTransactionRepository` (queries)
3. `CurrencyFormatter` e `BankAmountFormatter`
4. Widget tests para `add_transaction_screen`

---

## 3. Melhorias Recomendadas (por prioridade)

| # | Melhoria | Esforço | Impacto |
|---|---|---|---|
| 1 | Implementar `CategoryRepository` + `CategoryController` para persistir categorias criadas | Alto | Crítico |
| 2 | Implementar lógica das abas de período em Relatórios | Médio | Alto |
| 3 | Calcular `trendPercent` real no `BalanceCard` | Baixo | Alto |
| 4 | Adicionar confirmação antes de deletar transação + corrigir ícone | Baixo | Alto |
| 5 | Adicionar `update()` em toda a stack + `EditTransactionScreen` | Alto | Alto |
| 6 | Bloquear navegação para meses futuros em `HistoryScreen` | Baixo | Médio |
| 7 | Extrair `_TypeSelector` para `core/widgets/` | Baixo | Médio |
| 8 | Deletar ou usar os 5 widgets de core criados e não usados | Baixo | Médio |
| 9 | Migrar DI para `get_it` ou `riverpod` | Alto | Alto (longo prazo) |
| 10 | Implementar autenticação + rota guard | Muito Alto | Crítico (pré-produção) |
| 11 | Mover `_DashedChipBorder` para `core/widgets/` | Baixo | Baixo |
| 12 | Adicionar `cardGradientStart/End` em `AppColors` | Muito Baixo | Baixo |
| 13 | Remover `cupertino_icons` do pubspec | Muito Baixo | Baixo |
| 14 | Escrever testes unitários para controller e formatter | Alto | Alto (longo prazo) |
| 15 | Granularizar `ListenableBuilder` para seções específicas | Médio | Médio |

---

## 4. Refatorações Recomendadas

### 4.1 `TransactionCategory enum` → entidade dinâmica

**Prioridade: Crítica**

O `enum TransactionCategory` em `transaction.dart` precisa ser substituído por uma classe `Category`:

```
lib/features/categories/
  domain/
    entities/category.dart          // id, name, type, icon, color, isSystem
    repositories/category_repository.dart
  data/
    repositories/mock_category_repository.dart
  presentation/
    controllers/category_controller.dart
    screens/create_category_screen.dart  (já existe)
    screens/icon_picker_screen.dart      (já existe)
    screens/color_picker_screen.dart     (já existe)
```

Isso desacopla a UI de categorias do domínio de transações e permite categorias criadas pelo usuário.

---

### 4.2 `reports_screen.dart` — separar responsabilidades

**Prioridade: Alta**

`_ReportsScreenState` acumula: estado da UI (`_period`, `_touched`), lógica de dados para barras, lógica de dados para pizza, lógica do insight. São 4 responsabilidades em ~350 linhas.

**Extrair:**
```
features/reports/
  presentation/
    screens/reports_screen.dart         // orquestra
    widgets/period_bar_chart.dart       // _buildBarSection + lógica
    widgets/category_pie_chart.dart     // _buildPieSection + lógica
    widgets/spending_insight_card.dart  // _buildInsight
```

---

### 4.3 `add_transaction_screen.dart` — extrair widgets e normalizar indentação

**Prioridade: Média**

O arquivo tem ~400 linhas e mistura: formatador bancário, widget de chips, painter de borda, lógica de salvamento e UI de data. Além disso, a adição de `Center + ConstrainedBox` criou indentação inconsistente.

**Extrair:**
```
features/transactions/presentation/
  widgets/
    category_chips.dart              // _CategoryChips
    bank_amount_formatter.dart       // BankAmountFormatter
  screens/
    add_transaction_screen.dart      // < 200 linhas
core/widgets/
    dashed_border_painter.dart       // _DashedChipBorder
```

---

### 4.4 Centralizar widgets duplicados

**Prioridade: Média**

`_TypeSelector` em `add_transaction_screen.dart` e `create_category_screen.dart`:

```
lib/core/widgets/type_selector.dart   // único, importado por ambas as telas
```

---

### 4.5 `TransactionController` — separar por domínio

**Prioridade: Baixa agora, Alta quando novos módulos chegarem**

Quando investimentos, metas e contas bancárias forem implementados, um único `TransactionController` se tornará um "God Controller". Preparar separando desde já:

```
features/transactions/presentation/controllers/transaction_controller.dart
features/categories/presentation/controllers/category_controller.dart
features/investments/presentation/controllers/investment_controller.dart
```

Cada um com seu próprio `ChangeNotifier` e responsabilidades claras.

---

### 4.6 Normalizar uso de `AppTextStyles`

**Prioridade: Baixa**

Alguns arquivos usam `AppTextStyles.h3` corretamente. Outros usam `TextStyle(fontSize: 18, fontWeight: FontWeight.w600)` inline. Essa inconsistência significa que uma mudança de design exige varredura em vários arquivos.

**Ação:** Auditar todos os `TextStyle(...)` inline e substituir pelos equivalentes em `AppTextStyles` (ou adicionar novos estilos se necessário).

---

## 5. Arquitetura Ideal

### Estrutura de Pastas Recomendada

```
lib/
├── app.dart
├── main.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      (AppLimits, AppStrings)
│   │   ├── app_routes.dart         (centralizar TODAS as rotas aqui)
│   │   └── storage_keys.dart
│   ├── di/
│   │   └── service_locator.dart    (migrar para get_it com lazy singletons)
│   ├── error/
│   │   ├── app_exception.dart      (hierarquia de exceções)
│   │   └── failure.dart            (Either<Failure, T> pattern)
│   ├── network/
│   │   ├── api_client.dart
│   │   └── dio_api_client.dart     (implementação real)
│   ├── router/
│   │   ├── app_router.dart         (GoRouter com redirect guard)
│   │   └── route_guard.dart        (auth guard)
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── bank_amount_formatter.dart   (mover de add_transaction_screen)
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_card.dart
│       ├── app_scaffold.dart
│       ├── custom_button.dart           (usar de fato)
│       ├── custom_input.dart            (usar de fato)
│       ├── dashed_border_painter.dart   (mover de add_transaction_screen)
│       ├── loading_widget.dart          (usar de fato)
│       ├── section_header.dart
│       └── type_selector.dart           (extrair de add_transaction e create_category)
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user.dart
│   │   │   └── repositories/auth_repository.dart
│   │   ├── data/
│   │   │   └── repositories/remote_auth_repository.dart
│   │   └── presentation/
│   │       ├── controllers/auth_controller.dart    ← FALTA
│   │       ├── screens/
│   │       │   ├── login_screen.dart               ← FALTA
│   │       │   ├── register_screen.dart            ← FALTA
│   │       │   └── forgot_password_screen.dart     ← FALTA
│   │       └── widgets/auth_form_field.dart
│   │
│   ├── categories/
│   │   ├── domain/
│   │   │   ├── entities/category.dart              ← FALTA (substitui enum)
│   │   │   └── repositories/category_repository.dart  ← FALTA
│   │   ├── data/
│   │   │   └── repositories/mock_category_repository.dart  ← FALTA
│   │   └── presentation/
│   │       ├── controllers/category_controller.dart  ← FALTA
│   │       └── screens/
│   │           ├── create_category_screen.dart    (existe)
│   │           ├── icon_picker_screen.dart        (existe)
│   │           └── color_picker_screen.dart       (existe)
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── screens/dashboard_screen.dart
│   │       └── widgets/
│   │           ├── balance_card.dart
│   │           ├── flow_chart.dart
│   │           ├── info_cards_row.dart
│   │           └── recent_list.dart
│   │
│   ├── navigation/
│   │   └── presentation/
│   │       ├── screens/main_nav_screen.dart
│   │       └── widgets/
│   │           ├── bottom_nav.dart
│   │           └── nav_item.dart
│   │
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/more_screen.dart
│   │
│   ├── reports/
│   │   └── presentation/
│   │       ├── screens/reports_screen.dart
│   │       └── widgets/
│   │           ├── period_bar_chart.dart           ← EXTRAIR
│   │           ├── category_pie_chart.dart         ← EXTRAIR
│   │           └── spending_insight_card.dart      ← EXTRAIR
│   │
│   └── transactions/
│       ├── domain/
│       │   ├── entities/transaction.dart
│       │   └── repositories/transaction_repository.dart  (adicionar update())
│       ├── data/
│       │   └── repositories/mock_transaction_repository.dart (adicionar update())
│       └── presentation/
│           ├── controllers/transaction_controller.dart  (adicionar update())
│           ├── screens/
│           │   ├── add_transaction_screen.dart
│           │   ├── edit_transaction_screen.dart     ← FALTA
│           │   └── history_screen.dart
│           └── widgets/
│               ├── category_chips.dart              ← EXTRAIR
│               └── transaction_tile.dart
│
└── test/
    ├── core/utils/currency_formatter_test.dart     ← FALTA
    ├── features/transactions/
    │   ├── data/mock_transaction_repository_test.dart  ← FALTA
    │   └── presentation/transaction_controller_test.dart  ← FALTA
    └── features/categories/
        └── presentation/category_controller_test.dart   ← FALTA
```

---

### Princípios para Manter

1. **Repository Pattern:** Continuar usando. É o ponto certo de troca quando o backend for implementado.
2. **Feature-First:** Estrutura correta. Manter estritamente — nunca criar pastas transversais como `screens/` na raiz.
3. **ChangeNotifier:** Adequado para o porte atual. Se o app crescer para 10+ controllers, avaliar migração para `riverpod` ou `bloc`.
4. **Design System:** `AppColors`, `AppTextStyles`, `AppTheme` estão bem implementados. Continuar usando-os exclusivamente — proibir `TextStyle(...)` inline fora do design system.
5. **`AppLimits.contentMaxWidth`:** Boa decisão. Centralizar todos os valores de layout aqui.

---

### Fluxo de Dados Ideal

```
UI (Screen)
    ↓ chama
Controller (ChangeNotifier)
    ↓ chama
Repository Interface (abstract)
    ↓ implementado por
MockRepository (dev) ou RemoteRepository (prod)
    ↓ delega para
ApiClient (Dio) ou LocalStorage
```

**Regra de ouro:** Camadas superiores nunca conhecem camadas inferiores concretas. A `DashboardScreen` nunca deve importar `MockTransactionRepository`.

---

*Relatório gerado em 2026-05-31. Revisar após cada sprint de desenvolvimento.*

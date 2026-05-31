import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/core/widgets/section_header.dart';
import 'package:financeapp/core/di/service_locator.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/info_cards_row.dart';
import '../widgets/flow_chart.dart';
import '../widgets/recent_list.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;
  const DashboardScreen({this.onNavigateToHistory, super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Injector.transactionController,
      builder: (context, _) {
        final now  = DateTime.now();
        final ctrl = Injector.transactionController;

        final income      = ctrl.getTotalByType(TransactionType.income,     year: now.year, month: now.month);
        final expenses    = ctrl.getTotalByType(TransactionType.expense,    year: now.year, month: now.month);
        final investments = ctrl.getTotalByType(TransactionType.investment, year: now.year, month: now.month);
        final balance     = income - expenses;
        final recent      = ctrl.getRecent(limit: 5);
        final weekTxs     = ctrl.getByDateRange(now.subtract(const Duration(days: 6)), now);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(now: now),
                        const SizedBox(height: 20),
                        BalanceCard(balance: balance, trendPercent: 6.2),
                        const SizedBox(height: 12),
                        InfoCardsRow(income: income, expenses: expenses, investments: investments),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Fluxo do Mês'),
                        const SizedBox(height: 12),
                        FlowChart(transactions: weekTxs),
                        const SizedBox(height: 20),
                        SectionHeader(title: 'Recentes', actionLabel: 'Ver tudo →', onAction: onNavigateToHistory),
                        const SizedBox(height: 12),
                        RecentList(transactions: recent),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime now;
  const _Header({required this.now});

  @override
  Widget build(BuildContext context) {
    final hour     = now.hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    final month    = DateFormat('MMMM yyyy', 'pt_BR').format(now);
    final monthCap = month[0].toUpperCase() + month.substring(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('$greeting, Ian', style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ]),
            Text(monthCap, style: AppTextStyles.secondary),
          ],
        ),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.notifications_rounded, color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}

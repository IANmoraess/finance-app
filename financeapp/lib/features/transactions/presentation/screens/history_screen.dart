import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/core/utils/currency_formatter.dart';
import 'package:financeapp/core/di/service_locator.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _month;
  TransactionType? _filter;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _next() => setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Injector.transactionController,
      builder: (context, _) {
        final ctrl = Injector.transactionController;
        var txs    = ctrl.getByMonth(_month.year, _month.month);
        if (_filter != null) txs = txs.where((t) => t.type == _filter).toList();

        final income   = ctrl.getTotalByType(TransactionType.income,  year: _month.year, month: _month.month);
        final expenses = ctrl.getTotalByType(TransactionType.expense, year: _month.year, month: _month.month);
        final grouped  = _group(txs);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Histórico', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      _MonthSelector(month: _month, onPrev: _prev, onNext: _next),
                      const SizedBox(height: 12),
                      _SummaryRow(income: income, expenses: expenses),
                      const SizedBox(height: 12),
                      _FilterChips(selected: _filter, onChanged: (f) => setState(() => _filter = f)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: txs.isEmpty
                      ? const Center(child: Text('Nenhuma transação neste período', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                          itemCount: grouped.length,
                          itemBuilder: (_, i) {
                            final entry = grouped[i];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(entry.key,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ),
                                ...entry.value.map((t) => TransactionTile(
                                      transaction: t,
                                      onDelete: () => Injector.transactionController.delete(t.id),
                                    )),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<MapEntry<String, List<Transaction>>> _group(List<Transaction> txs) {
    final now = DateTime.now();
    final map = <String, List<Transaction>>{};
    for (final t in txs) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(t.date.year, t.date.month, t.date.day))
          .inDays;
      final label = diff == 0 ? 'Hoje' : diff == 1 ? 'Ontem' : DateFormat("d 'de' MMMM", 'pt_BR').format(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map.entries.toList();
  }
}

// ── sub-widgets ──────────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthSelector({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final raw = DateFormat('MMMM yyyy', 'pt_BR').format(month);
    final label = raw[0].toUpperCase() + raw.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          Text(label, style: AppTextStyles.bodyMedium),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double income;
  final double expenses;
  const _SummaryRow({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('Entradas: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(CurrencyFormatter.formatCompact(income),   style: const TextStyle(fontSize: 13, color: AppColors.income,  fontWeight: FontWeight.w600)),
      const SizedBox(width: 16),
      const Text('Gastos: ',   style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(CurrencyFormatter.formatCompact(expenses), style: const TextStyle(fontSize: 13, color: AppColors.expense, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _FilterChips extends StatelessWidget {
  final TransactionType? selected;
  final ValueChanged<TransactionType?> onChanged;
  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _chip(null,                       'Todos',         AppColors.primary),
        const SizedBox(width: 8),
        _chip(TransactionType.income,     'Entradas',      AppColors.income),
        const SizedBox(width: 8),
        _chip(TransactionType.expense,    'Gastos',        AppColors.expense),
        const SizedBox(width: 8),
        _chip(TransactionType.investment, 'Investimentos', AppColors.investment),
      ]),
    );
  }

  Widget _chip(TransactionType? type, String label, Color color) {
    final active = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: active ? color : AppColors.textSecondary, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

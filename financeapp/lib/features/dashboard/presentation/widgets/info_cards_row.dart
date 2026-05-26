import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/utils/currency_formatter.dart';

class InfoCardsRow extends StatelessWidget {
  final double income;
  final double expenses;
  final double investments;

  const InfoCardsRow({
    required this.income,
    required this.expenses,
    required this.investments,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Card(label: 'Entradas', value: income,      color: AppColors.income)),
        const SizedBox(width: 8),
        Expanded(child: _Card(label: 'Gastos',   value: expenses,    color: AppColors.expense)),
        const SizedBox(width: 8),
        Expanded(child: _Card(label: 'Invest.',  value: investments, color: AppColors.investment)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Card({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatCompact(value),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

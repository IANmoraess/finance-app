import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/utils/currency_formatter.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class RecentList extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentList({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Sem transações recentes', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return Column(
      children: transactions.map((t) => _Row(transaction: t)).toList(),
    );
  }
}

class _Row extends StatelessWidget {
  final Transaction transaction;
  const _Row({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income
        : transaction.type == TransactionType.investment ? AppColors.investment
        : AppColors.expense;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _Icon(category: transaction.category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(transaction.category.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '$sign ${CurrencyFormatter.formatCompact(transaction.amount)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final TransactionCategory category;
  const _Icon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, color: category.color, size: 20),
    );
  }
}

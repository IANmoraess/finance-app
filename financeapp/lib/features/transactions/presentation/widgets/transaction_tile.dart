import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/utils/currency_formatter.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionTile({required this.transaction, this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final isIncome     = transaction.type == TransactionType.income;
    final isInvestment = transaction.type == TransactionType.investment;
    final color = isIncome ? AppColors.income : isInvestment ? AppColors.investment : AppColors.expense;
    final sign  = isIncome ? '+' : '-';
    final time  = DateFormat('HH:mm').format(transaction.date);

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
                const SizedBox(height: 2),
                Text('${transaction.category.label} · $time', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '$sign ${CurrencyFormatter.formatCompact(transaction.amount)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ],
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
      decoration: BoxDecoration(color: category.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Icon(category.icon, color: category.color, size: 20),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double trendPercent;

  const BalanceCard({required this.balance, required this.trendPercent, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2140), Color(0xFF242B52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo Total', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.format(balance), style: AppTextStyles.amountLarge),
          const SizedBox(height: 12),
          _TrendBadge(percent: trendPercent),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final double percent;
  const _TrendBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final positive = percent >= 0;
    final color = positive ? AppColors.income : AppColors.expense;
    final icon  = positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '${percent.abs().toStringAsFixed(1)}% este mês',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

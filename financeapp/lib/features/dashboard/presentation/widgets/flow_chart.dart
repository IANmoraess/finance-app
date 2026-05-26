import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class FlowChart extends StatelessWidget {
  final List<Transaction> transactions;

  const FlowChart({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();
    final maxY = _maxY(groups);

    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  final now = DateTime.now();
                  final day = now.subtract(Duration(days: 6 - value.toInt()));
                  // 0=Sun..6=Sat for Dart weekday (1=Mon,7=Sun)
                  const abbrev = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                  final label = abbrev[day.weekday % 7];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
          ),
          barGroups: groups,
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayTxs = transactions.where((t) =>
          t.date.year == day.year && t.date.month == day.month && t.date.day == day.day);

      final income = dayTxs
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final expense = dayTxs
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);

      return BarChartGroupData(
        x: i,
        barsSpace: 3,
        barRods: [
          BarChartRodData(toY: income,  color: AppColors.income,  width: 9, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          BarChartRodData(toY: expense, color: AppColors.expense, width: 9, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ],
      );
    });
  }

  double _maxY(List<BarChartGroupData> groups) {
    final max = groups
        .expand((g) => g.barRods.map((r) => r.toY))
        .fold(0.0, (m, v) => v > m ? v : m);
    return max > 0 ? max * 1.35 : 1000;
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class FlowChart extends StatelessWidget {
  final List<Transaction> transactions;
  const FlowChart({required this.transactions, super.key});

  static const _kBarW       = 22.0;
  static const _kBarSpace   = 5.0;
  static const _kGroupSpace = 28.0;
  static const _kGroupW     = _kBarW * 2 + _kBarSpace + _kGroupSpace;

  @override
  Widget build(BuildContext context) {
    final groups     = _buildGroups();
    final maxY       = _maxY(groups);
    final chartWidth = 7 * _kGroupW + 24;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _dot(AppColors.income),  const SizedBox(width: 4),
                const Text('Entradas', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 10),
                _dot(AppColors.expense), const SizedBox(width: 4),
                const Text('Gastos',   style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              const Row(children: [
                Icon(Icons.swipe_rounded, size: 13, color: AppColors.textHint),
                SizedBox(width: 3),
                Text('arraste', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: 180,
              width: chartWidth,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  groupsSpace: _kGroupSpace,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Entradas' : 'Gastos';
                        return BarTooltipItem(
                          '$label\nR\$ ${rod.toY.toStringAsFixed(0)}',
                          TextStyle(
                            color: rodIndex == 0 ? AppColors.income : AppColors.expense,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: AppColors.border, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, _) {
                          final now = DateTime.now();
                          final day = now.subtract(Duration(days: 6 - value.toInt()));
                          const abbrev = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                          final label = abbrev[day.weekday % 7];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(label,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: groups,
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day    = now.subtract(Duration(days: 6 - i));
      final dayTxs = transactions.where((t) =>
          t.date.year == day.year && t.date.month == day.month && t.date.day == day.day);
      final income  = dayTxs.where((t) => t.type == TransactionType.income) .fold(0.0, (s, t) => s + t.amount);
      final expense = dayTxs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
      return BarChartGroupData(
        x: i,
        barsSpace: _kBarSpace,
        barRods: [
          BarChartRodData(toY: income,  color: AppColors.income,  width: _kBarW, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
          BarChartRodData(toY: expense, color: AppColors.expense, width: _kBarW, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
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

  Widget _dot(Color c) =>
      Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

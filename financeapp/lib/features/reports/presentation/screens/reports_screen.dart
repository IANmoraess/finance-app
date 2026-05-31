import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/core/di/service_locator.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

enum _Period { week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  _Period _period = _Period.month;
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Injector.transactionController,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Relatórios', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      _PeriodTabs(selected: _period, onChanged: (p) => setState(() => _period = p)),
                      const SizedBox(height: 20),
                      _buildBarSection(),
                      const SizedBox(height: 20),
                      _buildPieSection(),
                      const SizedBox(height: 20),
                      _buildInsight(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Entradas vs Gastos (rolável horizontalmente) ─────────────────────────

  static const _kBarW       = 22.0;  // largura de cada barra
  static const _kBarSpace   = 5.0;   // espaço entre as 2 barras do grupo
  static const _kGroupSpace = 28.0;  // espaço entre grupos
  // largura ocupada por cada grupo = 2 barras + espaço interno + espaço entre grupos
  static const _kGroupW     = _kBarW * 2 + _kBarSpace + _kGroupSpace; // ~77px

  Widget _buildBarSection() {
    final ctrl   = Injector.transactionController;
    final now    = DateTime.now();
    // Últimos 6 meses (do mais antigo para o mais recente)
    final months = List.generate(6, (i) => DateTime(now.year, now.month - 5 + i));

    final groups = months.asMap().entries.map((e) {
      final m       = e.value;
      final income  = ctrl.getTotalByType(TransactionType.income,  year: m.year, month: m.month);
      final expense = ctrl.getTotalByType(TransactionType.expense, year: m.year, month: m.month);
      return BarChartGroupData(
        x: e.key,
        barsSpace: _kBarSpace,
        barRods: [
          BarChartRodData(
            toY: income,
            color: AppColors.income,
            width: _kBarW,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
          BarChartRodData(
            toY: expense,
            color: AppColors.expense,
            width: _kBarW,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    }).toList();

    final maxY = groups
        .expand((g) => g.barRods.map((r) => r.toY))
        .fold(0.0, (m, v) => v > m ? v : m);
    final double chartMaxY = maxY > 0 ? maxY * 1.3 : 6000.0;

    // Largura total do gráfico: garante que caiba no mínimo em qualquer tela
    // mas sempre tem espaço para arrastar
    final chartWidth = months.length * _kGroupW + 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Entradas vs Gastos', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _dot(AppColors.income),  const SizedBox(width: 4),
              const Text('Entradas', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 10),
              _dot(AppColors.expense), const SizedBox(width: 4),
              const Text('Gastos',   style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          // Scroll horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: 180,
              width: chartWidth,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  groupsSpace: _kGroupSpace,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Entradas' : 'Gastos';
                        final value = rod.toY;
                        return BarTooltipItem(
                          '$label\nR\$ ${value.toStringAsFixed(0)}',
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
                    horizontalInterval: chartMaxY / 4,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: AppColors.border, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                          final raw = DateFormat('MMM', 'pt_BR').format(months[idx]);
                          final label = raw[0].toUpperCase() + raw.substring(1);
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
        ),
      ],
    );
  }

  // ── Gastos por categoria ──────────────────────────────────────────────────

  Widget _buildPieSection() {
    final ctrl = Injector.transactionController;
    final now  = DateTime.now();
    final txs  = ctrl.getByMonth(now.year, now.month).where((t) => t.type == TransactionType.expense);

    final totals = <TransactionCategory, double>{};
    for (final t in txs) totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    final total = totals.values.fold(0.0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top    = sorted.take(3).toList();
    final other  = sorted.skip(3).fold(0.0, (s, e) => s + e.value);

    // Raio máximo = SizedBox / 2 = 80px
    // centerSpaceRadius(32) + sectionRadius(44) = 76 ✓  (touched: 80 ✓)
    final sections = <PieChartSectionData>[
      for (int i = 0; i < top.length; i++)
        PieChartSectionData(
          value: top[i].value,
          color: top[i].key.color,
          showTitle: false,           // títulos ficam na legenda, não no gráfico
          radius: _touched == i ? 44 : 38,
        ),
      if (other > 0)
        PieChartSectionData(
          value: other,
          color: AppColors.textSecondary,
          showTitle: false,
          radius: _touched == top.length ? 44 : 38,
        ),
    ];

    final legend = <_LegendRow>[
      for (final e in top)
        _LegendRow(color: e.key.color, label: e.key.label, pct: e.value / total * 100),
      if (other > 0)
        _LegendRow(color: AppColors.textSecondary, label: 'Outros', pct: other / total * 100),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gastos por Categoria', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gráfico com tamanho fixo compatível com os raios definidos
              SizedBox(
                height: 160, width: 160,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 32,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (e, res) => setState(() {
                      _touched = (e.isInterestedForInteractions && res?.touchedSection != null)
                          ? res!.touchedSection!.touchedSectionIndex : -1;
                    }),
                  ),
                )),
              ),
              const SizedBox(width: 20),
              // Legenda expandida – nunca sobrepõe o gráfico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: legend,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Insight ───────────────────────────────────────────────────────────────

  Widget _buildInsight() {
    final ctrl  = Injector.transactionController;
    final now   = DateTime.now();
    final curr  = ctrl.getTotalByType(TransactionType.expense, year: now.year, month: now.month);
    final prev  = ctrl.getTotalByType(TransactionType.expense, year: now.year, month: now.month - 1);
    final diff  = prev > 0 ? ((prev - curr) / prev * 100) : 0.0;
    final less  = diff >= 0;
    final txt   = less
        ? 'Você gastou ${diff.toStringAsFixed(0)}% menos que no mês anterior! Continue assim 🎉'
        : 'Seus gastos aumentaram ${(-diff).toStringAsFixed(0)}% este mês. Fique de olho! 💡';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(txt, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

// ── _LegendRow ────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final double pct;
  const _LegendRow({required this.color, required this.label, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── _PeriodTabs ───────────────────────────────────────────────────────────────

class _PeriodTabs extends StatelessWidget {
  final _Period selected;
  final ValueChanged<_Period> onChanged;
  const _PeriodTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _tab(_Period.week,  'Semana'),
        _tab(_Period.month, 'Mês'),
        _tab(_Period.year,  'Ano'),
      ]),
    );
  }

  Widget _tab(_Period p, String label) {
    final active = selected == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: AppColors.primary, width: 1.5) : null,
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? AppColors.primary : AppColors.textSecondary)),
        ),
      ),
    );
  }
}

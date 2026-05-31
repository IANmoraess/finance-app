import 'package:flutter/material.dart';
import 'package:financeapp/core/constants/app_constants.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/features/categories/presentation/screens/color_picker_screen.dart';
import 'package:financeapp/features/categories/presentation/screens/icon_picker_screen.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  TransactionType _type         = TransactionType.expense;
  final _nameCtrl               = TextEditingController();
  IconData _selectedIcon        = Icons.category_rounded;
  Color    _selectedColor       = const Color(0xFFFB5757);

  static const _kItemSize = 44.0;
  static const _kGap      = 8.0;

  // Quick suggestions: selected item is always first
  static const _quickIconPool = [
    Icons.restaurant_rounded, Icons.directions_car_rounded, Icons.home_rounded,
    Icons.favorite_rounded,   Icons.school_rounded,         Icons.sports_esports_rounded,
    Icons.shopping_bag_rounded, Icons.trending_up_rounded,  Icons.account_balance_wallet_rounded,
    Icons.laptop_mac_rounded, Icons.flight_rounded,         Icons.pets_rounded,
  ];

  static const _quickColorPool = [
    Color(0xFFFB5757), Color(0xFFF97316), Color(0xFFF59E0B),
    Color(0xFF84CC16), Color(0xFF22C55E), Color(0xFF14B8A6),
    Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1),
    Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF94A3B8),
  ];

  int _perRow(double w) =>
      ((w + _kGap) / (_kItemSize + _kGap)).floor().clamp(3, 99);

  List<IconData> _quickIcons(int n) => _quickIconPool.take(n).toList();

  List<Color> _quickColors(int n) => _quickColorPool.take(n).toList();

  Future<void> _openIconPicker() async {
    final result = await Navigator.push<IconData>(
      context,
      MaterialPageRoute(
        builder: (_) => IconPickerScreen(
          current: _selectedIcon,
          accentColor: _selectedColor,
        ),
      ),
    );
    if (result != null) setState(() => _selectedIcon = result);
  }

  Future<void> _openColorPicker() async {
    final result = await Navigator.push<Color>(
      context,
      MaterialPageRoute(
        builder: (_) => ColorPickerScreen(current: _selectedColor),
      ),
    );
    if (result != null) setState(() => _selectedColor = result);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name  = _nameCtrl.text.trim();
    final valid = name.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nova categoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLimits.contentMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Preview ─────────────────────────────────────
                Center(
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(_selectedIcon, color: _selectedColor, size: 38),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      valid ? name : 'Nome da categoria',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: valid ? AppColors.textPrimary : AppColors.textHint,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Tipo ────────────────────────────────────────
                _TypeSelector(selected: _type, onChanged: (t) => setState(() => _type = t)),
                const SizedBox(height: 20),

                // ── Nome ────────────────────────────────────────
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLength: 22,
                  decoration: const InputDecoration(
                    hintText: 'Título da categoria',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),

                // ── Ícones e Cores (responsivos) ─────────────────
                LayoutBuilder(builder: (context, constraints) {
                  final n           = _perRow(constraints.maxWidth);
                  final quickIcons  = _quickIcons(n);
                  final quickColors = _quickColors(n);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ícone ──────────────────────────────────
                      _PickerLabel(
                        label: 'ÍCONE',
                        linkText: 'Ver todos',
                        onViewAll: _openIconPicker,
                      ),
                      Wrap(
                        spacing: _kGap, runSpacing: _kGap,
                        children: quickIcons.map((ic) {
                          final active = _selectedIcon == ic;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = ic),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _kItemSize, height: _kItemSize,
                              decoration: BoxDecoration(
                                color: active
                                    ? _selectedColor.withOpacity(0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active ? _selectedColor : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(ic, size: 20,
                                  color: active ? _selectedColor : AppColors.textSecondary),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ── Cor ────────────────────────────────────
                      _PickerLabel(
                        label: 'COR',
                        linkText: 'Ver todas',
                        onViewAll: _openColorPicker,
                      ),
                      Wrap(
                        spacing: _kGap, runSpacing: _kGap,
                        children: quickColors.map((c) {
                          final active = _selectedColor.value == c.value;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _kItemSize, height: _kItemSize,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: active
                                    ? Border.all(color: Colors.white, width: 2.5)
                                    : null,
                              ),
                              child: active
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 36),

                // ── Salvar ──────────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: valid ? () => Navigator.pop(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: valid ? _selectedColor : AppColors.surface,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Criar categoria',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── _PickerLabel ──────────────────────────────────────────────────────────────

class _PickerLabel extends StatelessWidget {
  final String label;
  final String linkText;
  final VoidCallback onViewAll;
  const _PickerLabel({
    required this.label,
    required this.linkText,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              )),
          GestureDetector(
            onTap: onViewAll,
            child: Row(children: [
              Text(linkText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  )),
              const Icon(Icons.chevron_right_rounded,
                  size: 14, color: AppColors.primary),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── _TypeSelector ─────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _tab(TransactionType.expense,    'Gasto',        AppColors.expense),
        _tab(TransactionType.income,     'Entrada',      AppColors.income),
        _tab(TransactionType.investment, 'Investimento', AppColors.investment),
      ]),
    );
  }

  Widget _tab(TransactionType type, String label, Color color) {
    final active = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? color : AppColors.textSecondary,
              )),
        ),
      ),
    );
  }
}

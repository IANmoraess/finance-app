import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/core/di/service_locator.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType? initialType;
  const AddTransactionScreen({this.initialType, super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type;
  TransactionCategory? _category;
  DateTime _date = DateTime.now();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController(text: '0,00');
  final _descCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color get _color => switch (_type) {
    TransactionType.income     => AppColors.income,
    TransactionType.expense    => AppColors.expense,
    TransactionType.investment => AppColors.investment,
  };

  String get _saveLabel => switch (_type) {
    TransactionType.income     => 'Salvar Entrada',
    TransactionType.expense    => 'Salvar Gasto',
    TransactionType.investment => 'Salvar Investimento',
  };

  List<TransactionCategory> get _categories => switch (_type) {
    TransactionType.income     => [TransactionCategory.salary, TransactionCategory.freelance, TransactionCategory.other],
    TransactionType.expense    => [
        TransactionCategory.food, TransactionCategory.housing, TransactionCategory.transport,
        TransactionCategory.health, TransactionCategory.entertainment, TransactionCategory.shopping,
        TransactionCategory.education, TransactionCategory.other,
      ],
    TransactionType.investment => [TransactionCategory.investment, TransactionCategory.other],
  };

  void _save() {
    final raw    = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido')));
      return;
    }
    final title = _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : (_category?.label ?? 'Transação');
    Injector.transactionController.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _type,
      category: _category ?? TransactionCategory.other,
      date: _date,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: _color, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nova Movimentação'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeSelector(selected: _type, onChanged: (t) => setState(() { _type = t; _category = null; })),
            const SizedBox(height: 20),
            _AmountField(controller: _amountCtrl, color: _color),
            const SizedBox(height: 16),
            _TitleField(controller: _titleCtrl),
            const SizedBox(height: 20),
            const Text('Categoria', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 10),
            _CategoryChips(categories: _categories, selected: _category, onSelected: (c) => setState(() => _category = c)),
            const SizedBox(height: 20),
            _DateRow(date: _date, onTap: _pickDate),
            const SizedBox(height: 14),
            _DescField(controller: _descCtrl),
            const SizedBox(height: 32),
            _SaveButton(label: _saveLabel, color: _color, onPressed: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── sub-widgets ──────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? color : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  const _AmountField({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Valor', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('R\$ ', style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.w500)),
              Expanded(
                child: TextField(
                  controller: controller,
                  // Numeric keyboard sem vírgula/ponto – o formatter cuida da formatação
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                  inputFormatters: [BankAmountFormatter()],
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
                  decoration: const InputDecoration(
                    border: InputBorder.none, filled: false,
                    contentPadding: EdgeInsets.zero, isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(hintText: 'Título (opcional)'),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<TransactionCategory> categories;
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;
  const _CategoryChips({required this.categories, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: categories.map((c) {
        final active = selected == c;
        return GestureDetector(
          onTap: () => onSelected(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? c.color.withOpacity(0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? c.color : AppColors.border, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c.icon, size: 14, color: active ? c.color : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(c.label, style: TextStyle(fontSize: 13, color: active ? c.color : AppColors.textSecondary, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateRow({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("d 'de' MMMM',' yyyy", 'pt_BR').format(date);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(fmt[0].toUpperCase() + fmt.substring(1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DescField extends StatelessWidget {
  final TextEditingController controller;
  const _DescField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: 3,
      decoration: const InputDecoration(hintText: 'Descrição (opcional)...'),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _SaveButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Formatador estilo banco ───────────────────────────────────────────────────
//
// Entrada da direita para a esquerda: digitar "5" → "0,05", "50" → "0,50".
// Backspace remove o último dígito da representação interna em centavos.
// Nunca permite valor vazio – mínimo é "0,00".

class BankAmountFormatter extends TextInputFormatter {
  static const int _maxCents = 999999999; // R$ 9.999.999,99

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extrai apenas dígitos do texto recebido
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Se ficou sem dígitos (ex: usuário apagou tudo), exibe 0,00
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    // Limita ao máximo permitido
    final cents = int.parse(digits) > _maxCents
        ? _maxCents
        : int.parse(digits);

    final formatted = _formatCents(cents);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatCents(int cents) {
    final reais    = cents ~/ 100;
    final centavos = cents % 100;
    final reaisStr = reais.toString();

    // Insere separador de milhar (ponto)
    final sb = StringBuffer();
    for (int i = 0; i < reaisStr.length; i++) {
      if (i > 0 && (reaisStr.length - i) % 3 == 0) sb.write('.');
      sb.write(reaisStr[i]);
    }

    return '${sb.toString()},${centavos.toString().padLeft(2, '0')}';
  }
}

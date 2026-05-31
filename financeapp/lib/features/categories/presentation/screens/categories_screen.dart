import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/features/categories/presentation/screens/create_category_screen.dart';
import 'package:financeapp/features/transactions/domain/entities/transaction.dart';

class CategoriesScreen extends StatelessWidget {
  final TransactionCategory? selectedCategory;
  final TransactionType? initialType;
  const CategoriesScreen({this.selectedCategory, this.initialType, super.key});

  static const _byType = {
    TransactionType.expense: [
      TransactionCategory.food,
      TransactionCategory.housing,
      TransactionCategory.transport,
      TransactionCategory.health,
      TransactionCategory.entertainment,
      TransactionCategory.shopping,
      TransactionCategory.education,
      TransactionCategory.other,
    ],
    TransactionType.income: [
      TransactionCategory.salary,
      TransactionCategory.freelance,
      TransactionCategory.other,
    ],
    TransactionType.investment: [
      TransactionCategory.investment,
      TransactionCategory.other,
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryGroup(
                    color: AppColors.expense,
                    label: 'Gastos',
                    categories: _byType[TransactionType.expense]!,
                    selectedCategory: selectedCategory,
                    onTap: (c) => Navigator.of(context).pop(c),
                  ),
                  const SizedBox(height: 24),
                  _CategoryGroup(
                    color: AppColors.income,
                    label: 'Entradas',
                    categories: _byType[TransactionType.income]!,
                    selectedCategory: selectedCategory,
                    onTap: (c) => Navigator.of(context).pop(c),
                  ),
                  const SizedBox(height: 24),
                  _CategoryGroup(
                    color: AppColors.investment,
                    label: 'Investimentos',
                    categories: _byType[TransactionType.investment]!,
                    selectedCategory: selectedCategory,
                    onTap: (c) => Navigator.of(context).pop(c),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer — Nova categoria ───────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Nova categoria',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _CategoryGroup ────────────────────────────────────────────────────────────

class _CategoryGroup extends StatelessWidget {
  final Color color;
  final String label;
  final List<TransactionCategory> categories;
  final TransactionCategory? selectedCategory;
  final ValueChanged<TransactionCategory> onTap;

  const _CategoryGroup({
    required this.color,
    required this.label,
    required this.categories,
    required this.onTap,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('${categories.length}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: categories.map((c) => _CategoryChip(
            category: c,
            selected: selectedCategory == c,
            onTap: () => onTap(c),
          )).toList(),
        ),
      ],
    );
  }
}

// ── _CategoryChip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final TransactionCategory category;
  final bool selected;
  final VoidCallback? onTap;
  const _CategoryChip({required this.category, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? category.color.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? category.color : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(category.icon, size: 13, color: category.color),
            ),
            const SizedBox(width: 8),
            Text(category.label,
                style: TextStyle(
                    fontSize: 13,
                    color: selected ? category.color : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

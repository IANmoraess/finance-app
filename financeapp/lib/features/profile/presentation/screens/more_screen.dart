import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/core/theme/app_text_styles.dart';
import 'package:financeapp/features/categories/presentation/screens/categories_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mais', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              _ProfileCard(),
              const SizedBox(height: 24),
              _Section(title: 'Conta', items: [
                _Item(icon: Icons.person_rounded,        label: 'Perfil'),
                _Item(icon: Icons.notifications_rounded, label: 'Notificações'),
                _Item(icon: Icons.security_rounded,      label: 'Segurança'),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Finanças', items: [
                _Item(
                  icon: Icons.category_rounded,
                  label: 'Gerenciar Categorias',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  ),
                ),
                _Item(icon: Icons.savings_rounded,          label: 'Metas de Economia'),
                _Item(icon: Icons.account_balance_rounded,  label: 'Contas Bancárias'),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'App', items: [
                _Item(icon: Icons.color_lens_rounded, label: 'Aparência'),
                _Item(icon: Icons.help_rounded,       label: 'Ajuda'),
                _Item(icon: Icons.info_rounded,       label: 'Sobre o App'),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: const Text('I', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ian', style: AppTextStyles.h3),
              SizedBox(height: 2),
              Text('ian@email.com', style: AppTextStyles.secondary),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: items.asMap().entries.map((e) {
              final last = e.key == items.length - 1;
              return Column(children: [
                e.value,
                if (!last) const Divider(height: 1, color: AppColors.border, indent: 52),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _Item({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

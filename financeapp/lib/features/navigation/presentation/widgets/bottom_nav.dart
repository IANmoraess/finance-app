import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'nav_item.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(index: 0, icon: Icons.grid_view_rounded,  label: 'Início',     current: currentIndex, onTap: onTap),
          NavItem(index: 1, icon: Icons.history_rounded,     label: 'Histórico',  current: currentIndex, onTap: onTap),
          const SizedBox(width: 56),
          NavItem(index: 2, icon: Icons.bar_chart_rounded,   label: 'Relatórios', current: currentIndex, onTap: onTap),
          NavItem(index: 3, icon: Icons.more_horiz_rounded,  label: 'Mais',       current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

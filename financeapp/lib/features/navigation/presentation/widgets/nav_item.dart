import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';

class NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int current;
  final ValueChanged<int> onTap;

  const NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.current,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == index;
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

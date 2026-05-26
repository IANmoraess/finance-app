import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold,  color: AppColors.textPrimary);
  static const h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold,  color: AppColors.textPrimary);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600,  color: AppColors.textPrimary);
  static const body       = TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const secondary  = TextStyle(fontSize: 13, color: AppColors.textSecondary);
  static const caption    = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const amountLarge = TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1);
}

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background   = Color(0xFF12141E);
  static const surface      = Color(0xFF1C1F2E);
  static const surfaceLight = Color(0xFF252840);
  static const border       = Color(0xFF2A2D3E);

  static const income     = Color(0xFF1BDE7A);
  static const expense    = Color(0xFFFF5454);
  static const investment = Color(0xFF9961FF);

  static const primary     = Color(0xFF1BDE7A);
  static const primaryDark = Color(0xFF13A35A);

  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF7B8099);
  static const textHint      = Color(0xFF4A4E63);

  // backwards-compat alias
  static const dark_background = background;
}

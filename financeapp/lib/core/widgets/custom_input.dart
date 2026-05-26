import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomInput({
    required this.controller,
    this.hint,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: hint, labelText: label),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';

enum TransactionType { income, expense, investment }

enum TransactionCategory {
  salary, freelance, food, transport, health,
  education, entertainment, shopping, housing, investment, other;

  String get label => switch (this) {
    salary        => 'Salário',
    freelance     => 'Freelance',
    food          => 'Alimentação',
    transport     => 'Transporte',
    health        => 'Saúde',
    education     => 'Educação',
    entertainment => 'Lazer',
    shopping      => 'Compras',
    housing       => 'Moradia',
    investment    => 'Investimento',
    other         => 'Outros',
  };

  IconData get icon => switch (this) {
    salary        => Icons.account_balance_wallet_rounded,
    freelance     => Icons.laptop_mac_rounded,
    food          => Icons.restaurant_rounded,
    transport     => Icons.directions_car_rounded,
    health        => Icons.favorite_rounded,
    education     => Icons.school_rounded,
    entertainment => Icons.sports_esports_rounded,
    shopping      => Icons.shopping_bag_rounded,
    housing       => Icons.home_rounded,
    investment    => Icons.trending_up_rounded,
    other         => Icons.category_rounded,
  };

  Color get color => switch (this) {
    salary        => AppColors.income,
    freelance     => const Color(0xFF00BCD4),
    food          => const Color(0xFFFF7043),
    transport     => const Color(0xFF42A5F5),
    health        => const Color(0xFFEC407A),
    education     => const Color(0xFF66BB6A),
    entertainment => AppColors.investment,
    shopping      => const Color(0xFFFF9800),
    housing       => const Color(0xFFFF9800),
    investment    => AppColors.investment,
    other         => AppColors.textSecondary,
  };
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? description;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });
}

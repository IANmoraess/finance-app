import 'package:flutter/material.dart';

enum CategoryType { expense, income, investment }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final CategoryType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}

const List<IconData> kCategoryIcons = [
  Icons.restaurant_rounded,
  Icons.shopping_cart_rounded,
  Icons.directions_car_rounded,
  Icons.favorite_rounded,
  Icons.sports_esports_rounded,
  Icons.school_rounded,
  Icons.home_rounded,
  Icons.checkroom_rounded,
  Icons.devices_rounded,
  Icons.flight_rounded,
  Icons.pets_rounded,
  Icons.face_rounded,
  Icons.fitness_center_rounded,
  Icons.play_circle_rounded,
  Icons.security_rounded,
  Icons.local_cafe_rounded,
  Icons.card_giftcard_rounded,
  Icons.local_gas_station_rounded,
  Icons.work_rounded,
  Icons.bar_chart_rounded,
  Icons.celebration_rounded,
  Icons.medical_services_rounded,
  Icons.brush_rounded,
  Icons.music_note_rounded,
  Icons.sports_soccer_rounded,
  Icons.spa_rounded,
  Icons.build_rounded,
  Icons.currency_bitcoin,
  Icons.more_horiz_rounded,
];

class CategoryRepository {
  static final List<Category> _categories = [
    // Gastos
    const Category(id: 'food', name: 'Alimentação', icon: Icons.restaurant_rounded, type: CategoryType.expense),
    const Category(id: 'market', name: 'Mercado', icon: Icons.shopping_cart_rounded, type: CategoryType.expense),
    const Category(id: 'transport', name: 'Transporte', icon: Icons.directions_car_rounded, type: CategoryType.expense),
    const Category(id: 'health', name: 'Saúde', icon: Icons.favorite_rounded, type: CategoryType.expense),
    const Category(id: 'leisure', name: 'Lazer', icon: Icons.sports_esports_rounded, type: CategoryType.expense),
    const Category(id: 'education', name: 'Educação', icon: Icons.school_rounded, type: CategoryType.expense),
    const Category(id: 'housing', name: 'Moradia', icon: Icons.home_rounded, type: CategoryType.expense),
    const Category(id: 'clothing', name: 'Vestuário', icon: Icons.checkroom_rounded, type: CategoryType.expense),
    const Category(id: 'tech', name: 'Tecnologia', icon: Icons.devices_rounded, type: CategoryType.expense),
    const Category(id: 'travel', name: 'Viagem', icon: Icons.flight_rounded, type: CategoryType.expense),
    const Category(id: 'pets', name: 'Pets', icon: Icons.pets_rounded, type: CategoryType.expense),
    const Category(id: 'beauty', name: 'Beleza', icon: Icons.face_rounded, type: CategoryType.expense),
    const Category(id: 'gym', name: 'Academia', icon: Icons.fitness_center_rounded, type: CategoryType.expense),
    const Category(id: 'streaming', name: 'Streaming', icon: Icons.play_circle_rounded, type: CategoryType.expense),
    const Category(id: 'bar', name: 'Bar & Café', icon: Icons.local_cafe_rounded, type: CategoryType.expense),
    const Category(id: 'gift', name: 'Presentes', icon: Icons.card_giftcard_rounded, type: CategoryType.expense),
    const Category(id: 'fuel', name: 'Combustível', icon: Icons.local_gas_station_rounded, type: CategoryType.expense),
    const Category(id: 'other_expense', name: 'Outros', icon: Icons.more_horiz_rounded, type: CategoryType.expense),
    // Entradas
    const Category(id: 'salary', name: 'Salário', icon: Icons.work_rounded, type: CategoryType.income),
    const Category(id: 'freelance', name: 'Freelance', icon: Icons.devices_rounded, type: CategoryType.income),
    const Category(id: 'bonus', name: 'Bônus', icon: Icons.celebration_rounded, type: CategoryType.income),
    const Category(id: 'other_income', name: 'Outros', icon: Icons.more_horiz_rounded, type: CategoryType.income),
    // Investimentos
    const Category(id: 'stocks', name: 'Ações', icon: Icons.bar_chart_rounded, type: CategoryType.investment),
    const Category(id: 'crypto', name: 'Cripto', icon: Icons.currency_bitcoin, type: CategoryType.investment),
    const Category(id: 'fixed', name: 'Renda Fixa', icon: Icons.security_rounded, type: CategoryType.investment),
    const Category(id: 'other_invest', name: 'Outros', icon: Icons.more_horiz_rounded, type: CategoryType.investment),
  ];

  static List<Category> getAll() => List.unmodifiable(_categories);

  static List<Category> getByType(CategoryType type) =>
      _categories.where((c) => c.type == type).toList();

  static void add(Category category) => _categories.add(category);
}

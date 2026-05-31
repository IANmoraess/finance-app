import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';

class IconPickerScreen extends StatefulWidget {
  final IconData current;
  final Color accentColor;
  const IconPickerScreen({required this.current, required this.accentColor, super.key});

  @override
  State<IconPickerScreen> createState() => _IconPickerScreenState();
}

class _IconPickerScreenState extends State<IconPickerScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const _groups = [
    _Group('Geral', [
      _E('Estrela',      Icons.star_rounded),
      _E('Favorito',     Icons.favorite_rounded),
      _E('Bandeira',     Icons.flag_rounded),
      _E('Favoritar',    Icons.bookmark_rounded),
      _E('Notificação',  Icons.notifications_rounded),
      _E('Calendário',   Icons.calendar_today_rounded),
      _E('Horário',      Icons.schedule_rounded),
      _E('Localização',  Icons.location_on_rounded),
      _E('Brilho',       Icons.auto_awesome_rounded),
      _E('Etiqueta',     Icons.label_rounded),
      _E('Emoji',        Icons.emoji_emotions_rounded),
      _E('Celebração',   Icons.celebration_rounded),
    ]),
    _Group('Alimentação', [
      _E('Restaurante',  Icons.restaurant_rounded),
      _E('Café',         Icons.coffee_rounded),
      _E('Pizza',        Icons.local_pizza_rounded),
      _E('Bolo',         Icons.cake_rounded),
      _E('Almoço',       Icons.lunch_dining_rounded),
      _E('Sorvete',      Icons.icecream_rounded),
      _E('Cafeteria',    Icons.local_cafe_rounded),
      _E('Fast food',    Icons.fastfood_rounded),
      _E('Natural',      Icons.eco_rounded),
      _E('Jantar',       Icons.dinner_dining_rounded),
      _E('Padaria',      Icons.bakery_dining_rounded),
      _E('Macarrão',     Icons.ramen_dining_rounded),
    ]),
    _Group('Mercado & Compras', [
      _E('Carrinho',     Icons.shopping_cart_rounded),
      _E('Sacola',       Icons.shopping_bag_rounded),
      _E('Mercado',      Icons.local_grocery_store_rounded),
      _E('Loja',         Icons.store_rounded),
      _E('Presente',     Icons.card_giftcard_rounded),
      _E('Roupa',        Icons.checkroom_rounded),
      _E('Diamante',     Icons.diamond_rounded),
      _E('Cartão',       Icons.credit_card_rounded),
      _E('Recibo',       Icons.receipt_long_rounded),
      _E('Vitrine',      Icons.storefront_rounded),
      _E('Shopping',     Icons.local_mall_rounded),
      _E('Relógio',      Icons.watch_rounded),
    ]),
    _Group('Casa & Contas', [
      _E('Casa',         Icons.home_rounded),
      _E('Luz',          Icons.lightbulb_rounded),
      _E('Energia',      Icons.power_rounded),
      _E('Água',         Icons.water_drop_rounded),
      _E('Gás',          Icons.local_fire_department_rounded),
      _E('Internet',     Icons.wifi_rounded),
      _E('Chave',        Icons.key_rounded),
      _E('Cama',         Icons.bed_rounded),
      _E('Ferramentas',  Icons.build_rounded),
      _E('Lavanderia',   Icons.local_laundry_service_rounded),
      _E('Limpeza',      Icons.cleaning_services_rounded),
      _E('Cozinha',      Icons.kitchen_rounded),
    ]),
    _Group('Transporte', [
      _E('Carro',        Icons.directions_car_rounded),
      _E('Ônibus',       Icons.directions_bus_rounded),
      _E('Trem',         Icons.train_rounded),
      _E('Avião',        Icons.flight_rounded),
      _E('Bicicleta',    Icons.pedal_bike_rounded),
      _E('Combustível',  Icons.local_gas_station_rounded),
      _E('Barco',        Icons.directions_boat_rounded),
      _E('Caminhão',     Icons.local_shipping_rounded),
      _E('Mapa',         Icons.map_rounded),
      _E('A pé',         Icons.directions_walk_rounded),
      _E('Táxi',         Icons.airport_shuttle_rounded),
      _E('Moto',         Icons.two_wheeler_rounded),
    ]),
    _Group('Saúde & Bem-estar', [
      _E('Saúde',        Icons.health_and_safety_rounded),
      _E('Remédio',      Icons.medication_rounded),
      _E('Academia',     Icons.fitness_center_rounded),
      _E('Vacina',       Icons.vaccines_rounded),
      _E('Psicologia',   Icons.psychology_rounded),
      _E('Spa',          Icons.spa_rounded),
      _E('Esporte',      Icons.sports_rounded),
      _E('Meditação',    Icons.self_improvement_rounded),
      _E('Médico',       Icons.medical_services_rounded),
      _E('Acessibilidade', Icons.accessibility_new_rounded),
      _E('Coração',      Icons.monitor_heart_rounded),
      _E('Temperatura',  Icons.thermostat_rounded),
    ]),
    _Group('Lazer & Educação', [
      _E('Games',        Icons.sports_esports_rounded),
      _E('Cinema',       Icons.movie_rounded),
      _E('Música',       Icons.music_note_rounded),
      _E('Livro',        Icons.menu_book_rounded),
      _E('Escola',       Icons.school_rounded),
      _E('Ingresso',     Icons.confirmation_number_rounded),
      _E('Arte',         Icons.palette_rounded),
      _E('Foto',         Icons.photo_camera_rounded),
      _E('TV',           Icons.tv_rounded),
      _E('Fone',         Icons.headphones_rounded),
      _E('Troféu',       Icons.emoji_events_rounded),
      _E('Futebol',      Icons.sports_soccer_rounded),
    ]),
    _Group('Pets & Família', [
      _E('Pet',          Icons.pets_rounded),
      _E('Criança',      Icons.child_care_rounded),
      _E('Pessoas',      Icons.people_rounded),
      _E('Família',      Icons.family_restroom_rounded),
      _E('Jardim',       Icons.grass_rounded),
      _E('Parque',       Icons.park_rounded),
      _E('Vegano',       Icons.cruelty_free_rounded),
      _E('Natureza',     Icons.nature_rounded),
    ]),
    _Group('Trabalho & Renda', [
      _E('Trabalho',     Icons.work_rounded),
      _E('Computador',   Icons.laptop_mac_rounded),
      _E('Pagamento',    Icons.payments_rounded),
      _E('Carteira',     Icons.account_balance_wallet_rounded),
      _E('Empresa',      Icons.business_rounded),
      _E('Parceria',     Icons.handshake_rounded),
      _E('E-mail',       Icons.email_rounded),
      _E('Telefone',     Icons.phone_rounded),
      _E('Tarefa',       Icons.assignment_rounded),
      _E('Calcular',     Icons.calculate_rounded),
      _E('Imprimir',     Icons.print_rounded),
      _E('Estoque',      Icons.inventory_2_rounded),
    ]),
    _Group('Investimentos', [
      _E('Alta',         Icons.trending_up_rounded),
      _E('Baixa',        Icons.trending_down_rounded),
      _E('Pizza',        Icons.pie_chart_rounded),
      _E('Bitcoin',      Icons.currency_bitcoin_rounded),
      _E('Banco',        Icons.account_balance_rounded),
      _E('Poupança',     Icons.savings_rounded),
      _E('Dinheiro',     Icons.attach_money_rounded),
      _E('Porcentagem',  Icons.percent_rounded),
      _E('Gráfico',      Icons.show_chart_rounded),
      _E('Barras',       Icons.bar_chart_rounded),
      _E('Moeda',        Icons.monetization_on_rounded),
      _E('Variação',     Icons.price_change_rounded),
    ]),
  ];

  List<_Group> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return _groups;
    return _groups
        .map((g) => _Group(g.label, g.entries.where((e) => e.name.toLowerCase().contains(q)).toList()))
        .where((g) => g.entries.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Escolher ícone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar ícone…',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _query = ''); },
                        child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Groups
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text('Nenhum ícone encontrado para "$_query"',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final group = filtered[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(group.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              )),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: group.entries.map((entry) {
                              final active = widget.current == entry.icon;
                              return GestureDetector(
                                onTap: () => Navigator.pop(context, entry.icon),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? widget.accentColor.withOpacity(0.15)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: active ? widget.accentColor : AppColors.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(entry.icon, size: 20,
                                      color: active ? widget.accentColor : AppColors.textSecondary),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _E {
  final String name;
  final IconData icon;
  const _E(this.name, this.icon);
}

class _Group {
  final String label;
  final List<_E> entries;
  const _Group(this.label, this.entries);
}

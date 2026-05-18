import 'package:financeapp/common/const/colors.dart';
import 'package:flutter/material.dart';

class LoginScreem extends StatelessWidget {
  const LoginScreem({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = const [
      InfoCard(
        title: 'Entradas',
        color: Color(0xFF00E475),
      ),
      InfoCard(
        title: 'Investimentos',
        color: Color(0xFF9961FF),
      ),
      InfoCard(
        title: 'Gastos',
        color: Color(0xFFFF5454),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.dark_background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CARD PRINCIPAL
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Atual',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          CurrencyText(size: 36),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: TrendingUp(value: 5.1),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CARDS RESPONSIVOS
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    return Column(
                      children: [
                        ...cards
                            .expand((w) => [w, const SizedBox(height: 12)])
                            .toList()
                          ..removeLast(),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      ...cards
                          .map((w) => Expanded(child: w))
                          .expand((w) => [w, const SizedBox(width: 12)])
                          .toList()
                        ..removeLast(),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // GRÁFICO
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // RECENTES
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🔹 CARD PADRONIZADO
//
class InfoCard extends StatelessWidget {
  final String title;
  final Color color;

  const InfoCard({
    required this.title,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700, // fundo neutro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dot(),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          CurrencyText(
            size: 20,
            color: color, // 👈 mesma cor da bolinha
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color, // 👈 cor dinâmica
        shape: BoxShape.circle,
      ),
    );
  }
}

//
// 💰 TEXTO DE MOEDA
//
class CurrencyText extends StatelessWidget {
  final double size;
  final Color color;

  const CurrencyText({
    this.size = 24,
    this.color = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'R\$',
          style: TextStyle(
            color: color, // 👈 mais suave
            fontSize: size * 1,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '1000',
          style: TextStyle(
            color: color, // 👈 cor principal
            fontSize: size,
          ),
        ),
      ],
    );
  }
}

//
// 📈 BADGE DE CRESCIMENTO
//
class TrendingUp extends StatelessWidget {
  final double value;

  const TrendingUp({
    this.value = 0.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00E475);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '+${value.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
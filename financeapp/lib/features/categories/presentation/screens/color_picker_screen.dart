import 'package:flutter/material.dart';
import 'package:financeapp/core/theme/app_colors.dart';

class ColorPickerScreen extends StatelessWidget {
  final Color current;
  const ColorPickerScreen({required this.current, super.key});

  static const _groups = [
    _Group('Vermelhos & Rosas', [
      Color(0xFFFB5757), Color(0xFFEF4444), Color(0xFFF43F5E),
      Color(0xFFEC4899), Color(0xFFDB2777), Color(0xFFBE123C),
    ]),
    _Group('Laranjas & Âmbar', [
      Color(0xFFF97316), Color(0xFFFB923C), Color(0xFFEA580C),
      Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFD97706),
    ]),
    _Group('Amarelos & Limão', [
      Color(0xFFEAB308), Color(0xFFFACC15), Color(0xFFA3E635),
      Color(0xFF84CC16), Color(0xFF65A30D), Color(0xFFBEF264),
    ]),
    _Group('Verdes', [
      Color(0xFF22C55E), Color(0xFF16A34A), Color(0xFF10B981),
      Color(0xFF34D399), Color(0xFF14B8A6), Color(0xFF059669),
    ]),
    _Group('Azuis & Ciano', [
      Color(0xFF06B6D4), Color(0xFF38BDF8), Color(0xFF0EA5E9),
      Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF0284C7),
    ]),
    _Group('Roxos & Índigo', [
      Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFF8B5CF6),
      Color(0xFFA855F7), Color(0xFF7C3AED), Color(0xFFC084FC),
    ]),
    _Group('Neutros', [
      Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569),
      Color(0xFF78716C), Color(0xFFA8A29E), Color(0xFF6B7280),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Escolher cor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        itemCount: _groups.length,
        itemBuilder: (context, i) {
          final group = _groups[i];
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
                children: group.colors.map((c) {
                  final active = current.value == c.value;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                      child: active
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Group {
  final String label;
  final List<Color> colors;
  const _Group(this.label, this.colors);
}

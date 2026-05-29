import 'package:flutter/material.dart';
import '../models/category.dart';

const _kAccent = Color(0xFFFF5454);
const _kBg = Color(0xFF1F2133);
const _kSurface = Color(0xFF2A2D42);

Future<Category?> showCategoryPicker(
  BuildContext context,
  Category? selected,
) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryPickerSheet(selected: selected),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  final Category? selected;
  const _CategoryPickerSheet({this.selected});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late Category? _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  List<Category> get _filtered {
    if (_query.isEmpty) return kExpenseCategories;
    final q = _query.toLowerCase();
    return kExpenseCategories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.65, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _DragHandle(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Categorias',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: Colors.white38, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SearchField(
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filtered.isEmpty
                    ? _EmptyState()
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final cat = _filtered[i];
                          return _CategoryTile(
                            category: cat,
                            selected: _selected?.id == cat.id,
                            onTap: () => Navigator.of(context).pop(cat),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar categoria...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
        filled: true,
        fillColor: _kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? _kAccent.withOpacity(0.12) : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _kAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              color: selected ? _kAccent : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? _kAccent : Colors.white60,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off_rounded, color: Colors.white24, size: 48),
          SizedBox(height: 12),
          Text(
            'Nenhuma categoria encontrada',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

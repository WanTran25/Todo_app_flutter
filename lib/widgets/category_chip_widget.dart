import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryChipWidget extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback? onTap;
  final bool showIcon;
  final bool showCount;
  final int? count;
  final double? size;

  const CategoryChipWidget({
    required this.category,
    this.selected = false,
    this.onTap,
    this.showIcon = true,
    this.showCount = false,
    this.count,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final chipSize = size ?? (showCount ? 140.0 : 120.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: chipSize,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? category.color : category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? category.color : category.color.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Colors.white : category.color,
                ),
              ),
            if (showIcon) const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getDisplayText(),
                style: TextStyle(
                  color: selected ? Colors.white : category.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (showCount && count != null) return '${category.name} ($count)';
    return category.name;
  }
}

// Filter chips
class CategoryFilterChips extends StatefulWidget {
  final Category? selectedCategory;
  final ValueChanged<Category?>? onCategorySelected;
  final List<Category> categories;
  final Map<String, int>? categoryCounts; // key: categoryId

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    required this.categories,
    this.categoryCounts,
  });

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  Category? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _selected == null,
          onSelected: (_) {
            setState(() => _selected = null);
            widget.onCategorySelected?.call(null);
          },
          selectedColor: Colors.blue,
          labelStyle: TextStyle(
            color: _selected == null ? Colors.white : Colors.black,
          ),
        ),
        ...widget.categories.map((c) {
          final count = widget.categoryCounts?[c.id] ?? 0;
          return ChoiceChip(
            label: Text(widget.categoryCounts != null ? '${c.name} ($count)' : c.name),
            selected: _selected?.id == c.id,
            onSelected: (_) {
              setState(() => _selected = c);
              widget.onCategorySelected?.call(c);
            },
            selectedColor: c.color,
            backgroundColor: c.color.withOpacity(0.1),
            labelStyle: TextStyle(
              color: _selected?.id == c.id ? Colors.white : Colors.black,
            ),
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';

class CategoryChipWidget extends StatelessWidget {
  final TaskCategory category;
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
    final chipSize = size ?? (showCount ? 100.0 : 80.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: chipSize,
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? category.color
              : category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? category.color
                : category.color.withOpacity(0.3),
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
            if (showIcon) SizedBox(width: 8),
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
    if (showCount && count != null) {
      return '${category.name.split(' ')[0]} ($count)';
    }
    return category.name.split(' ')[0];
  }
}

// Category Filter Chips
class CategoryFilterChips extends StatefulWidget {
  final TaskCategory? selectedCategory;
  final ValueChanged<TaskCategory?>? onCategorySelected;
  final Map<TaskCategory, int>? categoryCounts;

  const CategoryFilterChips({
    this.selectedCategory,
    this.onCategorySelected,
    this.categoryCounts,
  });

  @override
  _CategoryFilterChipsState createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // All Categories chip
        ChoiceChip(
          label: Text('All'),
          selected: _selectedCategory == null,
          onSelected: (selected) {
            setState(() => _selectedCategory = null);
            widget.onCategorySelected?.call(null);
          },
          selectedColor: Colors.blue,
          labelStyle: TextStyle(
            color: _selectedCategory == null ? Colors.white : Colors.black,
          ),
        ),
        
        // Category chips
        ...TaskCategory.values.map((category) {
          final count = widget.categoryCounts?[category] ?? 0;
          return ChoiceChip(
            label: Text(
              widget.categoryCounts != null
                  ? '${category.name.split(' ')[0]} ($count)'
                  : category.name.split(' ')[0],
            ),
            selected: _selectedCategory == category,
            onSelected: (selected) {
              setState(() => _selectedCategory = category);
              widget.onCategorySelected?.call(category);
            },
            selectedColor: category.color,
            backgroundColor: category.color.withOpacity(0.1),
            labelStyle: TextStyle(
              color: _selectedCategory == category ? Colors.white : Colors.black,
            ),
            avatar: CircleAvatar(
              backgroundColor: _selectedCategory == category
                  ? Colors.white
                  : category.color,
              radius: 8,
            ),
          );
        }),
      ],
    );
  }
}

// Category Selection Grid
class CategorySelectionGrid extends StatelessWidget {
  final TaskCategory? selectedCategory;
  final ValueChanged<TaskCategory> onCategorySelected;

  const CategorySelectionGrid({
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: TaskCategory.values.length,
      itemBuilder: (context, index) {
        final category = TaskCategory.values[index];
        final isSelected = selectedCategory == category;
        
        return GestureDetector(
          onTap: () => onCategorySelected(category),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? category.color
                  : category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? category.color
                    : category.color.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : category.color,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category.name.split(' ')[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : category.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
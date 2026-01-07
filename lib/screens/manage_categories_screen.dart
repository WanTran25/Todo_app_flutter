import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  bool _loading = true;
  List<Category> _categories = [];

  // Một số màu preset cho dễ chọn
  final List<Color> _presetColors = const [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    final cats = await _db.getAllCategories();
    cats.sort((a, b) {
      if (a.id == DatabaseHelper.uncategorizedId) return -1;
      if (b.id == DatabaseHelper.uncategorizedId) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  Future<void> _showCategoryDialog({Category? existing}) async {
    final isEdit = existing != null;
    final controller = TextEditingController(text: existing?.name ?? '');
    int selectedColorValue =
        existing?.colorValue ?? _presetColors.first.value;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Create Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetColors.map((c) {
                  final selected = selectedColorValue == c.value;
                  return GestureDetector(
                    onTap: () {
                      selectedColorValue = c.value;
                      // rebuild dialog
                      (context as Element).markNeedsBuild();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              if (isEdit) {
                // Không cho edit UNCATEGORIZED để khỏi rối
                if (existing!.id == DatabaseHelper.uncategorizedId) {
                  Navigator.pop(context, false);
                  return;
                }
                final updated = existing.copyWith(
                  name: name,
                  colorValue: selectedColorValue,
                );
                await _db.updateCategory(updated);
              } else {
                await _db.createCategory(
                  name: name,
                  colorValue: selectedColorValue,
                );
              }
              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.id == DatabaseHelper.uncategorizedId) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "${category.name}"?\n\nAll tasks in this category will be moved to UNCATEGORIZED.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _db.deleteCategory(category.id);
      if (!mounted) return;
      _loadCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadCategories,
        child: ListView.separated(
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = _categories[index];
            final isUnc = c.id == DatabaseHelper.uncategorizedId;

            return ListTile(
              leading: CircleAvatar(backgroundColor: c.color),
              title: Text(c.name),
              subtitle: Text(isUnc ? 'Default (cannot delete)' : c.createdAt.toString()),
              onTap: isUnc ? null : () => _showCategoryDialog(existing: c),
              trailing: isUnc
                  ? null
                  : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategory(c),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

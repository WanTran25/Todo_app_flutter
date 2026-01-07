import 'dart:math';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const String _tasksKey = 'tasks_list';
  static const String _nextTaskIdKey = 'next_task_id';

  static const String _categoriesKey = 'categories_list';

  /// ID mặc định cho category "UNCATEGORIZED"
  static const String uncategorizedId = kUncategorizedCategoryId;

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // -----------------------------
  // Seed categories (Option C)
  // -----------------------------
  List<Category> _defaultSeedCategories() => [
    Category(
      id: uncategorizedId,
      name: 'UNCATEGORIZED',
      colorValue: Colors.grey.value,
    ),
    Category(id: 'sportApp', name: 'SPORT APP', colorValue: Colors.green.value),
    Category(id: 'medicalApp', name: 'MEDICAL APP', colorValue: Colors.blue.value),
    Category(id: 'rentApp', name: 'RENT APP', colorValue: Colors.orange.value),
    Category(id: 'notes', name: 'NOTES', colorValue: Colors.purple.value),
    Category(
      id: 'gamingPlatform',
      name: 'GAMING PLATFORM APP',
      colorValue: Colors.red.value,
    ),
  ];

  Future<void> _ensureSeedCategories() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_categoriesKey);

    if (raw != null && raw.isNotEmpty) return;

    final seeds = _defaultSeedCategories();
    await prefs.setStringList(
      _categoriesKey,
      seeds.map((c) => c.toJson()).toList(),
    );
  }

  // -----------------------------
  // CATEGORY CRUD
  // -----------------------------
  Future<List<Category>> getAllCategories() async {
    try {
      await _ensureSeedCategories();
      final prefs = await _prefs;
      final raw = prefs.getStringList(_categoriesKey) ?? [];
      final result = <Category>[];

      for (final s in raw) {
        try {
          result.add(Category.fromJson(s));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing category: $e | $s');
          }
        }
      }

      // đảm bảo uncategorized luôn có
      if (!result.any((c) => c.id == uncategorizedId)) {
        result.insert(
          0,
          Category(id: uncategorizedId, name: 'UNCATEGORIZED', colorValue: Colors.grey.value),
        );
        await _saveCategories(result);
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getAllCategories: $e');
      }
      return [
        Category(id: uncategorizedId, name: 'UNCATEGORIZED', colorValue: Colors.grey.value),
      ];
    }
  }

  Future<Map<String, Category>> getCategoryMap() async {
    final list = await getAllCategories();
    return {for (final c in list) c.id: c};
  }

  Future<Category?> getCategoryById(String id) async {
    final map = await getCategoryMap();
    return map[id];
  }

  Future<void> _saveCategories(List<Category> categories) async {
    final prefs = await _prefs;
    await prefs.setStringList(_categoriesKey, categories.map((c) => c.toJson()).toList());
  }

  String _generateCategoryId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(1 << 32);
    return 'c_${ts.toRadixString(16)}_${r.toRadixString(16)}';
  }

  Future<String> createCategory({
    required String name,
    required int colorValue,
  }) async {
    try {
      await _ensureSeedCategories();
      final categories = await getAllCategories();
      final id = _generateCategoryId();
      categories.add(Category(id: id, name: name.trim(), colorValue: colorValue));
      await _saveCategories(categories);
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error createCategory: $e');
      }
      return '';
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      if (category.id == uncategorizedId) return false; // tránh rối
      final categories = await getAllCategories();
      final idx = categories.indexWhere((c) => c.id == category.id);
      if (idx == -1) return false;
      categories[idx] = category;
      await _saveCategories(categories);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updateCategory: $e');
      }
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      if (categoryId == uncategorizedId) return false;

      final categories = await getAllCategories();
      if (!categories.any((c) => c.id == categoryId)) return false;

      // Move all tasks -> UNCATEGORIZED
      final tasks = await getAllTasks();
      bool changed = false;
      for (final t in tasks) {
        if (t.categoryId == categoryId) {
          t.categoryId = uncategorizedId;
          changed = true;
        }
      }
      if (changed) {
        await _saveTasks(tasks);
      }

      categories.removeWhere((c) => c.id == categoryId);
      await _saveCategories(categories);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleteCategory: $e');
      }
      return false;
    }
  }

  // -----------------------------
  // TASK CRUD (giữ gần như cũ)
  // -----------------------------

  Future<int> _getNextTaskId() async {
    final prefs = await _prefs;
    int nextId = prefs.getInt(_nextTaskIdKey) ?? 1;
    await prefs.setInt(_nextTaskIdKey, nextId + 1);
    return nextId;
  }

  Future<List<Task>> getAllTasks() async {
    try {
      await _ensureSeedCategories();
      final prefs = await _prefs;
      final tasksRaw = prefs.getStringList(_tasksKey) ?? [];

      final tasks = <Task>[];
      for (final raw in tasksRaw) {
        try {
          final t = Task.fromJson(raw);
          // nếu categoryId rỗng -> uncategorized
          if (t.categoryId.trim().isEmpty) t.categoryId = uncategorizedId;
          tasks.add(t);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing task: $e, raw: $raw');
          }
        }
      }

      // nếu task tham chiếu categoryId không tồn tại -> chuyển về uncategorized (không bắt buộc save ngay)
      final catMap = await getCategoryMap();
      for (final t in tasks) {
        if (!catMap.containsKey(t.categoryId)) {
          t.categoryId = uncategorizedId;
        }
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('Error getAllTasks: $e');
      }
      return [];
    }
  }

  Future<Task?> getTaskById(int id) async {
    try {
      final tasks = await getAllTasks();
      for (final t in tasks) {
        if (t.id == id) return t;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getTaskById: $e');
      }
      return null;
    }
  }

  Future<int> insertTask(Task task) async {
    try {
      final tasks = await getAllTasks();
      final newId = await _getNextTaskId();

      final newTask = Task(
        id: newId,
        title: task.title,
        description: task.description,
        startTime: task.startTime,
        endTime: task.endTime,
        status: task.status,
        categoryId: task.categoryId.isNotEmpty ? task.categoryId : uncategorizedId,
        notes: task.notes,
        createdAt: task.createdAt,
      );

      tasks.add(newTask);
      await _saveTasks(tasks);
      return newId;
    } catch (e) {
      if (kDebugMode) {
        print('Error insertTask: $e');
      }
      return -1;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final tasks = await getAllTasks();
      final idx = tasks.indexWhere((t) => t.id == task.id);
      if (idx == -1) return false;
      tasks[idx] = task;
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updateTask: $e');
      }
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      final tasks = await getAllTasks();
      tasks.removeWhere((t) => t.id == id);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleteTask: $e');
      }
      return false;
    }
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    try {
      final prefs = await _prefs;
      final raw = tasks.map((t) => t.toJson()).toList();
      await prefs.setStringList(_tasksKey, raw);
    } catch (e) {
      if (kDebugMode) {
        print('Error _saveTasks: $e');
      }
    }
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((t) {
        return t.startTime.year == date.year &&
            t.startTime.month == date.month &&
            t.startTime.day == date.day;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getTasksByDate: $e');
      }
      return [];
    }
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((t) => t.status == status).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getTasksByStatus: $e');
      }
      return [];
    }
  }

  /// ✅ Thay vì enum TaskCategory: lọc theo categoryId
  Future<List<Task>> getTasksByCategoryId(String categoryId) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((t) => t.categoryId == categoryId).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getTasksByCategoryId: $e');
      }
      return [];
    }
  }

  Future<Map<TaskStatus, int>> getTaskStats() async {
    try {
      final tasks = await getAllTasks();
      final stats = {
        TaskStatus.todo: 0,
        TaskStatus.inProgress: 0,
        TaskStatus.done: 0,
      };
      for (final t in tasks) {
        stats[t.status] = (stats[t.status] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getTaskStats: $e');
      }
      return {
        TaskStatus.todo: 0,
        TaskStatus.inProgress: 0,
        TaskStatus.done: 0,
      };
    }
  }

  /// ✅ Category stats mới: Map<categoryId, count>
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final tasks = await getAllTasks();
      final catMap = await getCategoryMap();

      final stats = <String, int>{
        for (final id in catMap.keys) id: 0,
      };

      for (final t in tasks) {
        final id = catMap.containsKey(t.categoryId) ? t.categoryId : uncategorizedId;
        stats[id] = (stats[id] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getCategoryStats: $e');
      }
      return {uncategorizedId: 0};
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.isEmpty) return await getAllTasks();
      final tasks = await getAllTasks();
      final q = query.toLowerCase();

      return tasks.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            (t.notes != null && t.notes!.toLowerCase().contains(q));
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searchTasks: $e');
      }
      return [];
    }
  }

  Future<List<Task>> getRecentTasks({int limit = 5}) async {
    try {
      final tasks = await getAllTasks();
      return tasks.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getRecentTasks: $e');
      }
      return [];
    }
  }

  Future<void> clearAllTasks() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tasksKey);
      await prefs.remove(_nextTaskIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearAllTasks: $e');
      }
    }
  }

  Future<bool> hasTasks() async {
    final tasks = await getAllTasks();
    return tasks.isNotEmpty;
  }
}

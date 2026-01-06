import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() {
    return _instance;
  }
  
  DatabaseHelper._internal();
  
  static const String _tasksKey = 'tasks_list';
  static const String _nextIdKey = 'next_task_id';
  
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
  
  // Lấy ID tiếp theo cho task mới
  Future<int> _getNextId() async {
    final prefs = await _prefs;
    int nextId = prefs.getInt(_nextIdKey) ?? 1;
    await prefs.setInt(_nextIdKey, nextId + 1);
    return nextId;
  }
  
  // Lấy tất cả tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final prefs = await _prefs;
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];
      
      final List<Task> tasks = [];
      
      for (var json in tasksJson) {
        try {
          final task = Task.fromJson(json);
          tasks.add(task);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing task JSON: $e, JSON: $json');
          }
        }
      }
      
      // Sắp xếp theo thời gian tạo (mới nhất trước)
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks: $e');
      }
      return [];
    }
  }
  
  // Lấy task theo ID - SỬA LỖI Ở ĐÂY
  Future<Task?> getTaskById(int id) async {
    try {
      final tasks = await getAllTasks();
      for (var task in tasks) {
        if (task.id == id) {
          return task;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task by id: $e');
      }
      return null;
    }
  }
  
  // Thêm task mới
  Future<int> insertTask(Task task) async {
    try {
      final tasks = await getAllTasks();
      final newId = await _getNextId();
      
      final newTask = Task(
        id: newId,
        title: task.title,
        description: task.description,
        startTime: task.startTime,
        endTime: task.endTime,
        status: task.status,
        category: task.category,
        notes: task.notes,
        createdAt: task.createdAt,
      );
      
      tasks.add(newTask);
      await _saveTasks(tasks);
      
      return newId;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting task: $e');
      }
      return -1;
    }
  }
  
  // Cập nhật task
  Future<bool> updateTask(Task task) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      
      if (index != -1) {
        tasks[index] = task;
        await _saveTasks(tasks);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      return false;
    }
  }
  
  // Xóa task
  Future<bool> deleteTask(int id) async {
    try {
      final tasks = await getAllTasks();
      tasks.removeWhere((task) => task.id == id);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      return false;
    }
  }
  
  // Lưu tasks vào SharedPreferences
  Future<void> _saveTasks(List<Task> tasks) async {
    try {
      final prefs = await _prefs;
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      await prefs.setStringList(_tasksKey, tasksJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tasks: $e');
      }
    }
  }
  
  // Lấy tasks theo ngày
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) {
        return task.startTime.year == date.year &&
               task.startTime.month == date.month &&
               task.startTime.day == date.day;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by date: $e');
      }
      return [];
    }
  }
  
  // Lấy tasks theo trạng thái
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.status == status).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by status: $e');
      }
      return [];
    }
  }
  
  // Lấy tasks theo category
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.category == category).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by category: $e');
      }
      return [];
    }
  }
  
  // Thống kê tasks
  Future<Map<TaskStatus, int>> getTaskStats() async {
    try {
      final tasks = await getAllTasks();
      final stats = {
        TaskStatus.todo: 0,
        TaskStatus.inProgress: 0,
        TaskStatus.done: 0,
      };
      
      for (var task in tasks) {
        stats[task.status] = (stats[task.status] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task stats: $e');
      }
      return {
        TaskStatus.todo: 0,
        TaskStatus.inProgress: 0,
        TaskStatus.done: 0,
      };
    }
  }
  
  // Thống kê theo category
  Future<Map<TaskCategory, int>> getCategoryStats() async {
    try {
      final tasks = await getAllTasks();
      final stats = <TaskCategory, int>{};
      
      // Khởi tạo tất cả categories với giá trị 0
      for (var category in TaskCategory.values) {
        stats[category] = 0;
      }
      
      // Đếm số lượng tasks cho mỗi category
      for (var task in tasks) {
        stats[task.category] = (stats[task.category] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting category stats: $e');
      }
      final emptyStats = <TaskCategory, int>{};
      for (var category in TaskCategory.values) {
        emptyStats[category] = 0;
      }
      return emptyStats;
    }
  }
  
  // Tìm kiếm tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.isEmpty) return await getAllTasks();
      
      final tasks = await getAllTasks();
      final lowercaseQuery = query.toLowerCase();
      
      return tasks.where((task) {
        return task.title.toLowerCase().contains(lowercaseQuery) ||
               task.description.toLowerCase().contains(lowercaseQuery) ||
               (task.notes != null && 
                task.notes!.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching tasks: $e');
      }
      return [];
    }
  }
  
  // Lấy recent tasks
  Future<List<Task>> getRecentTasks({int limit = 5}) async {
    try {
      final tasks = await getAllTasks();
      return tasks.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent tasks: $e');
      }
      return [];
    }
  }
  
  // Xóa tất cả tasks (dùng cho testing)
  Future<void> clearAllTasks() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_tasksKey);
      await prefs.remove(_nextIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing tasks: $e');
      }
    }
  }
  
  // Kiểm tra xem có tasks nào không
  Future<bool> hasTasks() async {
    final tasks = await getAllTasks();
    return tasks.isNotEmpty;
  }
}
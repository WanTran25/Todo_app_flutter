import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskStatus { todo, inProgress, done }
enum TaskCategory { sportApp, medicalApp, rentApp, notes, gamingPlatform }

extension TaskCategoryExtension on TaskCategory {
  String get name {
    switch (this) {
      case TaskCategory.sportApp:
        return 'SPORT APP';
      case TaskCategory.medicalApp:
        return 'MEDICAL APP';
      case TaskCategory.rentApp:
        return 'RENT APP';
      case TaskCategory.notes:
        return 'NOTES';
      case TaskCategory.gamingPlatform:
        return 'GAMING PLATFORM APP';
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.sportApp:
        return Colors.green;
      case TaskCategory.medicalApp:
        return Colors.blue;
      case TaskCategory.rentApp:
        return Colors.orange;
      case TaskCategory.notes:
        return Colors.purple;
      case TaskCategory.gamingPlatform:
        return Colors.red;
    }
  }
}

class Task {
  int? id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  TaskStatus status;
  TaskCategory category;
  DateTime createdAt;
  String? notes;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.status = TaskStatus.todo,
    required this.category,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  // Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.index,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Tạo Task từ Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      status: TaskStatus.values[map['status'] as int],
      category: TaskCategory.values[map['category'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String?,
    );
  }

  // Chuyển đổi thành JSON string để lưu
  String toJson() {
    final map = toMap();
    // Sử dụng dấu phân cách đặc biệt để tránh conflict
    return '${map['id'] ?? ""}||${map['title']}||${map['description']}||${map['startTime']}||${map['endTime']}||${map['status']}||${map['category']}||${map['createdAt']}||${map['notes'] ?? ""}';
  }

  // Tạo Task từ JSON string
  factory Task.fromJson(String json) {
    try {
      final parts = json.split('||');
      if (parts.length != 9) {
        throw FormatException('Invalid JSON format');
      }
      
      return Task(
        id: parts[0].isNotEmpty ? int.parse(parts[0]) : null,
        title: parts[1],
        description: parts[2],
        startTime: DateTime.parse(parts[3]),
        endTime: DateTime.parse(parts[4]),
        status: TaskStatus.values[int.parse(parts[5])],
        category: TaskCategory.values[int.parse(parts[6])],
        createdAt: DateTime.parse(parts[7]),
        notes: parts[8].isNotEmpty ? parts[8] : null,
      );
    } catch (e) {
      print('Error parsing Task from JSON: $e, JSON: $json');
      rethrow;
    }
  }

  String get formattedTime {
    final start = DateFormat('HH:mm').format(startTime);
    final end = DateFormat('HH:mm').format(endTime);
    return '$start - $end';
  }

  Duration get duration => endTime.difference(startTime);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
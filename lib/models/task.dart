import 'dart:convert';
import 'package:intl/intl.dart';

enum TaskStatus { todo, inProgress, done }

/// Category ID mặc định khi category bị xoá / không tồn tại
const String kUncategorizedCategoryId = 'uncategorized';

class Task {
  int? id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  TaskStatus status;
  String categoryId;
  DateTime createdAt;
  String? notes;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.status = TaskStatus.todo,
    required this.categoryId,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.index,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final statusIndex = (map['status'] as int?) ?? 0;
    final safeStatus = (statusIndex >= 0 && statusIndex < TaskStatus.values.length)
        ? TaskStatus.values[statusIndex]
        : TaskStatus.todo;

    return Task(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      status: safeStatus,
      categoryId: (map['categoryId'] as String?) ?? kUncategorizedCategoryId,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes'] as String?,
    );
  }

  /// ✅ Lưu dạng JSON string (mới)
  String toJson() => jsonEncode(toMap());

  /// ✅ Đọc JSON mới; nếu fail thì đọc format cũ delimiter "||" (legacy)
  factory Task.fromJson(String raw) {
    // 1) thử JSON mới
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Task.fromMap(decoded);
      }
    } catch (_) {
      // ignore
    }

    // 2) fallback legacy format cũ: id||title||description||start||end||statusIndex||categoryIndex||createdAt||notes
    final parts = raw.split('||');
    if (parts.length == 9) {
      final statusIndex = int.tryParse(parts[5]) ?? 0;
      final safeStatus = (statusIndex >= 0 && statusIndex < TaskStatus.values.length)
          ? TaskStatus.values[statusIndex]
          : TaskStatus.todo;

      final legacyCatIndex = int.tryParse(parts[6]) ?? -1;
      final mappedCategoryId = _legacyCategoryIndexToId(legacyCatIndex);

      return Task(
        id: parts[0].isNotEmpty ? int.tryParse(parts[0]) : null,
        title: parts[1],
        description: parts[2],
        startTime: DateTime.parse(parts[3]),
        endTime: DateTime.parse(parts[4]),
        status: safeStatus,
        categoryId: mappedCategoryId,
        createdAt: DateTime.tryParse(parts[7]) ?? DateTime.now(),
        notes: parts[8].isNotEmpty ? parts[8] : null,
      );
    }

    // 3) nếu format lạ -> throw
    throw FormatException('Invalid task format: $raw');
  }

  static String _legacyCategoryIndexToId(int index) {
    // mapping đúng theo enum cũ của bạn:
    // 0 sportApp, 1 medicalApp, 2 rentApp, 3 notes, 4 gamingPlatform
    switch (index) {
      case 0:
        return 'sportApp';
      case 1:
        return 'medicalApp';
      case 2:
        return 'rentApp';
      case 3:
        return 'notes';
      case 4:
        return 'gamingPlatform';
      default:
        return kUncategorizedCategoryId;
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
          other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

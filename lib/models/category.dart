import 'dart:convert';
import 'package:flutter/material.dart';

/// Category động 100% (Option C)
class Category {
  final String id;
  final String name;
  final int colorValue; // Color.value (ARGB int)
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => Color(colorValue);

  Category copyWith({
    String? name,
    int? colorValue,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Unnamed',
      colorValue: (map['colorValue'] as int?) ?? Colors.grey.value,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Category.fromJson(String json) =>
      Category.fromMap(jsonDecode(json) as Map<String, dynamic>);
}

import 'task.dart';

class CategoryStats {
  final TaskCategory category;
  final int count;
  final double percentage;

  CategoryStats({
    required this.category,
    required this.count,
    required this.percentage,
  });
}
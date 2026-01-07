import 'package:flutter/material.dart' hide DateUtils;
import '../models/task.dart';
import '../models/category.dart';
import '../utils/date_utils.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final Category? category; // ✅ mới
  final VoidCallback? onTap;
  final VoidCallback? onStatusChanged;
  final bool showCategory;

  const TaskCardWidget({
    required this.task,
    required this.category,
    this.onTap,
    this.onStatusChanged,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final catName = (category?.name ?? 'UNCATEGORIZED');
    final catColor = (category?.color ?? Colors.grey);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status and Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onStatusChanged,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getStatusColor(task.status),
                                    width: 2,
                                  ),
                                ),
                                child: task.status == TaskStatus.done
                                    ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: _getStatusColor(task.status),
                                )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: task.status == TaskStatus.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.status == TaskStatus.done
                                      ? Colors.grey
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Category Chip
                  if (showCategory) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: catColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        catName,
                        style: TextStyle(
                          fontSize: 12,
                          color: catColor,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Description
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    task.formattedTime,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateUtils.formatDuration(task.duration),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),

                  const Spacer(),

                  if (!DateUtils.isToday(task.startTime))
                    Text(
                      DateUtils.getRelativeDate(task.startTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}

class TaskCardCompactWidget extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback? onTap;

  const TaskCardCompactWidget({
    required this.task,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catName = (category?.name ?? 'UNCATEGORIZED');
    final catColor = (category?.color ?? Colors.grey);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(shape: BoxShape.circle, color: catColor),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontSize: 16,
          decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${task.formattedTime} • $catName',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(task.status)),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}

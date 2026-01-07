import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Function? onTaskUpdated;

  TaskDetailScreen({
    required this.task,
    this.onTaskUpdated,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Category? _category;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _notesController.text = _task.notes ?? '';
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final cat = await _dbHelper.getCategoryById(_task.categoryId);
    if (!mounted) return;
    setState(() => _category = cat);
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: _task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _task.startTime,
      endTime: _task.endTime,
      status: _task.status,
      categoryId: _task.categoryId, // ✅ giữ category
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: _task.createdAt, // ✅ giữ createdAt
    );

    await _dbHelper.updateTask(updatedTask);
    setState(() {
      _task = updatedTask;
      _isEditing = false;
    });

    widget.onTaskUpdated?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully')),
    );
  }

  Future<void> _deleteTask() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteTask(_task.id!);
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onTaskUpdated?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    final updatedTask = Task(
      id: _task.id,
      title: _task.title,
      description: _task.description,
      startTime: _task.startTime,
      endTime: _task.endTime,
      status: newStatus,
      categoryId: _task.categoryId,
      notes: _task.notes,
      createdAt: _task.createdAt,
    );

    await _dbHelper.updateTask(updatedTask);
    setState(() => _task = updatedTask);
    widget.onTaskUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final catName = _category?.name ?? 'UNCATEGORIZED';
    final catColor = _category?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_task.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _task.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                if (!_isEditing)
                  DropdownButton<TaskStatus>(
                    value: _task.status,
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) _updateStatus(newStatus);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: catColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(backgroundColor: catColor, radius: 8),
                  const SizedBox(width: 8),
                  Text(catName, style: TextStyle(color: catColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Title
            _isEditing
                ? TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
                : Text(_task.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Date & Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(DateFormat('EEE, MMM d, yyyy').format(_task.startTime), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          '${DateFormat('HH:mm').format(_task.startTime)} - ${DateFormat('HH:mm').format(_task.endTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '(${_task.duration.inHours}h ${_task.duration.inMinutes.remainder(60)}m)',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            _isEditing
                ? TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter description'),
            )
                : Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_task.description, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            _isEditing
                ? TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Add notes...'),
            )
                : Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _task.notes != null && _task.notes!.isNotEmpty
                    ? Text(_task.notes!, style: const TextStyle(fontSize: 16))
                    : const Text('No notes added', style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Created: ${DateFormat('MMM d, yyyy - HH:mm').format(_task.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        _titleController.text = _task.title;
                        _descriptionController.text = _task.description;
                        _notesController.text = _task.notes ?? '';
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('SAVE'),
                    ),
                  ),
                ],
              ),
          ],
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

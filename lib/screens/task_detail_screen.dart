import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

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

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _notesController.text = _task.notes ?? '';
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: _task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _task.startTime,
      endTime: _task.endTime,
      status: _task.status,
      category: _task.category,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await _dbHelper.updateTask(updatedTask);
    setState(() {
      _task = updatedTask;
      _isEditing = false;
    });
    
    if (widget.onTaskUpdated != null) {
      widget.onTaskUpdated!();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task updated successfully')),
    );
  }

  Future<void> _deleteTask() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteTask(_task.id!);
              Navigator.pop(context);
              Navigator.pop(context);
              if (widget.onTaskUpdated != null) {
                widget.onTaskUpdated!();
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
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
      category: _task.category,
      notes: _task.notes,
    );

    await _dbHelper.updateTask(updatedTask);
    setState(() => _task = updatedTask);
    
    if (widget.onTaskUpdated != null) {
      widget.onTaskUpdated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_task.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _task.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (!_isEditing) ...[
                  DropdownButton<TaskStatus>(
                    value: _task.status,
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updateStatus(newStatus);
                      }
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),

            // Category Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _task.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _task.category.color),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: _task.category.color,
                    radius: 8,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _task.category.name,
                    style: TextStyle(
                      color: _task.category.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Title (Editable)
            _isEditing
                ? TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : Text(
                    _task.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            SizedBox(height: 20),

            // Date & Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_task.startTime),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          '${DateFormat('HH:mm').format(_task.startTime)} - ${DateFormat('HH:mm').format(_task.endTime)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '(${_task.duration.inHours}h ${_task.duration.inMinutes.remainder(60)}m)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            _isEditing
                ? TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description',
                    ),
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _task.description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            SizedBox(height: 20),

            // Notes
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            _isEditing
                ? TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add notes...',
                    ),
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _task.notes != null && _task.notes!.isNotEmpty
                          ? Text(
                              _task.notes!,
                              style: TextStyle(fontSize: 16),
                            )
                          : Text(
                              'No notes added',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),
            SizedBox(height: 30),

            // Created At
            Text(
              'Created: ${DateFormat('MMM d, yyyy - HH:mm').format(_task.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),

            // Save/Cancel Buttons for editing
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text('CANCEL'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('SAVE'),
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
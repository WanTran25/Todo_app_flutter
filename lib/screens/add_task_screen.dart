import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);

  String _selectedCategoryId = kUncategorizedCategoryId;
  TaskStatus _selectedStatus = TaskStatus.todo;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _loadingCategories = true;
  List<Category> _categories = [];
  Map<String, Category> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();

    final now = TimeOfDay.now();
    final endHour = now.hour + 1;
    _endTime = TimeOfDay(
      hour: endHour < 24 ? endHour : endHour - 24,
      minute: now.minute,
    );
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    final list = await _dbHelper.getAllCategories();
    final map = {for (final c in list) c.id: c};

    // chọn mặc định: uncategorized nếu có, không thì category đầu tiên
    String defaultId = DatabaseHelper.uncategorizedId;
    if (!map.containsKey(defaultId) && list.isNotEmpty) {
      defaultId = list.first.id;
    }

    setState(() {
      _categories = list;
      _categoryMap = map;
      _selectedCategoryId = defaultId;
      _loadingCategories = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categoryMap[_selectedCategoryId];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date Selection
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blue, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Start Time',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'End Time',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Duration Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_calculateDuration()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 30),

              // Category Selection (✅ dynamic)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/categories');
                      await _loadCategories();
                    },
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_loadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (_categories.isEmpty)
                const Text('No categories. Please create one.')
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((c) {
                    final selected = _selectedCategoryId == c.id;
                    return ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      selectedColor: c.color,
                      onSelected: (_) => setState(() => _selectedCategoryId = c.id),
                      backgroundColor: c.color.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                      avatar: CircleAvatar(
                        backgroundColor: selected ? Colors.white : c.color,
                        radius: 8,
                      ),
                    );
                  }).toList(),
                ),

              if (selectedCategory != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected: ${selectedCategory.name}',
                  style: TextStyle(color: selectedCategory.color, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 30),

              // Status Selection
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TaskStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(status.toString().split('.').last.toUpperCase()),
                    selected: _selectedStatus == status,
                    selectedColor: _getStatusColor(status),
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    backgroundColor: _getStatusColor(status).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: _selectedStatus == status ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 40),

              // Create Task Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CREATE TASK',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _calculateDuration() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    var durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) durationMinutes += 24 * 60;

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}'.trim();
    } else {
      return '$minutes m';
    }
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          if (endMinutes <= startMinutes) {
            _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;

      if (endMinutes <= startMinutes) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Time Warning'),
            content: const Text('End time is before or equal to start time. Do you want to continue?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
            ],
          ),
        );
        if (result != true) return;
      }

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final finalEndDateTime = endDateTime.isBefore(startDateTime)
          ? endDateTime.add(const Duration(days: 1))
          : endDateTime;

      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: finalEndDateTime,
        status: _selectedStatus,
        categoryId: _selectedCategoryId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final result = await _dbHelper.insertTask(task);

      if (!mounted) return;

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create task. Please try again.'), backgroundColor: Colors.red),
        );
      }
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

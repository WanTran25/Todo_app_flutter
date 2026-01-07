import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_card_widget.dart';
import 'task_detail_screen.dart';

class CategoryTasksScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryTasksScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryTasksScreen> createState() => _CategoryTasksScreenState();
}

class _CategoryTasksScreenState extends State<CategoryTasksScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    final tasks = await _dbHelper.getTasksByCategoryId(widget.categoryId);
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: widget.categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.categoryName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '(${_tasks.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_note, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('No tasks in this category', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return TaskCardWidget(
              task: task,
              showCategory: false, // vì đang lọc theo 1 category rồi
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(
                      task: task,
                      onTaskUpdated: _loadTasks,
                    ),
                  ),
                );
              }, category: null,
            );
          },
        ),
      ),
    );
  }
}

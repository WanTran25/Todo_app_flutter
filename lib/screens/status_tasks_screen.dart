import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_card_widget.dart';
import 'task_detail_screen.dart';

class StatusTasksScreen extends StatefulWidget {
  final TaskStatus status;
  final String title;
  final Color color;

  const StatusTasksScreen({
    super.key,
    required this.status,
    required this.title,
    required this.color,
  });

  @override
  State<StatusTasksScreen> createState() => _StatusTasksScreenState();
}

class _StatusTasksScreenState extends State<StatusTasksScreen> {
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

    // ✅ Đã sửa: Sử dụng getRecentTasks hoặc hàm tương đương để lấy dữ liệu
    // Nếu DatabaseHelper của bạn có hàm getAllTasks() thì thay bằng hàm đó nhé
    final allTasks = await _dbHelper.getRecentTasks(limit: 100);
    final filteredTasks =
        allTasks.where((t) => t.status == widget.status).toList();

    filteredTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _tasks = filteredTasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.title} (${_tasks.length})'),
        backgroundColor: Colors.white,
        foregroundColor: widget.color,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // ✅ Đã sửa lỗi "Main sniper"
                    children: [
                      Icon(Icons.assignment_turned_in_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No tasks in ${widget.title}',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCardWidget(
                          task: task,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(
                                  task: task,
                                  onTaskUpdated: _loadTasks,
                                ),
                              ),
                            );
                            _loadTasks();
                          },
                          category: null,
                          showCategory: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

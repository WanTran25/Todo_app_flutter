import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/task_card_widget.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<TaskStatus, int> _taskStats = {};
  Map<String, int> _categoryStats = {}; // ✅ categoryId -> count
  Map<String, Category> _categoryMap = {}; // ✅ categoryId -> Category
  List<Task> _recentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final futures = await Future.wait([
      _dbHelper.getTaskStats(),
      _dbHelper.getCategoryStats(),
      _dbHelper.getRecentTasks(limit: 5),
      _dbHelper.getCategoryMap(),
    ]);

    _taskStats = futures[0] as Map<TaskStatus, int>;
    _categoryStats = futures[1] as Map<String, int>;
    _recentTasks = futures[2] as List<Task>;
    _categoryMap = futures[3] as Map<String, Category>;

    setState(() => _isLoading = false);
  }

  int _getTotalTasks() => _taskStats.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildMyTasksSection(),
              const SizedBox(height: 30),
              _buildPieChartSection(),
              const SizedBox(height: 30),
              _buildCategorySection(),
              const SizedBox(height: 30),
              _buildRecentTasksSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask').then((_) => _loadDashboardData());
        },
        child: const Icon(Icons.add, size: 28),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Task Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('App Developer', style: TextStyle(fontSize: 16, color: Colors.grey[600]!)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    '${_getTotalTasks()} Total Tasks',
                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: const Text('TM', style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Tasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'To Do',
              count: _taskStats[TaskStatus.todo] ?? 0,
              color: Colors.orange,
              icon: Icons.access_time,
              subtitle: 'tasks now. 1 started',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'In Progress',
              count: _taskStats[TaskStatus.inProgress] ?? 0,
              color: Colors.blue,
              icon: Icons.autorenew,
              subtitle: 'tasks now. 1 started',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Done',
              count: _taskStats[TaskStatus.done] ?? 0,
              color: Colors.green,
              icon: Icons.check_circle,
              subtitle: 'tasks now. 13 started',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                    child: Text('+$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]!)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500]!)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    final totalTasks = _getTotalTasks();
    final doneTasks = _taskStats[TaskStatus.done] ?? 0;
    final percentage = totalTasks > 0 ? doneTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Task Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: PieChartWidget(stats: _taskStats)),
          const SizedBox(height: 20),
          _buildProgressBar(
            title: 'Completion Rate',
            value: doneTasks,
            total: totalTasks,
            percentage: percentage,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String title,
    required int value,
    required int total,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]!)),
            Text('${(percentage * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text('$value of $total tasks completed', style: TextStyle(fontSize: 12, color: Colors.grey[500]!)),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categories = _categoryMap.values.toList()
      ..sort((a, b) {
        if (a.id == DatabaseHelper.uncategorizedId) return -1;
        if (b.id == DatabaseHelper.uncategorizedId) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tasks by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/categories');
                _loadDashboardData();
              },
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((c) {
            final count = _categoryStats[c.id] ?? 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.color.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          c.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]!),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('$count tasks', style: TextStyle(fontSize: 12, color: Colors.grey[500]!)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/calendar'),
              child: const Text('View All', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_recentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.grey[50]!, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.event_note, size: 48, color: Colors.grey[400]!),
                const SizedBox(height: 12),
                Text('No tasks yet', style: TextStyle(color: Colors.grey[500]!, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Create your first task to get started', style: TextStyle(color: Colors.grey[400]!, fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/addTask'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Create Task'),
                ),
              ],
            ),
          )
        else
          Column(
            children: _recentTasks.map((task) {
              final cat = _categoryMap[task.categoryId];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCardWidget(
                  task: task,
                  category: cat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(
                          task: task,
                          onTaskUpdated: _loadDashboardData,
                        ),
                      ),
                    );
                  },
                  onStatusChanged: () async {
                    final newStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;

                    // ✅ giữ createdAt + categoryId
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      startTime: task.startTime,
                      endTime: task.endTime,
                      status: newStatus,
                      categoryId: task.categoryId,
                      notes: task.notes,
                      createdAt: task.createdAt,
                    );

                    await _dbHelper.updateTask(updatedTask);
                    _loadDashboardData();
                  },
                  showCategory: true,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600]!,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'Categories'),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/calendar');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/categories');
              _loadDashboardData();
            }
          },
        ),
      ),
    );
  }
}

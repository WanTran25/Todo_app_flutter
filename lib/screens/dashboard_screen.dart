import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
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
  Map<TaskCategory, int> _categoryStats = {};
  List<Task> _recentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Load all data in parallel
    final futures = await Future.wait([
      _dbHelper.getTaskStats(),
      _dbHelper.getCategoryStats(),
      _dbHelper.getRecentTasks(limit: 5),
    ]);
    
    _taskStats = futures[0] as Map<TaskStatus, int>;
    _categoryStats = futures[1] as Map<TaskCategory, int>;
    _recentTasks = futures[2] as List<Task>;
    
    setState(() => _isLoading = false);
  }

  int _getTotalTasks() {
    return _taskStats.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    SizedBox(height: 30),

                    // My Tasks Section
                    _buildMyTasksSection(),
                    SizedBox(height: 30),

                    // Pie Chart Section
                    _buildPieChartSection(),
                    SizedBox(height: 30),

                    // Category Stats Section
                    _buildCategorySection(),
                    SizedBox(height: 30),

                    // Recent Tasks Section
                    _buildRecentTasksSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask').then((_) {
            _loadDashboardData(); // Refresh when returning from add task
          });
        },
        child: Icon(Icons.add, size: 28),
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
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'App Developer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600]!,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, size: 14, color: Colors.blue),
                  SizedBox(width: 6),
                  Text(
                    '${_getTotalTasks()} Total Tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Text(
            'TM',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'To Do',
              count: _taskStats[TaskStatus.todo] ?? 0,
              color: Colors.orange,
              icon: Icons.access_time,
              subtitle: 'tasks now. 1 started',
            ),
            SizedBox(width: 12),
            _buildStatCard(
              title: 'In Progress',
              count: _taskStats[TaskStatus.inProgress] ?? 0,
              color: Colors.blue,
              icon: Icons.autorenew,
              subtitle: 'tasks now. 1 started',
            ),
            SizedBox(width: 12),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                Spacer(),
                if (count > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${count}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700]!,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500]!,
              ),
            ),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem(Colors.orange, 'To Do'),
                  SizedBox(width: 12),
                  _buildLegendItem(Colors.blue, 'In Progress'),
                  SizedBox(width: 12),
                  _buildLegendItem(Colors.green, 'Done'),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: PieChartWidget(stats: _taskStats),
          ),
          SizedBox(height: 20),
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

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700]!,
          ),
        ),
      ],
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
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700]!,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        SizedBox(height: 4),
        Text(
          '$value of $total tasks completed',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500]!,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: TaskCategory.values.map((category) {
            final count = _categoryStats[category] ?? 0;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: category.color.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700]!,
                        ),
                      ),
                      Text(
                        '$count tasks',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500]!,
                        ),
                      ),
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
            Text(
              'Recent Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calendar');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (_recentTasks.isEmpty)
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[50]!,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_note,
                  size: 48,
                  color: Colors.grey[400]!,
                ),
                SizedBox(height: 12),
                Text(
                  'No tasks yet',
                  style: TextStyle(
                    color: Colors.grey[500]!,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first task to get started',
                  style: TextStyle(
                    color: Colors.grey[400]!,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addTask');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Create Task'),
                ),
              ],
            ),
          )
        else
          Column(
            children: _recentTasks.map((task) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: TaskCardWidget(
                  task: task,
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
                    // Toggle task status
                    final newStatus = task.status == TaskStatus.done
                        ? TaskStatus.todo
                        : TaskStatus.done;
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      startTime: task.startTime,
                      endTime: task.endTime,
                      status: newStatus,
                      category: task.category,
                      notes: task.notes,
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600]!,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task_rounded),
              label: 'Add Task',
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/calendar');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/addTask');
            }
          },
        ),
      ),
    );
  }
}
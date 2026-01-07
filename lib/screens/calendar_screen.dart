import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../widgets/task_card_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime _selectedDate = DateTime.now();
  List<Task> _dailyTasks = [];
  Map<String, Category> _categoryMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
  }

  Future<void> _loadDailyTasks() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _dbHelper.getTasksByDate(_selectedDate),
      _dbHelper.getCategoryMap(),
    ]);

    _dailyTasks = results[0] as List<Task>;
    _categoryMap = results[1] as Map<String, Category>;

    _dailyTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productive Day', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(DateFormat('MMMM, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),

            // Calendar mock (giữ nguyên)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mon'), Text('Tue'), Text('Wed'), Text('Thu'), Text('Fri'), Text('Sat'),Text('Sun'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final day = 5 + index;
                      final isToday = day == _selectedDate.day;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                          });
                          _loadDailyTasks();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyTasks.isEmpty
                ? const Center(
              child: Column(
                children: [
                  Icon(Icons.event_note, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No tasks for today', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasks for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._dailyTasks.map(_buildTaskCard),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addTask'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final cat = _categoryMap[task.categoryId];

    return TaskCardWidget(
      task: task,
      category: cat,
      onTap: () {
        Navigator.pushNamed(
          context,
          '/taskDetail',
          arguments: task,
        ).then((_) => _loadDailyTasks());
      },
      showCategory: true,
    );
  }
}

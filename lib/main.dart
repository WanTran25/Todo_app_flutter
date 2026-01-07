import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/manage_categories_screen.dart';
import 'models/task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/addTask': (context) => AddTaskScreen(),
        '/categories': (context) => const ManageCategoriesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/taskDetail') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

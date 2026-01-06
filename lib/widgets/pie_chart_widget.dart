import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';

class PieChartWidget extends StatelessWidget {
  final Map<TaskStatus, int> stats;

  PieChartWidget({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.values.fold(0, (sum, count) => sum + count);
    final data = [
      _PieData(TaskStatus.todo, stats[TaskStatus.todo] ?? 0, Colors.orange),
      _PieData(TaskStatus.inProgress, stats[TaskStatus.inProgress] ?? 0, Colors.blue),
      _PieData(TaskStatus.done, stats[TaskStatus.done] ?? 0, Colors.green),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: data.map((item) {
                return PieChartSectionData(
                  color: item.color,
                  value: item.count.toDouble(),
                  title: total > 0 ? '${((item.count / total) * 100).round()}%' : '0%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.map((item) {
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  item.status.toString().split('.').last,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieData {
  final TaskStatus status;
  final int count;
  final Color color;

  _PieData(this.status, this.count, this.color);
}
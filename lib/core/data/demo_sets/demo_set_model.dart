import 'package:flutter/material.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';

class DemoSet {
  final String id;
  final String name;
  final String icon;
  final String desc;
  final Color color;
  final List<TaskModel> tasks;
  final List<NoteModel> notes;
  final List<Map<String, dynamic>> projectStats;
  final List<Map<String, dynamic>> hourlyData;

  const DemoSet({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
    required this.color,
    required this.tasks,
    this.notes = const [],
    this.projectStats = const [],
    this.hourlyData = const [],
  });
}

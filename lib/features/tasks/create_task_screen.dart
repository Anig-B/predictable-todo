import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import 'package:uuid/uuid.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  RecurrenceType _recurrenceType = RecurrenceType.daily;
  TaskCategory _category = TaskCategory.other;
  TaskPriority _priority = TaskPriority.medium;
  List<int> _selectedDays = []; // 1-7
  int? _dayOfMonth;

  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recurring Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Info'),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  filled: true,
                  fillColor: AppTheme.secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: AppTheme.secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle('Category'),
              Wrap(
                spacing: 10,
                children: TaskCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text(cat.name.toUpperCase()),
                    selected: _category == cat,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat);
                    },
                    selectedColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle('Recurrence'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildRecurrenceOption(RecurrenceType.daily, 'Daily'),
                        _buildRecurrenceOption(RecurrenceType.weekly, 'Weekly'),
                        _buildRecurrenceOption(
                          RecurrenceType.monthly,
                          'Monthly',
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.greyColor),
                    if (_recurrenceType == RecurrenceType.weekly)
                      _buildWeeklySelection(),
                    if (_recurrenceType == RecurrenceType.monthly)
                      _buildMonthlySelection(),
                    if (_recurrenceType == RecurrenceType.daily)
                      const Text(
                        'Occurs every day',
                        style: TextStyle(color: AppTheme.greyColor),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle('Priority'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: TaskPriority.values.map((p) {
                  Color c = p == TaskPriority.high
                      ? Colors.red
                      : (p == TaskPriority.medium
                            ? Colors.orange
                            : Colors.green);
                  return FilterChip(
                    label: Text(p.name.toUpperCase()),
                    selected: _priority == p,
                    onSelected: (v) => setState(() => _priority = p),
                    selectedColor: c.withOpacity(0.3),
                    checkmarkColor: c,
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Create Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildRecurrenceOption(RecurrenceType type, String label) {
    bool isSelected = _recurrenceType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _recurrenceType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.greyColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySelection() {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        int day = index + 1;
        bool isSelected = _selectedDays.contains(day);
        return FilterChip(
          label: Text(_weekDays[index]),
          selected: isSelected,
          onSelected: (v) {
            setState(() {
              if (v) {
                _selectedDays.add(day);
              } else {
                _selectedDays.remove(day);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildMonthlySelection() {
    return Row(
      children: [
        const Text('On day: '),
        const SizedBox(width: 10),
        DropdownButton<int>(
          value: _dayOfMonth ?? 1,
          dropdownColor: AppTheme.secondaryColor,
          items: List.generate(31, (index) => index + 1)
              .map((d) => DropdownMenuItem(value: d, child: Text(d.toString())))
              .toList(),
          onChanged: (v) => setState(() => _dayOfMonth = v),
        ),
      ],
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = context.read<UserModel?>();
      if (userProfile == null || userProfile.currentTeamId == null) return;

      final task = TaskDefinitionModel(
        id: const Uuid().v4(),
        teamId: userProfile.currentTeamId!,
        creatorId: userProfile.uid,
        assigneeIds: [userProfile.uid],
        title: _titleController.text,
        description: _descriptionController.text,
        recurrenceType: _recurrenceType,
        daysOfWeek: _selectedDays,
        dayOfMonth: _dayOfMonth,
        category: _category,
        priority: _priority,
        subTasks: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      try {
        await context.read<FirebaseService>().createTask(task);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
        }
      }
    }
  }
}

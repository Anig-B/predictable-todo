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
  List<int> _selectedDays = [];
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
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Design New Task'), centerTitle: true),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('CORE DETAILS'),
                _buildInputContainer(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Task Title',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppTheme.greyColor),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Title is required' : null,
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'What needs to be done?',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppTheme.greyColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('CATEGORY'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TaskCategory.values.map((cat) {
                      final isSelected = _category == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _category = cat);
                          },
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('FREQUENCY'),
                _buildInputContainer(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildRecurrenceTab(RecurrenceType.daily, 'Daily'),
                          _buildRecurrenceTab(RecurrenceType.weekly, 'Weekly'),
                          _buildRecurrenceTab(
                            RecurrenceType.monthly,
                            'Monthly',
                          ),
                        ],
                      ),
                      if (_recurrenceType != RecurrenceType.daily) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Colors.white24),
                        const SizedBox(height: 16),
                        if (_recurrenceType == RecurrenceType.weekly)
                          _buildWeeklySelection(),
                        if (_recurrenceType == RecurrenceType.monthly)
                          _buildMonthlySelection(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('PRIORITY'),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = _priority == p;
                    Color color = p == TaskPriority.high
                        ? Colors.red
                        : (p == TaskPriority.medium
                              ? Colors.orange
                              : Colors.green);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: p != TaskPriority.values.last ? 8.0 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                p.name.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _saveTask,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Create Recurring Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: child,
    );
  }

  Widget _buildRecurrenceTab(RecurrenceType type, String label) {
    bool isSelected = _recurrenceType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _recurrenceType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.greyColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySelection() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (index) {
        int day = index + 1;
        bool isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? _selectedDays.remove(day) : _selectedDays.add(day);
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            child: Center(
              child: Text(
                _weekDays[index][0],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthlySelection() {
    return Row(
      children: [
        const Text(
          'Repeat on day: ',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<int>(
            value: _dayOfMonth ?? 1,
            underline: const SizedBox(),
            items: List.generate(31, (index) => index + 1)
                .map(
                  (d) => DropdownMenuItem(value: d, child: Text(d.toString())),
                )
                .toList(),
            onChanged: (v) => setState(() => _dayOfMonth = v),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving task: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}

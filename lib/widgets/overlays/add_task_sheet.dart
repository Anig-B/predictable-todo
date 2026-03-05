import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskCategory _category = TaskCategory.work;
  TaskPriority _priority = TaskPriority.medium;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final points = _priority == TaskPriority.high
        ? 80
        : _priority == TaskPriority.medium
            ? 50
            : 25;
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      desc: _descCtrl.text.trim(),
      time: _time.format(context),
      points: points,
      project: _category.label,
      streak: 0,
      done: false,
      priority: _priority,
      category: _category,
    );
    ref.read(taskProvider.notifier).addTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('New Quest', style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Title
              _Label('TITLE'),
              TextField(
                controller: _titleCtrl,
                style: AppTheme.sans(size: 13),
                decoration: const InputDecoration(hintText: 'What needs to be done?'),
              ),
              const SizedBox(height: 12),

              // Description
              _Label('DESCRIPTION', optional: true),
              TextField(
                controller: _descCtrl,
                style: AppTheme.sans(size: 13),
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Add details…'),
              ),
              const SizedBox(height: 12),

              // Category
              _Label('CATEGORY'),
              _PillGroup<TaskCategory>(
                values: TaskCategory.values,
                selected: _category,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 12),

              // Priority
              _Label('PRIORITY'),
              _PillGroup<TaskPriority>(
                values: TaskPriority.values,
                selected: _priority,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 12),

              // Time
              _Label('TIME'),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: AppTheme.surfaceBox(),
                  child: Text(_time.format(context),
                      style: AppTheme.sans(size: 13)),
                ),
              ),
              const SizedBox(height: 16),

              // Submit
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('Add Quest',
                      style: AppTheme.sans(
                          size: 13, weight: FontWeight.w800, color: AppColors.bg)),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Cancel',
                      style: AppTheme.sans(size: 11, color: AppColors.subtle,
                          weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool optional;
  const _Label(this.text, {this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(text,
              style: AppTheme.mono(
                  size: 9, color: AppColors.subtle, weight: FontWeight.w700)),
          if (optional) ...[
            const SizedBox(width: 4),
            Text('optional',
                style: AppTheme.sans(size: 9, color: AppColors.subtle)),
          ],
        ],
      ),
    );
  }
}

class _PillGroup<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  const _PillGroup({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5, runSpacing: 5,
      children: values.map((v) {
        final active = v == selected;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: active ? AppColors.accent : AppColors.border,
              ),
            ),
            child: Text(label(v),
                style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w600,
                    color: active ? AppColors.accent : AppColors.muted)),
          ),
        );
      }).toList(),
    );
  }
}

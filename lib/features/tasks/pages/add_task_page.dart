import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/seed_data.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key});

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskCategory _category = TaskCategory.work;
  TaskPriority _priority = TaskPriority.medium;
  TaskRecurring _recurring = TaskRecurring.none;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _showDemoPicker = false;
  int _weeklyDay = DateTime.now().weekday; // 1=Mon…7=Sun
  int _monthlyDay = 1; // 1-28 or 0=last

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _importDemo(DemoSet demo) {
    final base = DateTime.now().millisecondsSinceEpoch;

    // Import Tasks
    final tasks = demo.tasks.asMap().entries.map((e) {
      return e.value.copyWith(
          id: base + e.key,
          streak: 0,
          done: false,
          bonusEarned: 0,
          clearLastCompleted: true);
    }).toList();

    // Import Notes with unique IDs
    final notes = demo.notes.asMap().entries.map((e) {
      return e.value.copyWith(
        id: 'demo-${base + e.key}',
        createdAt: DateTime.now().subtract(Duration(minutes: e.key * 5)),
      );
    }).toList();

    ref.read(taskProvider.notifier).loadDemo(
          tasks,
          projectStats: demo.projectStats,
          hourlyData: demo.hourlyData,
        );
    ref.read(noteProvider.notifier).loadDemo(notes);

    Navigator.of(context).pop();
  }

  static const _weekDayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  String _recurringHint() {
    switch (_recurring) {
      case TaskRecurring.daily:
        return 'Auto-resets every day';
      case TaskRecurring.weekly:
        return 'Auto-resets every ${_weekDayNames[_weeklyDay - 1]}';
      case TaskRecurring.monthly:
        final label =
            _monthlyDay == 0 ? 'the last day' : 'the ${_ordinal(_monthlyDay)}';
        return 'Auto-resets on $label of each month';
      case TaskRecurring.none:
        return '';
    }
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
      recurring: _recurring,
      weeklyDay: _recurring == TaskRecurring.weekly ? _weeklyDay : null,
      monthlyDay: _recurring == TaskRecurring.monthly ? _monthlyDay : null,
    );
    ref.read(taskProvider.notifier).addTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('NEW QUEST',
            style: AppTheme.mono(size: 14, weight: FontWeight.w700)
                .copyWith(letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded,
                size: 20,
                color: _showDemoPicker ? AppColors.purple : AppColors.muted),
            onPressed: () => setState(() => _showDemoPicker = !_showDemoPicker),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showDemoPicker) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.25)),
                  color: AppColors.surface,
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: AppColors.purple.withValues(alpha: 0.08),
                      child: Text('SELECT A MISSION PACK',
                          style: AppTheme.mono(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: AppColors.purple)
                              .copyWith(letterSpacing: 1.5)),
                    ),
                    ...SeedData.demoSets.map((demo) => GestureDetector(
                          onTap: () => _importDemo(demo),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.border
                                        .withValues(alpha: 0.5)),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: demo.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            demo.color.withValues(alpha: 0.25)),
                                  ),
                                  child: Center(
                                    child: Text(demo.icon,
                                        style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(demo.name,
                                          style: AppTheme.sans(
                                              size: 14,
                                              weight: FontWeight.w800)),
                                      const SizedBox(height: 3),
                                      Text(demo.desc,
                                          style: AppTheme.sans(
                                              size: 10,
                                              color: AppColors.subtle)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: demo.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                      '${demo.tasks.length} tasks · ${demo.notes.length} scrolls',
                                      style: AppTheme.mono(
                                          size: 9,
                                          weight: FontWeight.w700,
                                          color: demo.color)),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            const _FieldLabel('TITLE'),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: AppTheme.sans(size: 15, weight: FontWeight.w600),
              decoration: AppTheme.inputDecoration(
                hint: 'What is your next mission?',
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const _FieldLabel('DESCRIPTION', optional: true),
            TextField(
              controller: _descCtrl,
              style: AppTheme.sans(size: 14),
              maxLines: 3,
              decoration: AppTheme.inputDecoration(
                hint: 'Add objectives or details...',
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('PRIORITY'),
                      _PriorityButtons(
                        selected: _priority,
                        onSelect: (v) => setState(() => _priority = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('TIME'),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: AppTheme.surfaceBox(),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 16, color: AppColors.muted),
                              const SizedBox(width: 8),
                              Text(_time.format(context),
                                  style: AppTheme.sans(
                                      size: 14, weight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category
            const _FieldLabel('CATEGORY'),
            _PillGroup<TaskCategory>(
              values: TaskCategory.values,
              selected: _category,
              label: (v) => v.label,
              onSelect: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 24),

            // Recurring
            const _FieldLabel('RECURRING'),
            _PillGroup<TaskRecurring>(
              values: TaskRecurring.values,
              selected: _recurring,
              label: (v) => v.label,
              onSelect: (v) => setState(() => _recurring = v),
            ),
            if (_recurring == TaskRecurring.weekly) ...[
              const SizedBox(height: 12),
              const _FieldLabel('ACTIVE DAYS'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ].asMap().entries.map((e) {
                  final day = e.key + 1;
                  final active = _weeklyDay == day;
                  return GestureDetector(
                    onTap: () => setState(() => _weeklyDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.purple.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? AppColors.purple : AppColors.border,
                        ),
                      ),
                      child: Text(e.value,
                          style: AppTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color:
                                  active ? AppColors.purple : AppColors.muted)),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (_recurring == TaskRecurring.monthly) ...[
              const SizedBox(height: 12),
              const _FieldLabel('DAY OF MONTH'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...List.generate(28, (i) => i + 1),
                  0,
                ].map((day) {
                  final active = _monthlyDay == day;
                  final label = day == 0 ? 'Last' : _ordinal(day);
                  return GestureDetector(
                    onTap: () => setState(() => _monthlyDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.purple.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active ? AppColors.purple : AppColors.border,
                        ),
                      ),
                      child: Text(label,
                          style: AppTheme.mono(
                              size: 10,
                              weight: FontWeight.w700,
                              color:
                                  active ? AppColors.purple : AppColors.muted)),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (_recurring != TaskRecurring.none) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: AppTheme.surfaceBox(
                  color: AppColors.purple.withValues(alpha: 0.06),
                  borderColor: AppColors.purple.withValues(alpha: 0.22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.autorenew_rounded,
                        size: 14, color: AppColors.purple),
                    const SizedBox(width: 8),
                    Text(
                      _recurringHint(),
                      style: AppTheme.sans(
                          size: 12,
                          color: AppColors.purple,
                          weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),

            // Submit
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.bg, size: 24),
                    const SizedBox(width: 8),
                    Text('CREATE QUEST',
                        style: AppTheme.sans(
                                size: 14,
                                weight: FontWeight.w900,
                                color: AppColors.bg)
                            .copyWith(letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool optional;
  const _FieldLabel(this.text, {this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Text(text,
              style: AppTheme.mono(
                  size: 10, color: AppColors.subtle, weight: FontWeight.w800)),
          if (optional) ...[
            const SizedBox(width: 6),
            Text('OPTIONAL',
                style: AppTheme.mono(size: 9, color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

class _PriorityButtons extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelect;

  const _PriorityButtons({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((v) {
        final active = selected == v;
        Color color;
        switch (v) {
          case TaskPriority.high:
            color = AppColors.red;
            break;
          case TaskPriority.medium:
            color = AppColors.orange;
            break;
          case TaskPriority.low:
            color = AppColors.accent;
            break;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: v == TaskPriority.low ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:
                    active ? color.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? color : AppColors.border,
                  width: active ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(v.label.toUpperCase(),
                  style: AppTheme.mono(
                      size: 9,
                      weight: FontWeight.w800,
                      color: active ? color : AppColors.muted)),
            ),
          ),
        );
      }).toList(),
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
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final active = v == selected;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.purple.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.purple : AppColors.border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(label(v),
                style: AppTheme.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: active ? AppColors.purple : AppColors.muted)),
          ),
        );
      }).toList(),
    );
  }
}

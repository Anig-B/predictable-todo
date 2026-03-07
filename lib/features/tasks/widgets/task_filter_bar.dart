import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

enum TaskFilter { notes, today, weekly, monthly, cleared }

class TaskFilterBar extends StatelessWidget {
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;

  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: TaskFilter.values.map((f) {
            final active = selected == f;
            final isNotes = f == TaskFilter.notes;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (isNotes) {
                    context.push('/notes');
                  } else {
                    onChanged(f);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? (isNotes
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.surface3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: isNotes
                                  ? AppColors.accent.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isNotes
                      ? Icon(Icons.history_edu_rounded,
                          size: 16,
                          color: active ? AppColors.accent : AppColors.muted)
                      : Text(
                          f.name.toUpperCase(),
                          style: AppTheme.mono(
                            size: 9,
                            weight: active ? FontWeight.w900 : FontWeight.w700,
                            color: active ? AppColors.accent : AppColors.muted,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

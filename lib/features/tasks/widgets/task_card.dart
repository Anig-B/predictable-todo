import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final int effectiveMulti;
  final VoidCallback onToggle;
  final VoidCallback onQuickToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.effectiveMulti,
    required this.onToggle,
    required this.onQuickToggle,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _checkScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.22), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _handleQuickToggle() {
    if (!widget.task.done) _checkCtrl.forward(from: 0);
    widget.onQuickToggle();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final xpLabel = widget.effectiveMulti > 1 && !t.done
        ? '⚡ ${t.points}×${widget.effectiveMulti}'
        : '⚡ ${t.points}';

    return AnimatedOpacity(
      opacity: t.done ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Priority stripe
            Positioned(
              left: 0,
              top: 6,
              bottom: 6,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: t.priority.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 11, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Check button
                      ScaleTransition(
                        scale: _checkScale,
                        child: GestureDetector(
                          onTap: _handleQuickToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient:
                                  t.done ? AppColors.primaryGradient : null,
                              border: t.done
                                  ? null
                                  : Border.all(
                                      color: AppColors.border, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: t.done
                                ? const Icon(Icons.check,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      // Title + chips
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: AppTheme.sans(
                                  size: 12,
                                  weight: FontWeight.w700,
                                  color:
                                      t.done ? AppColors.muted : AppColors.text,
                                ).copyWith(
                                  decoration: t.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _Chip(
                                      label: '🕐 ${t.time}',
                                      color: AppColors.subtle,
                                      bg: AppColors.surface2),
                                  _Chip(
                                      label: xpLabel,
                                      color: AppColors.accent,
                                      bg: AppColors.accent
                                          .withValues(alpha: 0.1),
                                      mono: true),
                                  _Chip(
                                      label: '📁 ${t.project}',
                                      color: AppColors.purple,
                                      bg: AppColors.purple
                                          .withValues(alpha: 0.1)),
                                  _Chip(
                                      label: '🔥 ${t.streak}d',
                                      color: AppColors.gold,
                                      bg: AppColors.gold
                                          .withValues(alpha: 0.1)),
                                  if (t.recurring != TaskRecurring.none)
                                    _Chip(
                                      label: '↻ ${t.recurringLabel}',
                                      color: AppColors.blue,
                                      bg: AppColors.blue.withValues(alpha: 0.1),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expand button
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: AppTheme.surfaceBox(
                              color: AppColors.surface2, radius: 7),
                          child: Icon(
                            _expanded
                                ? Icons.expand_less
                                : Icons.description_outlined,
                            size: 14,
                            color: AppColors.subtle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Expanded description
                  if (_expanded && t.desc.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: AppTheme.surfaceBox(
                          color: AppColors.surface2, radius: 8),
                      child: Text(t.desc,
                          style:
                              AppTheme.sans(size: 11, color: AppColors.muted)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final bool mono;

  const _Chip(
      {required this.label,
      required this.color,
      required this.bg,
      this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(
        label,
        style: mono
            ? AppTheme.mono(size: 9, color: color)
            : AppTheme.sans(size: 9, weight: FontWeight.w600, color: color),
      ),
    );
  }
}

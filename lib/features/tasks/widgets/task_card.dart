import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../../../shared/widgets/rainbow_glimmer.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final int effectiveMulti;
  final VoidCallback onToggle;
  final VoidCallback onQuickToggle;
  final VoidCallback? onLongPress;
  final bool selectMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  const TaskCard({
    super.key,
    required this.task,
    required this.effectiveMulti,
    required this.onToggle,
    required this.onQuickToggle,
    this.onLongPress,
    this.selectMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _showCelebration = false;
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
    if (!widget.task.done) {
      _checkCtrl.forward(from: 0);
      setState(() => _showCelebration = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showCelebration = false);
      });
    }
    widget.onQuickToggle();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    int potentialXp = t.points * widget.effectiveMulti;
    final xpLabel = t.done 
        ? '⚡ ${t.points + t.bonusEarned}' 
        : (widget.effectiveMulti > 1 ? '⚡ $potentialXp (${t.points}×${widget.effectiveMulti})' : '⚡ ${t.points}');

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Rainbow Border Celebration
          if (_showCelebration)
            Positioned.fill(
              child: RainbowGlimmer(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
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
                    // Select checkbox
                    if (widget.selectMode)
                      GestureDetector(
                        onTap: widget.onSelect,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 9, top: 1),
                          decoration: BoxDecoration(
                            color: widget.isSelected ? AppColors.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.isSelected ? AppColors.accent : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: widget.isSelected
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                      ),
                    // Check button (hidden in select mode)
                    if (!widget.selectMode)
                      AnimatedOpacity(
                        opacity: t.done ? 0.45 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: ScaleTransition(
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
                      ),
                    const SizedBox(width: 9),
                    // Title + chips
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: t.done ? 0.45 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: widget.selectMode ? widget.onSelect : widget.onToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                  // Expanded details
                  if (_expanded) ...[
                    if (t.desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: AppTheme.surfaceBox(
                            color: AppColors.surface2, radius: 8),
                        child: Text(t.desc,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sans(
                                size: 11, color: AppColors.muted)),
                      ),
                    ],
                    if (t.proofNotes != null && t.proofNotes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: AppTheme.surfaceBox(
                            color: AppColors.accent.withValues(alpha: 0.06),
                            radius: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PROOF NOTE',
                                style: AppTheme.mono(
                                    size: 8,
                                    color: AppColors.accent,
                                    weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(t.proofNotes!,
                                style: AppTheme.sans(
                                    size: 11, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                    if (t.proofImage != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          t.proofImage!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Image unavailable',
                                style: AppTheme.sans(
                                    size: 10, color: AppColors.muted)),
                          ),
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                          color: AppColors.accent)),
                        ),
                      ),
                    ],
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

  const _Chip({
    required this.label,
    required this.color,
    required this.bg,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: mono
            ? AppTheme.mono(size: 9, weight: FontWeight.w600, color: color)
            : AppTheme.sans(size: 9, weight: FontWeight.w600, color: color),
      ),
    );
  }
}

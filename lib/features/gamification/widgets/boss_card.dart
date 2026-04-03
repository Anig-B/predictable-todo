import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/boss_model.dart';

class BossCard extends StatefulWidget {
  final BossModel boss;

  const BossCard({super.key, required this.boss});

  @override
  State<BossCard> createState() => _BossCardState();
}

class _BossCardState extends State<BossCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getElementColor() {
      switch (widget.boss.color) {
        case 'fire':
          return AppColors.red;
        case 'undead':
          return AppColors.accent; // Greenish
        case 'earth':
          return AppColors.orange;
        case 'rare':
          return AppColors.gold;
        default:
          return AppColors.red;
      }
    }

    final elementColor = getElementColor();
    final hpColor = widget.boss.hpPercent > 0.5
        ? elementColor
        : widget.boss.hpPercent > 0.25
            ? AppColors.orange
            : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor.withValues(alpha: 0.04),
            elementColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: widget.boss.isDefeated
              ? AppColors.border
              : elementColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text('⚔️ WEEKLY BOSS',
                        style: AppTheme.mono(size: 9, color: AppColors.subtle)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: elementColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(widget.boss.color?.toUpperCase() ?? 'NONE',
                          style: AppTheme.mono(size: 7, color: elementColor, weight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: elementColor.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('+${widget.boss.reward} XP',
                    style: AppTheme.mono(size: 9, color: elementColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Boss emoji with floating animation
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, widget.boss.isDefeated ? 0 : _animation.value),
                  child: child,
                );
              },
              child: TweenAnimationBuilder<double>(
                tween:
                    Tween(begin: 0.0, end: widget.boss.isDefeated ? 0.4 : 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (_, opacity, child) => Opacity(
                  opacity: opacity,
                  child: ColorFiltered(
                    colorFilter: widget.boss.isDefeated
                        ? AppColors.grayscaleFilter
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.color),
                    child: child,
                  ),
                ),
                child: Text(widget.boss.emoji,
                    style: const TextStyle(fontSize: 44)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.boss.name,
              style: AppTheme.mono(size: 12, weight: FontWeight.w800)),
          if (widget.boss.isDefeated)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('🎉 DEFEATED!',
                  style: AppTheme.sans(
                      size: 12,
                      weight: FontWeight.w800,
                      color: AppColors.accent)),
            ),
          const SizedBox(height: 10),
          // HP row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HP',
                  style: AppTheme.mono(size: 9, color: AppColors.subtle)),
              Text('${widget.boss.hp.clamp(0, 999999)}/${widget.boss.maxHp}',
                  style: AppTheme.mono(size: 9, color: hpColor)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.boss.hpPercent,
              minHeight: 8,
              backgroundColor: AppColors.surface3,
              valueColor: AlwaysStoppedAnimation<Color>(hpColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.boss.tasksDone}/${widget.boss.tasksNeeded} tasks · ${widget.boss.damagePerTask} DMG each',
            style: AppTheme.sans(size: 9, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/boss_model.dart';

class BossCard extends StatelessWidget {
  final BossModel boss;

  const BossCard({super.key, required this.boss});

  @override
  Widget build(BuildContext context) {
    final hpColor = boss.hpPercent > 0.5
        ? AppColors.red
        : boss.hpPercent > 0.25
            ? AppColors.orange
            : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.red.withValues(alpha: 0.04),
            AppColors.orange.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: boss.isDefeated
              ? AppColors.border
              : AppColors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text('⚔️ WEEKLY BOSS',
                    style: AppTheme.mono(size: 9, color: AppColors.subtle),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.red),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('+${boss.reward} XP',
                    style: AppTheme.mono(size: 9, color: AppColors.red)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Boss emoji
          RepaintBoundary(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: boss.isDefeated ? 0.4 : 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (_, opacity, __) => Opacity(
                opacity: opacity,
                child: ColorFiltered(
                  colorFilter: boss.isDefeated
                      ? AppColors.grayscaleFilter
                      : const ColorFilter.mode(
                          Colors.transparent, BlendMode.color),
                  child: Text(boss.emoji, style: const TextStyle(fontSize: 44)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(boss.name,
              style: AppTheme.mono(size: 12, weight: FontWeight.w800)),
          if (boss.isDefeated)
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
              Text('${boss.hp.clamp(0, 999999)}/${boss.maxHp}',
                  style: AppTheme.mono(size: 9, color: hpColor)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: boss.hpPercent,
              minHeight: 8,
              backgroundColor: AppColors.surface3,
              valueColor: AlwaysStoppedAnimation<Color>(hpColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${boss.tasksDone}/${boss.tasksNeeded} tasks · ${boss.damagePerTask} DMG each',
            style: AppTheme.sans(size: 9, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}

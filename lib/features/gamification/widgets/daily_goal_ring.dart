import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DailyGoalRing extends StatelessWidget {
  final int done;
  final int goal;
  const DailyGoalRing({super.key, required this.done, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (done / goal).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32, height: 32,
              child: CustomPaint(
                painter: _RingPainter(progress: progress),
                child: Center(
                  child: Text('$done/$goal',
                      style: AppTheme.mono(size: 7, color: AppColors.accent)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Goal',
                    style: AppTheme.sans(size: 10, weight: FontWeight.w800)),
                Text(done >= goal ? 'Done! 🎉' : '${goal - done} left',
                    style: AppTheme.sans(
                        size: 8,
                        color: AppColors.subtle,
                        weight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - 3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    paint.color = AppColors.surface3;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    paint.color = AppColors.accent;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class StreakCard extends StatelessWidget {
  final int streak;
  final int shields;
  const StreakCard({super.key, required this.streak, required this.shields});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak Days',
                    style: AppTheme.sans(
                        size: 10,
                        weight: FontWeight.w800,
                        color: AppColors.gold)),
                Text(
                    shields > 0
                        ? '🛡️ $shields shield${shields > 1 ? 's' : ''}'
                        : 'Streak',
                    style: AppTheme.sans(
                        size: 8,
                        color: AppColors.subtle,
                        weight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

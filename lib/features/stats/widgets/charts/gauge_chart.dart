import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class GaugeChart extends StatelessWidget {
  final double value;
  final double max;
  final String label;
  final Color color;

  const GaugeChart({
    super.key,
    required this.value,
    required this.max,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76, height: 76,
          child: CustomPaint(
            painter: _GaugePainter(pct: pct, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(pct * 100).round()}%',
                      style: AppTheme.mono(
                          size: 13, weight: FontWeight.w800, color: AppColors.text)),
                  Text(label,
                      style: AppTheme.mono(size: 7, color: AppColors.subtle)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  final Color color;
  const _GaugePainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 32.0;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(cx, cy), r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * pct,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.pct != pct;
}

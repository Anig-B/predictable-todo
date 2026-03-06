import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // {name, value, color}
  final double size;

  const DonutChart({super.key, required this.data, this.size = 126});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (s, d) => s + (d['value'] as int));

    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _DonutPainter(data: data, total: total),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total',
                  style: AppTheme.mono(
                      size: 18, weight: FontWeight.w800, color: AppColors.text)),
              Text('TASKS',
                  style: AppTheme.mono(size: 8, color: AppColors.subtle)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int total;

  const _DonutPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - 10;
    double startAngle = -pi / 2;

    for (final seg in data) {
      final sweep = 2 * pi * (seg['value'] as int) / total;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = seg['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle + 0.05,
        sweep - 0.1,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.data != data;
}

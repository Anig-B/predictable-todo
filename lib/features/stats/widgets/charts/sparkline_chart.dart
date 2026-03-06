import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SparklineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // {day, xp}
  final Color color;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    this.color = AppColors.accent,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxXp = data.map((d) => d['xp'] as int).reduce((a, b) => a > b ? a : b);
    final w = size.width;
    final h = size.height;

    final points = List.generate(data.length, (i) {
      final x = (i / (data.length - 1)) * w;
      final y = h - (data[i]['xp'] as int) / maxXp * (h - 10) - 5;
      return Offset(x, y);
    });

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final fillPath = Path()..moveTo(0, h);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(w, h);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) linePath.lineTo(points[i].dx, points[i].dy);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}

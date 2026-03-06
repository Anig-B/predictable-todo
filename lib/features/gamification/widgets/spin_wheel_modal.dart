import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/seed_data.dart';

class SpinWheelModal extends StatefulWidget {
  final void Function(Map<String, dynamic> seg) onResult;
  const SpinWheelModal({super.key, required this.onResult});

  @override
  State<SpinWheelModal> createState() => _SpinWheelModalState();
}

class _SpinWheelModalState extends State<SpinWheelModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _rotation;
  bool _spinning = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500));
    _rotation = Tween(begin: 0.0, end: 0.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _result = null;
    });

    final segs = SeedData.wheelSegments;
    final winIdx = Random().nextInt(segs.length);
    final segAngle = 2 * pi / segs.length;
    final currentAngle = _rotation.value;
    final targetAngle =
        currentAngle + 2 * pi * 5 + (2 * pi - winIdx * segAngle - segAngle / 2);

    _rotation = Tween(begin: currentAngle, end: targetAngle).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Cubic(0.17, 0.67, 0.12, 0.99)),
    );
    _ctrl.forward(from: 0).then((_) {
      setState(() {
        _spinning = false;
        _result = segs[winIdx];
      });
      widget.onResult(segs[winIdx]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.sheetBox,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTheme.handleBar,
          const SizedBox(height: 16),
          Text('🎰 Daily Spin',
              style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 18),
          // Pointer
          const Text('▼',
              style: TextStyle(fontSize: 18, color: AppColors.gold)),
          // Wheel
          AnimatedBuilder(
            animation: _rotation,
            builder: (_, __) => Transform.rotate(
              angle: _rotation.value,
              child: SizedBox(
                width: 220, height: 220,
                child: CustomPaint(
                  painter: _WheelPainter(segs: SeedData.wheelSegments),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Result
          if (_result != null)
            AnimatedOpacity(
              opacity: _result != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (_result!['color'] as Color)
                          .withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                        _result!['type'] == 'shield'
                            ? '🛡️'
                            : _result!['type'] == 'multi'
                                ? '✨'
                                : '⚡',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(_result!['label'] as String,
                        style: AppTheme.mono(
                            size: 16,
                            weight: FontWeight.w800,
                            color: _result!['color'] as Color)),
                    const SizedBox(height: 3),
                    Text(
                        _result!['type'] == 'shield'
                            ? 'Streak Shield — protects one missed day'
                            : _result!['type'] == 'multi'
                                ? '${_result!['value']}× multiplier on your next task!'
                                : 'Bonus XP added!',
                        style:
                            AppTheme.sans(size: 10, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          // Button
          GestureDetector(
            onTap: _spinning
                ? null
                : (_result != null
                    ? () => Navigator.of(context).pop()
                    : _spin),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: _spinning ? null : AppColors.primaryGradient,
                color: _spinning ? AppColors.surface2 : null,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _spinning
                    ? 'Spinning…'
                    : _result != null
                        ? 'Collect & Close'
                        : '🎰 SPIN!',
                style: AppTheme.sans(
                    size: 13,
                    weight: FontWeight.w800,
                    color: _spinning ? AppColors.muted : AppColors.bg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segs;
  const _WheelPainter({required this.segs});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 100.0;
    final segAngle = 2 * pi / segs.length;

    for (int i = 0; i < segs.length; i++) {
      final startA = i * segAngle - pi / 2;

      final paint = Paint()
        ..color = (segs[i]['color'] as Color).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + r * cos(startA), cy + r * sin(startA))
        ..arcTo(
            Rect.fromCircle(center: Offset(cx, cy), radius: r),
            startA, segAngle, false)
        ..close();

      canvas.drawPath(path, paint);

      // Separator
      final sep = Paint()
        ..color = AppColors.bg
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, cy),
          Offset(cx + r * cos(startA), cy + r * sin(startA)), sep);

      // Label
      final midA = startA + segAngle / 2;
      final tx = cx + 65 * cos(midA);
      final ty = cy + 65 * sin(midA);

      final tp = TextPainter(
        text: TextSpan(
          text: segs[i]['label'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(tx, ty);
      canvas.rotate(midA + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(Offset(cx, cy), 20,
        Paint()..color = AppColors.bg);
    canvas.drawCircle(Offset(cx, cy), 20,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => false;
}

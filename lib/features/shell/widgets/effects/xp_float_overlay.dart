import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../gamification/providers/effects_provider.dart';

class XpFloatOverlay extends StatelessWidget {
  final List<XpFloat> floats;
  const XpFloatOverlay({super.key, required this.floats});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: floats.map((f) => _XpFloatItem(float: f)).toList(),
    );
  }
}

class _XpFloatItem extends StatefulWidget {
  final XpFloat float;
  const _XpFloatItem({required this.float});

  @override
  State<_XpFloatItem> createState() => _XpFloatItemState();
}

class _XpFloatItemState extends State<_XpFloatItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _rise;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);

    _rise = Tween(begin: 0.0, end: -80.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.35), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 80),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMulti = widget.float.multiplier > 1;
    final color = isMulti ? AppColors.red : AppColors.accent;
    final label = isMulti
        ? '+${widget.float.value} ×${widget.float.multiplier}'
        : '+${widget.float.value}';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.float.x,
        top: widget.float.y + _rise.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Text(
              label,
              style: AppTheme.mono(size: 20, weight: FontWeight.w800, color: color).copyWith(
                shadows: [Shadow(color: color, blurRadius: 12)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

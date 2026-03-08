import 'package:flutter/material.dart';

/// A widget that applies a sweeping rainbow glimmer effect to its child.
/// Useful for making specific icons or text feel "magical".
class RainbowGlimmer extends StatefulWidget {
  final Widget child;
  final bool active;
  final Duration duration;

  const RainbowGlimmer({
    super.key,
    required this.child,
    this.active = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<RainbowGlimmer> createState() => _RainbowGlimmerState();
}

class _RainbowGlimmerState extends State<RainbowGlimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(RainbowGlimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + (4.0 * _controller.value), 0.0),
              end: Alignment(-1.0 + (4.0 * _controller.value), 0.0),
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

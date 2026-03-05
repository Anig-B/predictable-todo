import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';

class ConfettiBurst extends StatefulWidget {
  final bool trigger;
  const ConfettiBurst({super.key, required this.trigger});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  late final ConfettiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ConfettiController(duration: const Duration(milliseconds: 800));
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _ctrl.play();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _ctrl,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 28,
        colors: AppColors.confettiColors,
        gravity: 0.3,
        emissionFrequency: 0.6,
        shouldLoop: false,
      ),
    );
  }
}

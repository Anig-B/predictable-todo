import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';

class PetWidget extends StatelessWidget {
  final int totalLifetimeTasks;
  const PetWidget({super.key, required this.totalLifetimeTasks});

  @override
  Widget build(BuildContext context) {
    final pet = XpCalculator.currentPet(totalLifetimeTasks);
    final next = XpCalculator.nextPet(totalLifetimeTasks);
    final progress = XpCalculator.petProgress(totalLifetimeTasks);
    final nextLabel = (next != null && next.minTasks > pet.minTasks)
        ? '— ${next.minTasks - totalLifetimeTasks} to ${next.emoji}'
        : '— Max!';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: AppTheme.surfaceBox(),
      child: Row(
        children: [
          _BobblingPet(emoji: pet.emoji, size: pet.size),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pet.name,
                        style:
                            AppTheme.sans(size: 10, weight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(nextLabel,
                          style:
                              AppTheme.sans(size: 8, color: AppColors.subtle),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: AppColors.surface3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BobblingPet extends StatefulWidget {
  final String emoji;
  final double size;
  const _BobblingPet({required this.emoji, required this.size});

  @override
  State<_BobblingPet> createState() => _BobblingPetState();
}

class _BobblingPetState extends State<_BobblingPet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bobble;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bobble = Tween(begin: 0.0, end: -4.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _bobble,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _bobble.value),
          child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
        ),
      ),
    );
  }
}

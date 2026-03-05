import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/seed_data.dart';
import '../../models/loot_item_model.dart';

class LootBoxModal extends StatefulWidget {
  final void Function(LootItemModel item) onCollect;
  const LootBoxModal({super.key, required this.onCollect});

  @override
  State<LootBoxModal> createState() => _LootBoxModalState();
}

class _LootBoxModalState extends State<LootBoxModal>
    with SingleTickerProviderStateMixin {
  LootItemModel? _loot;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.18), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open() {
    final item = SeedData.lootPool[Random().nextInt(SeedData.lootPool.length)];
    setState(() => _loot = item);
    _ctrl.forward(from: 0);
    widget.onCollect(item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loot == null
                ? _ClosedChest(key: const ValueKey('closed'), onOpen: _open)
                : _OpenedLoot(
                    key: const ValueKey('opened'),
                    loot: _loot!,
                    scale: _scale,
                    onCollect: () {
                      Navigator.of(context).pop();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ClosedChest extends StatelessWidget {
  final VoidCallback onOpen;
  const _ClosedChest({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🎁', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 14),
        Text('Treasure Chest!',
            style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Earned by completing a task set.',
            style: AppTheme.sans(size: 11, color: AppColors.muted)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onOpen,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text('🔓 Open Chest',
                style: AppTheme.sans(
                    size: 13, weight: FontWeight.w800, color: AppColors.bg)),
          ),
        ),
      ],
    );
  }
}

class _OpenedLoot extends StatelessWidget {
  final LootItemModel loot;
  final Animation<double> scale;
  final VoidCallback onCollect;

  const _OpenedLoot(
      {super.key,
      required this.loot,
      required this.scale,
      required this.onCollect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: scale,
          child: Text(loot.icon, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 10),
        Text(loot.rarity.label.toUpperCase(),
            style: AppTheme.mono(size: 9, color: loot.color)
                .copyWith(letterSpacing: 2)),
        const SizedBox(height: 3),
        Text(loot.name,
            style: AppTheme.sans(size: 16, weight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(loot.desc,
            style: AppTheme.sans(size: 11, color: AppColors.muted)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onCollect,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text('✨ Collect',
                style: AppTheme.sans(
                    size: 13, weight: FontWeight.w800, color: AppColors.bg)),
          ),
        ),
      ],
    );
  }
}

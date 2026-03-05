import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';

class ProofModal extends StatefulWidget {
  final TaskModel task;
  final void Function(int bonusXp) onSubmit;

  const ProofModal({super.key, required this.task, required this.onSubmit});

  @override
  State<ProofModal> createState() => _ProofModalState();
}

class _ProofModalState extends State<ProofModal> {
  final _noteCtrl = TextEditingController();
  int _rating = 0;
  bool _hasPhoto = false;

  static const _ratingEmojis = ['🥱', '😌', '🙂', '😊', '🔥'];

  int get _bonusXp => (_hasPhoto ? 15 : 0) + (_noteCtrl.text.isNotEmpty ? 10 : 0);

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          18, 20, 18, 36 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Complete Quest', style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.task.title,
                style: AppTheme.sans(size: 12, color: AppColors.muted)),
            const SizedBox(height: 16),

            // Proof bonus info
            if (_bonusXp > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.14)),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('+$_bonusXp bonus XP for proof!',
                        style: AppTheme.sans(
                            size: 11,
                            weight: FontWeight.w700,
                            color: AppColors.accent)),
                  ],
                ),
              ),

            // Rating
            Text('HOW DID IT GO?',
                style: AppTheme.mono(size: 9, color: AppColors.subtle)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final active = _rating == i + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.surface3 : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? AppColors.accent : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(_ratingEmojis[i],
                          style: TextStyle(
                              fontSize: active ? 22 : 18)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Photo button
            GestureDetector(
              onTap: () => setState(() => _hasPhoto = !_hasPhoto),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _hasPhoto
                      ? AppColors.accent.withValues(alpha: 0.07)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: _hasPhoto
                        ? AppColors.accent.withValues(alpha: 0.25)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 16,
                        color: _hasPhoto ? AppColors.accent : AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                        _hasPhoto ? 'Photo attached (+15 XP)' : 'Add photo (+15 XP)',
                        style: AppTheme.sans(
                            size: 11,
                            weight: FontWeight.w600,
                            color: _hasPhoto ? AppColors.accent : AppColors.muted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note
            Text('NOTE', style: AppTheme.mono(size: 9, color: AppColors.subtle)),
            const SizedBox(height: 5),
            TextField(
              controller: _noteCtrl,
              style: AppTheme.sans(size: 13),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  hintText: 'Optional notes (+10 XP)…'),
            ),
            const SizedBox(height: 16),

            // Submit
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                widget.onSubmit(_bonusXp);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Complete Quest ✓',
                    style: AppTheme.sans(
                        size: 13, weight: FontWeight.w800, color: AppColors.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

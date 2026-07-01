import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final done = challenge.done;

    return AnimatedOpacity(
      opacity: done ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: done
              ? AppColors.accent.withValues(alpha: 0.03)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: done
                ? AppColors.accent.withValues(alpha: 0.18)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: done
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : AppColors.border,
                ),
              ),
              child: Center(
                  child: Text(challenge.icon,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(challenge.title,
                            style: AppTheme.sans(
                                size: 12, weight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (done) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('DONE',
                              style: AppTheme.mono(
                                  size: 10, color: AppColors.accent)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(challenge.desc,
                      style: AppTheme.sans(size: 11, color: AppColors.subtle)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (done)
                  Text('✓', style: AppTheme.mono(size: 14, weight: FontWeight.w800, color: AppColors.accent))
                else if (challenge.target > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('${challenge.progress}/${challenge.target}',
                        style: AppTheme.mono(size: 12, weight: FontWeight.w800, color: AppColors.purple)),
                  )
                else
                  Text('+${challenge.reward}',
                      style: AppTheme.mono(
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.gold)),
                          
                if (!done)
                  Text('${challenge.reward} XP',
                      style: AppTheme.sans(size: 9, color: AppColors.subtle)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

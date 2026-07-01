import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final String? tooltip;
  const SectionLabel(this.text, {super.key, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: AppTheme.mono(
                    size: 10, color: AppColors.subtle, weight: FontWeight.w700)
                .copyWith(letterSpacing: 2)),
        if (tooltip != null) ...[
          const SizedBox(width: 6),
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: tooltip!,
            child: const Icon(Icons.info_outline, size: 12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

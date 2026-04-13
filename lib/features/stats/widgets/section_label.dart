import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTheme.mono(
                size: 9, color: AppColors.subtle, weight: FontWeight.w700)
            .copyWith(letterSpacing: 2));
  }
}

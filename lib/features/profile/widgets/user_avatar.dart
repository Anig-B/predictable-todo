import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String avatar;
  final double size;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.avatar,
    this.size = 72,
    this.fontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: Text(
          avatar.isEmpty ? '👤' : avatar,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}

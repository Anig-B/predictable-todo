import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class HorizontalBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // {name, completed, total, color}

  const HorizontalBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((item) {
        final completed = item['completed'] as int;
        final total = item['total'] as int;
        final pct = total > 0 ? completed / total : 0.0;
        final color = item['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(item['name'] as String,
                    textAlign: TextAlign.right,
                    style: AppTheme.sans(size: 9, weight: FontWeight.w600, color: AppColors.muted)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 20, color: AppColors.surface2),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('$completed',
                              style: AppTheme.mono(
                                  size: 8,
                                  color: Colors.black.withValues(alpha: 0.65),
                                  weight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

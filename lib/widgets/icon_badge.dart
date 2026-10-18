import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Тёмно-розовый квадратик с иконкой (категория, поездка).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.highlight20,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.highlight40),
      ),
      child: Icon(icon, color: AppColors.highlight, size: size * 0.5),
    );
  }
}

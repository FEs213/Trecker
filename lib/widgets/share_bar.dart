import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Тонкая полоса доли (0..1) в розовом цвете.
class ShareBar extends StatelessWidget {
  const ShareBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        color: AppColors.highlight,
        backgroundColor: AppColors.primary20,
      ),
    );
  }
}

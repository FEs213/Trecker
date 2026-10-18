import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Основная розовая кнопка. [danger] — красная (удаление),
/// [subdued] — приглушённая (вторичное действие).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
    this.subdued = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final Color background = danger
        ? AppColors.error
        : subdued
            ? AppColors.primary20
            : AppColors.highlight;
    final Color foreground =
        subdued ? AppColors.primary : AppColors.primaryInversion;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.primary20,
          disabledForegroundColor: AppColors.primary40,
        ),
        child: Text(label),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Готовые текстовые стили приложения.
abstract final class AppText {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.primary,
  );
  static const amountLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 1.1,
    color: AppColors.primary,
  );
  static const section = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
  static const body = TextStyle(fontSize: 16, color: AppColors.primary);
  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
  static const label = TextStyle(fontSize: 14, color: AppColors.secondary);
  static const caption = TextStyle(fontSize: 13, color: AppColors.secondary);
  static const link = TextStyle(fontSize: 14, color: AppColors.highlight);
}

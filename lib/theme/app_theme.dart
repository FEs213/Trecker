import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

ThemeData buildVelvetTheme() {
  final scheme = ColorScheme.dark(
    primary: AppColors.highlight,
    onPrimary: AppColors.primaryInversion,
    secondary: AppColors.highlight80,
    onSecondary: AppColors.primaryInversion,
    error: AppColors.error,
    onError: AppColors.primaryInversion,
    surface: AppColors.surfaceElevated,
    onSurface: AppColors.primary,
    onSurfaceVariant: AppColors.secondary,
    outline: AppColors.primary40,
    outlineVariant: AppColors.primary20,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme.apply(
    bodyColor: AppColors.primary,
    displayColor: AppColors.primary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: AppColors.surfaceElevated,
    textTheme: text,
    dividerColor: AppColors.cardBorder,
    dividerTheme: const DividerThemeData(
      color: AppColors.cardBorder,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.primary80),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.primaryInversion,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.highlight80),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.highlight),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBackground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? AppColors.highlight
              : AppColors.secondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? AppColors.highlight
              : AppColors.secondary,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceElevated,
      modalBackgroundColor: AppColors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.primary40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: AppText.section,
      contentTextStyle: AppText.label,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: AppText.body,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.primary,
      iconColor: AppColors.highlight,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.highlight,
      selectionHandleColor: AppColors.highlight,
    ),
  );
}

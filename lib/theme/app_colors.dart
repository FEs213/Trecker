import 'package:flutter/material.dart';

/// Палитра Red Velvet [Dark] из спецификации Aurora OS UI Kit.
abstract final class AppColors {
  // Primary (светлый текст на тёмном)
  static const primary = Color(0xFFFFFFFF); // 100%
  static const primary80 = Color(0xFFD4CCCD); // 80%
  static const secondary = Color(0xFFA8999C); // 60%
  static const primary40 = Color(0xFF7A666A); // 40%
  static const primary20 = Color(0xFF4B3339); // 20%

  // Highlight (розовый акцент)
  static const highlight = Color(0xFFFF80AD); // 100%
  static const highlight80 = Color(0xFFD5668D); // 80%
  static const highlight60 = Color(0xFFAF4D6E); // 60%
  static const highlight40 = Color(0xFF87334E); // 40%
  static const highlight20 = Color(0xFF591A2D); // 20%

  // Прочие цвета
  static const highlightBackground = Color(0xFFE50051);
  static const highlightDimmer = Color(0xFF330012);
  static const overlayBackground = Color(0xA6080002); // 65%
  static const primaryInversion = Color(0xFF000000);
  static const secondaryInversion = Color(0xFF080002);

  // Ошибка / удаление
  static const error = Color(0xFFFF4D4D);
  static const errorSecondary = Color(0xFF9A191B);

  // Фон приложения (градиент) и поверхности
  static const backgroundTop = Color(0xFF2C0008);
  static const backgroundBottom = Color(0xFF100005);
  static const backgroundGlow = Color(0xB33F0015);
  static const navBackground = Color(0xFF160009);
  static const surfaceElevated = Color(0xFF2A0E16);
  static const cardFill = Color(0x14FFFFFF); // белый 8%
  static const cardBorder = Color(0x1FFFFFFF); // белый 12%
  static const fieldFill = Color(0x0FFFFFFF); // белый 6%
  static const fieldLine = Color(0x40FFFFFF); // белый 25%
}

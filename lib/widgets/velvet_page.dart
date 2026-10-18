import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Каркас экрана: заголовок с белой полоской слева, прокручиваемое тело
/// и необязательная нижняя кнопка действия.
class VelvetPage extends StatelessWidget {
  const VelvetPage({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.bottom,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: title, trailing: trailing),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: children,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 12),
      child: Row(
        children: [
          Container(width: 3, height: 30, color: AppColors.primary),
          const SizedBox(width: 13),
          Expanded(child: Text(title, style: AppText.title)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

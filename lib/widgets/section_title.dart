import 'package:flutter/material.dart';

import '../theme/app_text.dart';

/// Заголовок раздела с необязательным текстом справа («Все →»).
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.section),
        if (trailing != null) trailing!,
      ],
    );
  }
}

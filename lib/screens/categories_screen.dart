import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_page.dart';

/// Вкладка «Категории»: стандартные категории (свои — следующий шаг).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VelvetPage(
      title: 'Категории',
      bottom: PrimaryButton(
        label: 'Добавить категорию',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Экран появится на следующем шаге')),
        ),
      ),
      children: [
        Text(
          'Стандартные · ${demoCategories.length} категорий',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        for (final category in demoCategories)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(category.icon, color: AppColors.highlight),
                const SizedBox(width: 16),
                Text(category.name, style: AppText.body),
              ],
            ),
          ),
      ],
    );
  }
}

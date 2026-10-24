import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'primary_button.dart';

/// Диалог подтверждения удаления (как в макете). Возвращает true,
/// если пользователь нажал «Удалить».
Future<bool> showDeleteConfirm(
  BuildContext context, {
  required String title,
  required String summary,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.delete_outline, color: AppColors.highlight),
            const SizedBox(height: 16),
            Text(title, style: AppText.title),
            const SizedBox(height: 12),
            Text(summary, style: AppText.body),
            const SizedBox(height: 12),
            Text(message, style: AppText.label),
            const SizedBox(height: 24),
            Builder(
              builder: (dialogContext) => PrimaryButton(
                label: 'Удалить',
                danger: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (dialogContext) => PrimaryButton(
                label: 'Отмена',
                subdued: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

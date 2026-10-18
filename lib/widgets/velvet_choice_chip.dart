import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Круглая «таблетка» выбора (способ оплаты, фильтры).
class VelvetChoiceChip extends StatelessWidget {
  const VelvetChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = StadiumBorder(
      side: BorderSide(
        color: selected ? AppColors.highlight : AppColors.cardBorder,
      ),
    );
    return Material(
      color: selected ? AppColors.highlight20 : AppColors.fieldFill,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 16, color: AppColors.highlight),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: selected ? AppColors.highlight : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

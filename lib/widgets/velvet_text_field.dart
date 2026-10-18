import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Поле ввода в стиле макета: подпись сверху, залитое поле с линией снизу.
class VelvetTextField extends StatelessWidget {
  const VelvetTextField({
    super.key,
    this.label,
    this.hint = 'Поле ввода',
    this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.inputFormatters,
    this.onChanged,
  });

  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  static const _radius = BorderRadius.vertical(top: Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    const lineSide = BorderSide(color: AppColors.fieldLine);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label),
          const SizedBox(height: 4),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppText.body.copyWith(fontSize: 18),
          cursorColor: AppColors.highlight,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(
              fontSize: 18,
              color: AppColors.primary40,
            ),
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.primary80),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.secondary),
            border: const UnderlineInputBorder(
              borderRadius: _radius,
              borderSide: lineSide,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderRadius: _radius,
              borderSide: lineSide,
            ),
            focusedBorder: const UnderlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppColors.highlight, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

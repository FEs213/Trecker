import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Фирменный фон Red Velvet: тёмно-бордовый градиент со свечением слева.
class VelvetBackground extends StatelessWidget {
  const VelvetBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.0, 0.1),
            radius: 1.1,
            colors: [AppColors.backgroundGlow, Color(0x003F0015)],
          ),
        ),
        child: child,
      ),
    );
  }
}

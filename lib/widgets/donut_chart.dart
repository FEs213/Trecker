import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Цвета сегментов для стандартных категорий (оттенки палитры Red Velvet).
const kChartPalette = <Color>[
  Color(0xFFFF80AD),
  Color(0xFFE8639B),
  Color(0xFFC25A86),
  Color(0xFFA48BC9),
  Color(0xFFDDA58C),
  Color(0xFFB9B1E3),
  Color(0xFFF4A6C0),
  Color(0xFF8E5A7A),
];

class DonutSegment {
  const DonutSegment({required this.value, required this.color});

  final int value;
  final Color color;
}

/// Кольцевая диаграмма; [center] рисуется в середине кольца.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 190,
    this.center,
  });

  final List<DonutSegment> segments;
  final double size;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(segments),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments);

  final List<DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.15;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = segments.fold<int>(0, (sum, s) => sum + s.value);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true;

    if (total <= 0) {
      paint.color = AppColors.primary20;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    final gap = segments.length > 1 ? 0.05 : 0.0;
    var start = -math.pi / 2;
    for (final segment in segments) {
      final sweep = math.pi * 2 * segment.value / total;
      paint.color = segment.color;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(sweep - gap, 0.001),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final a = oldDelegate.segments[i];
      final b = segments[i];
      if (a.value != b.value || a.color != b.color) return true;
    }
    return false;
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Katta, bosish oson karta: emoji + yozuv (NFR-1).
/// O'yin tanlash, daraja tanlash va profil tanlashda ishlatiladi.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    this.footer,
    this.size = 150,
  });

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final Widget? footer;
  final double size;

  static const _baseStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  /// So'zlar orasidan qatorga o'tadi, lekin so'z o'rtasidan bo'linmaydi:
  /// eng uzun so'z sig'masa, shrift kichrayadi ("Tenglamalar", "Geometriya").
  TextStyle _labelStyle(BuildContext context, double maxWidth) {
    var widest = 0.0;
    for (final word in label.split(' ')) {
      final painter = TextPainter(
        text: TextSpan(text: word, style: _baseStyle),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      widest = max(widest, painter.width);
      painter.dispose();
    }
    if (widest <= maxWidth) return _baseStyle;
    final fontSize = (_baseStyle.fontSize! * maxWidth / widest).floorToDouble();
    return _baseStyle.copyWith(fontSize: fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: size * 0.35)),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final style = _labelStyle(context, constraints.maxWidth);
                    return Text(label, textAlign: TextAlign.center, style: style);
                  },
                ),
                if (footer != null) ...[const SizedBox(height: 4), footer!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

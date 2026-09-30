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
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
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

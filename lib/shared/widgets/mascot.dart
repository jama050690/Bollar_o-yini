import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Yordamchi qahramon — boyo'g'li Donish 🦉.
///
/// Ekran ochilganda biroz chayqaladi va pufakchada gapiradi.
/// [messages] dan biri tasodifiy tanlanadi (ekran qayta chizilsa o'zgarmaydi).
class Mascot extends StatefulWidget {
  const Mascot({super.key, required this.messages, this.size = 64, this.random});

  final List<String> messages;
  final double size;

  /// Testlar uchun: tanlovni oldindan aytib bo'ladigan qilish.
  final Random? random;

  static const emoji = '🦉';

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> {
  late final String _message =
      widget.messages[(widget.random ?? Random()).nextInt(widget.messages.length)];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.mascotName,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bir necha marta yuqori-pastga chayqaladi va to'xtaydi.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 2400),
            builder: (context, t, child) => Transform.translate(
              offset: Offset(0, -6 * sin(t * pi * 6).abs() * (1 - t)),
              child: child,
            ),
            child: Text(Mascot.emoji, style: TextStyle(fontSize: widget.size)),
          ),
          const SizedBox(width: 8),
          Flexible(child: _SpeechBubble(text: _message)),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: Alignment.centerLeft,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

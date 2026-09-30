import 'package:flutter/material.dart';

/// 3 ta yulduzcha: to'lganlari sariq, qolganlari kulrang.
class StarsRow extends StatelessWidget {
  const StarsRow({super.key, required this.stars, this.size = 24});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < stars ? const Color(0xFFFFB300) : Colors.black26,
          ),
      ],
    );
  }
}

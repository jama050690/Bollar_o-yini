import 'package:flutter/material.dart';

import 'shape_sorter_game.dart';

/// Rangli shakl (doira, kvadrat, uchburchak).
class ToyView extends StatelessWidget {
  const ToyView({super.key, required this.toy, required this.size});

  final Toy toy;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ShapePainter(shape: toy.shape, fill: toy.color.color),
      ),
    );
  }
}

/// Shakl konturi — "shakl bo'yicha saralash" savatlari uchun.
class ShapeOutline extends StatelessWidget {
  const ShapeOutline({super.key, required this.shape, required this.size});

  final ToyShape shape;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ShapePainter(shape: shape, fill: null)),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.shape, required this.fill});

  final ToyShape shape;

  /// null bo'lsa faqat kontur chiziladi.
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill!);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.06
        ..strokeJoin = StrokeJoin.round
        ..color = fill == null ? const Color(0xFF546E7A) : Colors.black26,
    );
  }

  Path _path(Size size) {
    final inset = size.width * 0.06;
    final rect = Offset(inset, inset) & Size(size.width - inset * 2, size.height - inset * 2);
    return switch (shape) {
      ToyShape.circle => Path()..addOval(rect),
      ToyShape.square => Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.12))),
      ToyShape.triangle => Path()
        ..moveTo(rect.center.dx, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close(),
    };
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.shape != shape || old.fill != fill;
}

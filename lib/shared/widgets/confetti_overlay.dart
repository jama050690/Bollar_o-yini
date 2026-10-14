import 'dart:math';

import 'package:flutter/material.dart';

/// Tepadan yog'iladigan rangli konfetti (bir marta, ~2.5 soniya).
///
/// Bosishlarni o'tkazib yuboradi — ostidagi tugmalarga xalaqit bermaydi.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.count = 60});

  /// Bo'lakchalar soni.
  final int count;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFFEF5350),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  )..forward();

  late final List<_Piece> _pieces = () {
    final random = Random();
    return [
      for (var i = 0; i < widget.count; i++)
        _Piece(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.35,
          drift: (random.nextDouble() - 0.5) * 0.3,
          spin: (random.nextDouble() - 0.5) * 12,
          size: 8 + random.nextDouble() * 8,
          color: _colors[random.nextInt(_colors.length)],
        ),
    ];
  }();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _controller),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
  });

  /// Boshlang'ich gorizontal joy (0..1).
  final double x;

  /// Tushishni boshlash kechikishi (animatsiya ulushida).
  final double delay;

  /// Yon tomonga siljish (ekran kengligi ulushida).
  final double drift;
  final double spin;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.progress) : super(repaint: progress);

  final List<_Piece> pieces;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      final t = ((progress.value - piece.delay) / (1 - piece.delay)).clamp(
        0.0,
        1.0,
      );
      if (t <= 0 || t >= 1) continue;

      final dx =
          (piece.x + piece.drift * t + sin(t * pi * 4) * 0.02) * size.width;
      final dy = -piece.size + t * (size.height + piece.size * 2);
      // Oxirida asta-sekin yo'qoladi.
      paint.color = piece.color.withValues(alpha: t > 0.8 ? (1 - t) / 0.2 : 1);

      canvas
        ..save()
        ..translate(dx, dy)
        ..rotate(piece.spin * t)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}

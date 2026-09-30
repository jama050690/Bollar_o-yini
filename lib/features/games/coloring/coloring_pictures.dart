import 'dart:math';
import 'dart:ui';

import '../../../core/constants/app_strings.dart';

/// Bo'yash rasmi: 100×100 koordinatadagi bo'laklar (pastdan yuqoriga chiziladi)
/// va bo'yalmaydigan bezak chiziqlari (ko'z, mo'ylov, ip va h.k.).
class ColoringPicture {
  ColoringPicture({
    required this.name,
    required this.emoji,
    required this.regions,
    this.details = const [],
    this.dots = const [],
  });

  final String name;
  final String emoji;
  final List<Path> regions;

  /// Faqat kontur bilan chiziladigan chiziqlar.
  final List<Path> details;

  /// Qora nuqtalar (ko'z, urug' va h.k.).
  final List<Path> dots;
}

// ---------- Yordamchi shakllar ----------

Path _circle(double cx, double cy, double r) =>
    Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

Path _oval(double l, double t, double w, double h) => Path()..addOval(Rect.fromLTWH(l, t, w, h));

Path _rect(double l, double t, double w, double h) => Path()..addRect(Rect.fromLTWH(l, t, w, h));

Path _rrect(double l, double t, double w, double h, double r) =>
    Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l, t, w, h), Radius.circular(r)));

Path _poly(List<Offset> points) => Path()..addPolygon(points, true);

Path _line(List<Offset> points) => Path()..addPolygon(points, false);

// ---------- Rasmlar ----------

ColoringPicture _balloons() => ColoringPicture(
      name: AppStrings.picBalloons,
      emoji: '🎈',
      regions: [
        _oval(10, 18, 28, 36),
        _poly(const [Offset(24, 54), Offset(20, 60), Offset(28, 60)]),
        _oval(62, 18, 28, 36),
        _poly(const [Offset(76, 54), Offset(72, 60), Offset(80, 60)]),
        _oval(36, 6, 28, 36),
        _poly(const [Offset(50, 42), Offset(46, 48), Offset(54, 48)]),
      ],
      details: [
        _line(const [Offset(24, 60), Offset(50, 94)]),
        _line(const [Offset(50, 48), Offset(50, 94)]),
        _line(const [Offset(76, 60), Offset(50, 94)]),
      ],
    );

ColoringPicture _apple() => ColoringPicture(
      name: AppStrings.picApple,
      emoji: '🍎',
      regions: [
        _rrect(47, 8, 6, 22, 3),
        Path()
          ..moveTo(52, 18)
          ..quadraticBezierTo(66, 4, 80, 12)
          ..quadraticBezierTo(68, 26, 52, 18)
          ..close(),
        Path()
          ..moveTo(50, 30)
          ..cubicTo(30, 18, 10, 30, 12, 55)
          ..cubicTo(14, 80, 32, 94, 50, 88)
          ..cubicTo(68, 94, 86, 80, 88, 55)
          ..cubicTo(90, 30, 70, 18, 50, 30)
          ..close(),
        _oval(64, 40, 9, 16),
      ],
    );

ColoringPicture _pear() => ColoringPicture(
      name: AppStrings.picPear,
      emoji: '🍐',
      regions: [
        _rrect(48, 6, 5, 18, 2),
        Path()
          ..moveTo(52, 16)
          ..quadraticBezierTo(64, 4, 76, 10)
          ..quadraticBezierTo(66, 22, 52, 16)
          ..close(),
        Path.combine(PathOperation.union, _circle(50, 38, 16), _circle(50, 68, 27)),
      ],
    );

ColoringPicture _strawberry() => ColoringPicture(
      name: AppStrings.picStrawberry,
      emoji: '🍓',
      regions: [
        Path()
          ..moveTo(18, 36)
          ..quadraticBezierTo(50, 22, 82, 36)
          ..quadraticBezierTo(84, 70, 50, 94)
          ..quadraticBezierTo(16, 70, 18, 36)
          ..close(),
        _poly(const [
          Offset(26, 34),
          Offset(36, 18),
          Offset(44, 28),
          Offset(50, 14),
          Offset(56, 28),
          Offset(64, 18),
          Offset(74, 34),
          Offset(50, 40),
        ]),
        _rrect(48, 4, 5, 14, 2),
      ],
      dots: [
        for (final p in const [
          Offset(34, 50),
          Offset(50, 48),
          Offset(66, 50),
          Offset(40, 64),
          Offset(60, 64),
          Offset(50, 78),
        ])
          _circle(p.dx, p.dy, 1.8),
      ],
    );

ColoringPicture _cat() => ColoringPicture(
      name: AppStrings.picCat,
      emoji: '🐱',
      regions: [
        _poly(const [Offset(70, 84), Offset(90, 56), Offset(96, 60), Offset(78, 90)]),
        _oval(24, 52, 52, 44),
        _poly(const [Offset(30, 30), Offset(32, 6), Offset(48, 20)]),
        _poly(const [Offset(52, 20), Offset(68, 6), Offset(70, 30)]),
        _circle(50, 38, 22),
      ],
      details: [
        _line(const [Offset(20, 40), Offset(40, 44)]),
        _line(const [Offset(20, 48), Offset(40, 46)]),
        _line(const [Offset(80, 40), Offset(60, 44)]),
        _line(const [Offset(80, 48), Offset(60, 46)]),
        _line(const [Offset(44, 50), Offset(50, 53), Offset(56, 50)]),
      ],
      dots: [
        _circle(42, 34, 3),
        _circle(58, 34, 3),
        _circle(50, 44, 2.2),
      ],
    );

ColoringPicture _fish() => ColoringPicture(
      name: AppStrings.picFish,
      emoji: '🐟',
      regions: [
        _poly(const [Offset(68, 52), Offset(94, 30), Offset(94, 74)]),
        _poly(const [Offset(34, 36), Offset(48, 16), Offset(60, 36)]),
        _oval(8, 30, 66, 44),
        _circle(84, 14, 5),
        _circle(74, 6, 3.5),
      ],
      details: [
        _line(const [Offset(30, 38), Offset(26, 52), Offset(30, 66)]),
      ],
      dots: [_circle(20, 46, 3)],
    );

ColoringPicture _butterfly() => ColoringPicture(
      name: AppStrings.picButterfly,
      emoji: '🦋',
      regions: [
        _oval(8, 14, 40, 38),
        _oval(52, 14, 40, 38),
        _oval(16, 48, 32, 32),
        _oval(52, 48, 32, 32),
        _rrect(45, 20, 10, 62, 5),
      ],
      details: [
        _line(const [Offset(48, 22), Offset(38, 6)]),
        _line(const [Offset(52, 22), Offset(62, 6)]),
      ],
      dots: [_circle(38, 6, 2), _circle(62, 6, 2)],
    );

ColoringPicture _house() => ColoringPicture(
      name: AppStrings.picHouse,
      emoji: '🏠',
      regions: [
        _rect(66, 14, 10, 24),
        _rect(20, 46, 60, 46),
        _poly(const [Offset(10, 48), Offset(50, 10), Offset(90, 48)]),
        _rrect(42, 64, 16, 28, 2),
        _rect(25, 56, 13, 13),
        _rect(62, 56, 13, 13),
      ],
      dots: [_circle(54, 79, 1.6)],
    );

ColoringPicture _star() {
  const center = Offset(50, 54);
  Offset point(double radius, double degrees) {
    final a = degrees * pi / 180;
    return center + Offset(cos(a) * radius, sin(a) * radius);
  }

  final outer = [for (var k = 0; k < 5; k++) point(46, -90 + 72.0 * k)];
  final inner = [for (var k = 0; k < 5; k++) point(18, -54 + 72.0 * k)];
  return ColoringPicture(
    name: AppStrings.picStar,
    emoji: '⭐',
    regions: [
      // 5 ta uchburchak nur + o'rtadagi beshburchak.
      for (var k = 0; k < 5; k++) _poly([inner[(k + 4) % 5], outer[k], inner[k]]),
      _poly(inner),
    ],
  );
}

ColoringPicture _flower() {
  final petals = [
    for (var k = 0; k < 5; k++)
      _circle(50 + cos((-90 + 72.0 * k) * pi / 180) * 17, 36 + sin((-90 + 72.0 * k) * pi / 180) * 17,
          13),
  ];
  return ColoringPicture(
    name: AppStrings.picFlower,
    emoji: '🌸',
    regions: [
      _rect(48, 50, 5, 46),
      Path()
        ..moveTo(52, 80)
        ..quadraticBezierTo(70, 60, 86, 68)
        ..quadraticBezierTo(72, 86, 52, 80)
        ..close(),
      Path()
        ..moveTo(49, 72)
        ..quadraticBezierTo(30, 54, 14, 62)
        ..quadraticBezierTo(28, 80, 49, 72)
        ..close(),
      ...petals,
      _circle(50, 36, 10),
    ],
  );
}

/// Barcha rasmlar (Path'lar faqat kerak bo'lganda yaratiladi).
final List<ColoringPicture Function()> coloringPictures = [
  _balloons,
  _apple,
  _pear,
  _strawberry,
  _cat,
  _fish,
  _butterfly,
  _house,
  _star,
  _flower,
];

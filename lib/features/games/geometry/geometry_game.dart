import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

enum GeoShape { square, rectangle, rightTriangle }

/// Nima so'raladi: perimetr, yuz yoki yuzi berilgan to'rtburchakning noma'lum tomoni.
enum GeoAsk { perimeter, area, missingSide }

/// Daraja: ① perimetr ② yuz ③ uchburchak yuzi va noma'lum tomon.
enum GeometryLevel {
  perimeter(label: AppStrings.levelPerimeter, emoji: '📏'),
  area(label: AppStrings.levelArea, emoji: '🟦'),
  mix(label: AppStrings.levelGeoMix, emoji: '📐');

  const GeometryLevel({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

class GeometryQuestion {
  const GeometryQuestion(this.shape, this.ask, this.width, this.height, this.options);

  final GeoShape shape;
  final GeoAsk ask;

  /// Tomonlar (sm). Kvadratda width == height; uchburchakda katetlar.
  final int width;
  final int height;

  final List<int> options;

  int get area => shape == GeoShape.rightTriangle ? width * height ~/ 2 : width * height;

  int get answer => switch (ask) {
        GeoAsk.perimeter => 2 * (width + height),
        GeoAsk.area => area,
        GeoAsk.missingSide => height,
      };
}

enum GeometryOutcome { correct, wrong, finished }

/// Geometriya: chizilgan shaklning perimetri, yuzi yoki noma'lum tomoni. 10 ta savol.
class GeometryGame {
  GeometryGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [for (var i = 0; i < questionCount; i++) makeQuestion(level, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final GeometryLevel level;
  late final List<GeometryQuestion> questions;
  int step = 0;
  int mistakes = 0;

  GeometryQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static GeometryQuestion makeQuestion(GeometryLevel level, Random rnd) {
    int between(int min, int max) => min + rnd.nextInt(max - min + 1);

    GeoShape shape;
    GeoAsk ask;
    var w = between(2, 12);
    var h = between(2, 9);
    switch (level) {
      case GeometryLevel.perimeter:
      case GeometryLevel.area:
        ask = level == GeometryLevel.perimeter ? GeoAsk.perimeter : GeoAsk.area;
        shape = rnd.nextInt(3) == 0 ? GeoShape.square : GeoShape.rectangle;
      case GeometryLevel.mix:
        if (rnd.nextBool()) {
          shape = GeoShape.rightTriangle;
          ask = GeoAsk.area;
          if (w.isOdd && h.isOdd) w++; // yuz butun son bo'lsin
        } else {
          shape = GeoShape.rectangle;
          ask = GeoAsk.missingSide;
        }
    }
    if (shape == GeoShape.square) h = w;
    if (shape == GeoShape.rectangle && w == h) w++;

    final q = GeometryQuestion(shape, ask, w, h, const []);
    final answer = q.answer;
    // Odatiy xatolar: perimetr o'rniga yuz (va aksincha), yarim perimetr, uchburchakda 2 ga bo'lmaslik.
    final candidates = <int>{
      if (ask == GeoAsk.perimeter) w * h,
      if (ask == GeoAsk.perimeter) w + h,
      if (ask == GeoAsk.area) 2 * (w + h),
      if (shape == GeoShape.rightTriangle) w * h,
      if (ask == GeoAsk.missingSide) w * h - w,
      answer + 1,
      answer - 1,
      answer + 2,
      answer - 2,
    }.where((v) => v > 0 && v != answer).toList()
      ..shuffle(rnd);
    return GeometryQuestion(
      shape,
      ask,
      w,
      h,
      [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd),
    );
  }

  GeometryOutcome answer(int option) {
    if (option != current.answer) {
      mistakes++;
      return GeometryOutcome.wrong;
    }
    step++;
    return isFinished ? GeometryOutcome.finished : GeometryOutcome.correct;
  }
}

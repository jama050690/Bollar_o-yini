import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

enum PieceShape { triangle, square, circle, rectangle }

/// Buyumning bitta bo'lagi. Joylashuv 0..1 oralig'ida (taxta o'lchamiga nisbatan).
class ShapePart {
  const ShapePart(this.shape, this.color, this.left, this.top, this.width, this.height);

  final PieceShape shape;
  final int color;
  final double left;
  final double top;
  final double width;
  final double height;

  /// Barmoq biroz chetga tushsa ham qabul qilamiz (kichkintoylar uchun).
  bool contains(double x, double y, {double tolerance = 0.08}) =>
      x >= left - tolerance &&
      x <= left + width + tolerance &&
      y >= top - tolerance &&
      y <= top + height + tolerance;
}

class BuildObject {
  const BuildObject(this.name, this.emoji, this.parts);

  final String name;
  final String emoji;
  final List<ShapePart> parts;
}

const _red = 0xFFE53935;
const _blue = 0xFF1E88E5;
const _yellow = 0xFFFDD835;
const _green = 0xFF43A047;
const _brown = 0xFF8D6E63;
const _dark = 0xFF455A64;
const _sky = 0xFF81D4FA;
const _orange = 0xFFFB8C00;

const buildObjects = [
  BuildObject(AppStrings.objHouse, '🏠', [
    ShapePart(PieceShape.triangle, _red, 0.1, 0.08, 0.8, 0.37),
    ShapePart(PieceShape.square, _yellow, 0.25, 0.45, 0.5, 0.5),
    ShapePart(PieceShape.rectangle, _brown, 0.43, 0.68, 0.14, 0.27),
  ]),
  BuildObject(AppStrings.objCar, '🚗', [
    ShapePart(PieceShape.square, _sky, 0.32, 0.14, 0.3, 0.3),
    ShapePart(PieceShape.rectangle, _blue, 0.05, 0.42, 0.9, 0.26),
    ShapePart(PieceShape.circle, _dark, 0.14, 0.58, 0.24, 0.24),
    ShapePart(PieceShape.circle, _dark, 0.62, 0.58, 0.24, 0.24),
  ]),
  BuildObject(AppStrings.objTree, '🌳', [
    ShapePart(PieceShape.triangle, _green, 0.18, 0.04, 0.64, 0.34),
    ShapePart(PieceShape.triangle, _green, 0.08, 0.3, 0.84, 0.4),
    ShapePart(PieceShape.rectangle, _brown, 0.42, 0.7, 0.16, 0.28),
  ]),
  BuildObject(AppStrings.objRocket, '🚀', [
    ShapePart(PieceShape.triangle, _red, 0.35, 0.02, 0.3, 0.2),
    ShapePart(PieceShape.rectangle, _blue, 0.35, 0.22, 0.3, 0.56),
    ShapePart(PieceShape.circle, _sky, 0.42, 0.3, 0.16, 0.16),
    ShapePart(PieceShape.triangle, _orange, 0.17, 0.6, 0.18, 0.3),
    ShapePart(PieceShape.triangle, _orange, 0.65, 0.6, 0.18, 0.3),
  ]),
  BuildObject(AppStrings.objCat, '🐱', [
    ShapePart(PieceShape.circle, _orange, 0.2, 0.42, 0.56, 0.56),
    ShapePart(PieceShape.circle, _orange, 0.3, 0.08, 0.4, 0.4),
    ShapePart(PieceShape.triangle, _orange, 0.3, 0.0, 0.14, 0.14),
    ShapePart(PieceShape.triangle, _orange, 0.56, 0.0, 0.14, 0.14),
  ]),
];

enum PlaceResult { correct, wrong, objectFinished, gameFinished }

/// Shakldan buyum: har bir bo'lakni konturdagi o'z joyiga sudrab qo'yish.
class ShapeBuilderGame {
  ShapeBuilderGame({Random? random, List<BuildObject> objects = buildObjects})
      : _random = random ?? Random(),
        objects = List.of(objects) {
    this.objects.shuffle(_random);
    _prepare();
  }

  final Random _random;
  final List<BuildObject> objects;

  int objectIndex = 0;
  int mistakes = 0;

  /// Joyiga qo'yilgan bo'laklar (current.parts indekslari).
  final Set<int> filled = {};

  /// Pastdagi tanlanadigan bo'laklar (current.parts indekslari, aralash tartibda).
  List<int> tray = [];

  BuildObject get current => objects[objectIndex];
  bool get isObjectComplete => filled.length == current.parts.length;
  bool get isLastObject => objectIndex == objects.length - 1;
  int get stars => starsForMistakes(mistakes);

  void _prepare() {
    filled.clear();
    tray = List.generate(current.parts.length, (i) => i)..shuffle(_random);
  }

  /// [partIndex] — sudralgan bo'lak, (x, y) — tashlangan nuqta (0..1).
  /// Shu nuqtada bir xil shakldagi bo'sh joy bo'lsa — joylashadi.
  PlaceResult place(int partIndex, double x, double y) {
    final shape = current.parts[partIndex].shape;
    // Ustma-ust joylar bo'lsa, ustidagisi (ro'yxatda keyingisi) birinchi tekshiriladi.
    int? slot;
    for (var i = current.parts.length - 1; i >= 0; i--) {
      final part = current.parts[i];
      if (!filled.contains(i) && part.shape == shape && part.contains(x, y)) {
        slot = i;
        break;
      }
    }
    if (slot == null) {
      mistakes++;
      return PlaceResult.wrong;
    }

    filled.add(slot);
    // Bir xil shakldagi bo'laklar almashinuvchan: sudralgan bo'lak qaysi
    // mos joyga tushsa ham qabul qilinadi va trayda yo'qoladi.
    tray.remove(partIndex);
    if (!isObjectComplete) return PlaceResult.correct;
    return isLastObject ? PlaceResult.gameFinished : PlaceResult.objectFinished;
  }

  void nextObject() {
    if (isLastObject) return;
    objectIndex++;
    _prepare();
  }
}

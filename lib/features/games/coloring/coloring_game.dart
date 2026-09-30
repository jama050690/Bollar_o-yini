import 'dart:ui';

import 'coloring_pictures.dart';

/// Palitra: 12 ta yorqin rang.
const coloringPalette = [
  0xFFE53935, // qizil
  0xFFFB8C00, // to'q sariq
  0xFFFDD835, // sariq
  0xFF7CB342, // och yashil
  0xFF2E7D32, // yashil
  0xFF29B6F6, // havorang
  0xFF1E88E5, // ko'k
  0xFF8E24AA, // binafsha
  0xFFF06292, // pushti
  0xFF8D6E63, // jigarrang
  0xFF757575, // kulrang
  0xFF212121, // qora
];

enum ColoringOutcome { none, painted, finished }

/// Bo'yash mantiqi: xato yo'q — har bo'lakni istalgan rangga bo'yash mumkin.
/// Hamma bo'lak bo'yalgach rasm tayyor (natija doim 3 yulduz).
class ColoringGame {
  ColoringGame(this.picture) : colors = List.filled(picture.regions.length, null);

  static const stars = 3;

  final ColoringPicture picture;

  /// Har bo'lakning rangi (null — hali bo'yalmagan).
  final List<int?> colors;
  int selectedColor = coloringPalette.first;

  bool get isComplete => colors.every((c) => c != null);

  /// 100×100 koordinatadagi nuqtada eng ustki bo'lak indeksi.
  int? regionAt(Offset point) {
    for (var i = picture.regions.length - 1; i >= 0; i--) {
      if (picture.regions[i].contains(point)) return i;
    }
    return null;
  }

  ColoringOutcome tap(Offset point) {
    final index = regionAt(point);
    if (index == null) return ColoringOutcome.none;
    final wasComplete = isComplete;
    colors[index] = selectedColor;
    return !wasComplete && isComplete ? ColoringOutcome.finished : ColoringOutcome.painted;
  }

  void clear() => colors.fillRange(0, colors.length, null);
}

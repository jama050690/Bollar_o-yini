import 'dart:math';
import 'dart:ui';

import '../game_result.dart';

enum ToyShape { circle, square, triangle }

enum ToyColor {
  red(Color(0xFFEF5350)),
  blue(Color(0xFF42A5F5)),
  yellow(Color(0xFFFFCA28));

  const ToyColor(this.color);

  final Color color;
}

class Toy {
  const Toy(this.id, this.shape, this.color);

  final int id;
  final ToyShape shape;
  final ToyColor color;
}

enum SortBy { color, shape }

/// Savat: yoki bitta rangni, yoki bitta shaklni qabul qiladi.
class SortBin {
  const SortBin.color(ToyColor this.color) : shape = null;
  const SortBin.shape(ToyShape this.shape) : color = null;

  final ToyColor? color;
  final ToyShape? shape;

  bool accepts(Toy toy) => color != null ? toy.color == color : toy.shape == shape;
}

class SorterRound {
  SorterRound(this.sortBy, this.bins, this.toys);

  final SortBy sortBy;
  final List<SortBin> bins;
  final List<Toy> toys;
}

enum DropOutcome { correct, wrong, roundFinished, gameFinished }

/// O'yin mantiqi. Raundlar: 2 rang → 3 rang → 3 shakl (osondan qiyinga).
class ShapeSorterGame {
  ShapeSorterGame({Random? random}) : rounds = _buildRounds(random ?? Random()) {
    _resetRound();
  }

  static const toysPerBin = 2;

  final List<SorterRound> rounds;
  int roundIndex = 0;
  int mistakes = 0;

  /// Hali saralanmagan o'yinchoqlar.
  late List<Toy> remaining;

  /// Har bir savatga (indeks bo'yicha) tushgan o'yinchoqlar.
  late List<List<Toy>> placed;

  SorterRound get currentRound => rounds[roundIndex];
  int get stars => starsForMistakes(mistakes);

  static List<SorterRound> _buildRounds(Random random) {
    var nextId = 0;

    SorterRound byColor(List<ToyColor> colors) {
      final toys = [
        for (final c in colors)
          for (var i = 0; i < toysPerBin; i++)
            Toy(nextId++, ToyShape.values[random.nextInt(ToyShape.values.length)], c),
      ]..shuffle(random);
      return SorterRound(SortBy.color, [for (final c in colors) SortBin.color(c)], toys);
    }

    SorterRound byShape(List<ToyShape> shapes) {
      final toys = [
        for (final s in shapes)
          for (var i = 0; i < toysPerBin; i++)
            Toy(nextId++, s, ToyColor.values[random.nextInt(ToyColor.values.length)]),
      ]..shuffle(random);
      return SorterRound(SortBy.shape, [for (final s in shapes) SortBin.shape(s)], toys);
    }

    final twoColors = (List.of(ToyColor.values)..shuffle(random)).take(2).toList();
    return [
      byColor(twoColors),
      byColor(ToyColor.values),
      byShape(ToyShape.values),
    ];
  }

  void _resetRound() {
    remaining = List.of(currentRound.toys);
    placed = [for (final _ in currentRound.bins) <Toy>[]];
  }

  DropOutcome drop(Toy toy, int binIndex) {
    if (!currentRound.bins[binIndex].accepts(toy)) {
      mistakes++;
      return DropOutcome.wrong;
    }
    remaining.removeWhere((t) => t.id == toy.id);
    placed[binIndex].add(toy);
    if (remaining.isNotEmpty) return DropOutcome.correct;
    return roundIndex == rounds.length - 1 ? DropOutcome.gameFinished : DropOutcome.roundFinished;
  }

  void startNextRound() {
    roundIndex++;
    _resetRound();
  }
}

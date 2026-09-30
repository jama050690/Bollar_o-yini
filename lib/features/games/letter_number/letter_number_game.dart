import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

enum SequenceMode {
  numbers(label: AppStrings.modeNumbers, emoji: '🔢'),
  letters(label: AppStrings.modeLetters, emoji: '🔤');

  const SequenceMode({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

/// Bitta harf yoki raqam. [soundKey] — ovoz fayli nomi (assets/sounds/uz/...).
class SequenceItem {
  const SequenceItem(this.label, this.soundKey);

  final String label;
  final String soundKey;

  @override
  bool operator ==(Object other) => other is SequenceItem && other.label == label;

  @override
  int get hashCode => label.hashCode;
}

/// O'zbek lotin alifbosi (29 harf) — rasmiy tartibda.
const uzbekLetters = [
  SequenceItem('A', 'a'), SequenceItem('B', 'b'), SequenceItem('D', 'd'), //
  SequenceItem('E', 'e'), SequenceItem('F', 'f'), SequenceItem('G', 'g'),
  SequenceItem('H', 'h'), SequenceItem('I', 'i'), SequenceItem('J', 'j'),
  SequenceItem('K', 'k'), SequenceItem('L', 'l'), SequenceItem('M', 'm'),
  SequenceItem('N', 'n'), SequenceItem('O', 'o'), SequenceItem('P', 'p'),
  SequenceItem('Q', 'q'), SequenceItem('R', 'r'), SequenceItem('S', 's'),
  SequenceItem('T', 't'), SequenceItem('U', 'u'), SequenceItem('V', 'v'),
  SequenceItem('X', 'x'), SequenceItem('Y', 'y'), SequenceItem('Z', 'z'),
  SequenceItem('Oʻ', 'o_'), SequenceItem('Gʻ', 'g_'), SequenceItem('Sh', 'sh'),
  SequenceItem('Ch', 'ch'), SequenceItem('Ng', 'ng'),
];

final numbers = [for (var i = 1; i <= 10; i++) SequenceItem('$i', '$i')];

enum TapOutcome { correct, wrong, roundFinished, gameFinished }

/// O'yin mantiqi: har raundda plitkalar aralashtiriladi, bola ularni tartib bilan bosadi.
class LetterNumberGame {
  LetterNumberGame(this.mode, {Random? random}) {
    final rnd = random ?? Random();
    rounds = _buildRounds(mode, rnd);
    tiles = [for (final round in rounds) List.of(round)..shuffle(rnd)];
  }

  static const _letterChunk = 5;
  static const roundCount = 3;

  final SequenceMode mode;
  late final List<List<SequenceItem>> rounds;
  late final List<List<SequenceItem>> tiles;

  int roundIndex = 0;
  int nextIndex = 0;
  int mistakes = 0;

  List<SequenceItem> get currentRound => rounds[roundIndex];
  List<SequenceItem> get currentTiles => tiles[roundIndex];
  SequenceItem get target => currentRound[nextIndex];
  int get stars => starsForMistakes(mistakes);

  bool isDone(SequenceItem item) => currentRound.indexOf(item) < nextIndex;

  /// Raqamlar: 1-5, 1-7, 1-10. Harflar: alifboning ketma-ket 3 bo'lagi (5 tadan).
  static List<List<SequenceItem>> _buildRounds(SequenceMode mode, Random random) {
    if (mode == SequenceMode.numbers) {
      return [numbers.sublist(0, 5), numbers.sublist(0, 7), numbers];
    }
    final chunkCount = uzbekLetters.length ~/ _letterChunk;
    final start = random.nextInt(chunkCount - roundCount + 1);
    return [
      for (var c = start; c < start + roundCount; c++)
        uzbekLetters.sublist(c * _letterChunk, (c + 1) * _letterChunk),
    ];
  }

  TapOutcome tap(SequenceItem item) {
    if (item != target) {
      mistakes++;
      return TapOutcome.wrong;
    }
    nextIndex++;
    if (nextIndex < currentRound.length) return TapOutcome.correct;
    return roundIndex == rounds.length - 1 ? TapOutcome.gameFinished : TapOutcome.roundFinished;
  }

  void startNextRound() {
    roundIndex++;
    nextIndex = 0;
  }
}

import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Juftlik: rasm va unga mos javob (hayvon → ovqati, kasb → asbobi).
class Pair {
  const Pair(this.question, this.answer);

  final String question;
  final String answer;
}

const foodPairs = [
  Pair('🐰', '🥕'),
  Pair('🐒', '🍌'),
  Pair('🐭', '🧀'),
  Pair('🐻', '🍯'),
  Pair('🐶', '🦴'),
  Pair('🐱', '🐟'),
  Pair('🐼', '🎋'),
  Pair('🐿️', '🌰'),
  Pair('🐝', '🌸'),
  Pair('🐄', '🌾'),
];

const toolPairs = [
  Pair('👨‍🍳', '🍳'),
  Pair('👨‍🚒', '🧯'),
  Pair('👩‍⚕️', '💉'),
  Pair('👨‍🌾', '🚜'),
  Pair('👮', '🚓'),
  Pair('🧑‍🎨', '🎨'),
  Pair('👨‍🔧', '🔧'),
  Pair('🧑‍🚀', '🚀'),
  Pair('👩‍🏫', '📚'),
  Pair('🧑‍💻', '💻'),
];

/// Bosqichlar: ① ovqat (3 variant) ② asbob (4 variant) ③ aralash (6 variant).
enum PairsLevel {
  food(label: AppStrings.pairsFood, emoji: '🐰', options: 3),
  tools(label: AppStrings.pairsTools, emoji: '👨‍🍳', options: 4),
  mixed(label: AppStrings.pairsMixed, emoji: '🌈', options: 6);

  const PairsLevel({required this.label, required this.emoji, required this.options});

  final String label;
  final String emoji;
  final int options;

  List<Pair> get pairs => switch (this) {
        PairsLevel.food => foodPairs,
        PairsLevel.tools => toolPairs,
        PairsLevel.mixed => [...foodPairs, ...toolPairs],
      };
}

class PairQuestion {
  const PairQuestion(this.pair, this.options);

  final Pair pair;
  final List<String> options;
}

enum PairOutcome { correct, wrong, finished }

/// 10 ta savol: har birida rasmning jufti variantlar orasidan topiladi.
class MatchPairsGame {
  MatchPairsGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    final all = level.pairs;
    final picked = [...all]..shuffle(rnd);
    questions = [
      for (final pair in picked.take(questionCount))
        PairQuestion(pair, [
          pair.answer,
          ...(all.where((p) => p != pair).map((p) => p.answer).toList()..shuffle(rnd))
              .take(level.options - 1),
        ]..shuffle(rnd)),
    ];
  }

  static const questionCount = 10;

  final PairsLevel level;
  late final List<PairQuestion> questions;
  int step = 0;
  int mistakes = 0;

  PairQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  PairOutcome answer(String option) {
    if (option != current.pair.answer) {
      mistakes++;
      return PairOutcome.wrong;
    }
    step++;
    return isFinished ? PairOutcome.finished : PairOutcome.correct;
  }
}

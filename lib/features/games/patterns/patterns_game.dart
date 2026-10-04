import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Naqshlar uchun rasm to'plamlari (har birida kamida 5 ta rasm).
const patternSymbolSets = [
  ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠'],
  ['🍎', '🍌', '🍇', '🍓', '🍊'],
  ['🐱', '🐶', '🐰', '🐻', '🐸'],
  ['⭐', '❤️', '🔷', '🌙', '☀️'],
];

/// Bosqichlar. [units] — takrorlanuvchi bo'lak shablonlari (0 = A, 1 = B, ...).
enum PatternLevel {
  easy(label: AppStrings.levelEasy, emoji: '🐣', options: 3, units: [
    [0, 1],
  ]),
  medium(label: AppStrings.levelMedium, emoji: '🐥', options: 4, units: [
    [0, 1, 2],
    [0, 0, 1],
    [0, 1, 1],
  ]),
  hard(label: AppStrings.levelHard, emoji: '🦅', options: 4, units: [
    [0, 1, 2, 3],
    [0, 1, 1],
    [0, 0, 1, 1],
    [0, 1, 2, 1],
  ]);

  const PatternLevel({
    required this.label,
    required this.emoji,
    required this.options,
    required this.units,
  });

  final String label;
  final String emoji;
  final int options;
  final List<List<int>> units;
}

class PatternQuestion {
  const PatternQuestion(this.sequence, this.missing, this.options);

  /// To'liq ketma-ketlik (ekranda [missing] o'rnida ❓ turadi).
  final List<String> sequence;
  final int missing;
  final List<String> options;

  String get answer => sequence[missing];
}

enum PatternOutcome { correct, wrong, finished }

/// 10 ta naqsh: bola ❓ o'rniga keladigan rasmni topadi.
class PatternsGame {
  PatternsGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = List.generate(questionCount, (_) => makeQuestion(level, rnd));
  }

  static const questionCount = 10;

  final PatternLevel level;
  late final List<PatternQuestion> questions;
  int step = 0;
  int mistakes = 0;

  PatternQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static PatternQuestion makeQuestion(PatternLevel level, Random rnd) {
    final unit = level.units[rnd.nextInt(level.units.length)];
    final symbols = [...patternSymbolSets[rnd.nextInt(patternSymbolSets.length)]]..shuffle(rnd);
    // Kamida 2 marta takrorlanadi; uzunlik 6–8.
    final length = max(6, min(8, unit.length * 2 + 1));
    final sequence = [for (var i = 0; i < length; i++) symbols[unit[i % unit.length]]];

    // Oson/O'rta: ❓ oxirida. Qiyin: ❓ birinchi to'liq bo'lakdan keyin istalgan joyda.
    final missing = level == PatternLevel.hard
        ? unit.length + rnd.nextInt(length - unit.length)
        : length - 1;

    final answer = sequence[missing];
    final others = symbols.where((s) => s != answer).toList()..shuffle(rnd);
    final options = [answer, ...others.take(level.options - 1)]..shuffle(rnd);
    return PatternQuestion(sequence, missing, options);
  }

  PatternOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return PatternOutcome.wrong;
    }
    step++;
    return isFinished ? PatternOutcome.finished : PatternOutcome.correct;
  }
}

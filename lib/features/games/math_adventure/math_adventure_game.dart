import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Darajalar: sonlar chegarasi 20, 50, 100 gacha.
enum MathLevel {
  upTo20(max: 20, label: AppStrings.levelEasy, emoji: '🐢'),
  upTo50(max: 50, label: AppStrings.levelMedium, emoji: '🐇'),
  upTo100(max: 100, label: AppStrings.levelHard, emoji: '🚀');

  const MathLevel({required this.max, required this.label, required this.emoji});

  final int max;
  final String label;
  final String emoji;
}

class MathQuestion {
  const MathQuestion({
    required this.a,
    required this.b,
    required this.isAddition,
    required this.options,
  });

  final int a;
  final int b;
  final bool isAddition;

  /// 4 ta javob varianti (bittasi to'g'ri), aralashtirilgan.
  final List<int> options;

  int get answer => isAddition ? a + b : a - b;
  String get text => '$a ${isAddition ? '+' : '−'} $b = ?';
}

enum AnswerOutcome { correct, wrong, finished }

/// O'yin mantiqi: 10 ta misol, har to'g'ri javob personajni bir qadam oldinga suradi.
class MathAdventureGame {
  MathAdventureGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = List.generate(questionCount, (_) => _makeQuestion(level.max, rnd));
  }

  static const questionCount = 10;

  final MathLevel level;
  late final List<MathQuestion> questions;

  /// Nechta misol yechildi = personaj yo'ldagi qadami.
  int step = 0;
  int mistakes = 0;

  MathQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static MathQuestion _makeQuestion(int max, Random rnd) {
    final isAddition = rnd.nextBool();
    late int a;
    late int b;
    if (isAddition) {
      // a + b <= max, ikkala son kamida 1.
      a = 1 + rnd.nextInt(max - 1);
      b = 1 + rnd.nextInt(max - a);
    } else {
      // a - b >= 1 — manfiy son yo'q.
      a = 2 + rnd.nextInt(max - 1);
      b = 1 + rnd.nextInt(a - 1);
    }
    final answer = isAddition ? a + b : a - b;

    // To'g'ri javobga yaqin, lekin undan farqli 3 ta variant.
    final options = {answer};
    while (options.length < 4) {
      final offset = rnd.nextInt(10) + 1;
      final candidate = rnd.nextBool() ? answer + offset : answer - offset;
      if (candidate >= 0 && candidate <= max) options.add(candidate);
    }
    return MathQuestion(
      a: a,
      b: b,
      isAddition: isAddition,
      options: options.toList()..shuffle(rnd),
    );
  }

  AnswerOutcome answer(int value) {
    if (value != current.answer) {
      mistakes++;
      return AnswerOutcome.wrong;
    }
    step++;
    return isFinished ? AnswerOutcome.finished : AnswerOutcome.correct;
  }
}

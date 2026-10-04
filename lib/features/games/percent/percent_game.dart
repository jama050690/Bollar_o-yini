import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja: ① 50%, 25%, 10% ② 5% … 75% ③ chegirmadan keyingi narx.
enum PercentLevel {
  easy(label: AppStrings.levelPercentEasy, emoji: '🐣', percents: [50, 25, 10]),
  more(label: AppStrings.levelPercentMore, emoji: '🐥', percents: [5, 20, 30, 40, 60, 75]),
  discount(label: AppStrings.levelDiscount, emoji: '🏷️', percents: [10, 20, 25, 50]);

  const PercentLevel({required this.label, required this.emoji, required this.percents});

  final String label;
  final String emoji;
  final List<int> percents;
}

class PercentQuestion {
  const PercentQuestion(this.number, this.percent, this.isDiscount, this.options);

  /// Son yoki narx (chegirmada ming so'mda).
  final int number;
  final int percent;

  /// true — "narx −p%" dan keyingi yangi narx so'raladi.
  final bool isDiscount;

  final List<int> options;

  int get part => number * percent ~/ 100;
  int get answer => isDiscount ? number - part : part;
}

enum PercentOutcome { correct, wrong, finished }

/// Foizlar: sonning foizini yoki chegirmali narxni topish. 10 ta savol.
class PercentGame {
  PercentGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [for (var i = 0; i < questionCount; i++) makeQuestion(level, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final PercentLevel level;
  late final List<PercentQuestion> questions;
  int step = 0;
  int mistakes = 0;

  PercentQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static PercentQuestion makeQuestion(PercentLevel level, Random rnd) {
    // 20 ga karrali sonlarning barcha tanlangan foizlari butun son chiqadi.
    final number = 20 * (1 + rnd.nextInt(10));
    final percent = level.percents[rnd.nextInt(level.percents.length)];
    final isDiscount = level == PercentLevel.discount;
    final q = PercentQuestion(number, percent, isDiscount, const []);
    final answer = q.answer;
    // Odatiy xatolar: chegirma o'rniga chegirma miqdori, foiz sonini o'zini olish.
    final candidates = <int>{
      if (isDiscount) q.part,
      if (isDiscount) number + q.part,
      if (!isDiscount && percent != answer) percent,
      if (!isDiscount) number - answer,
      answer + 1,
      answer - 1,
      answer + 5,
      answer - 5,
      answer + 10,
    }.where((v) => v > 0 && v != answer).toList()
      ..shuffle(rnd);
    return PercentQuestion(
      number,
      percent,
      isDiscount,
      [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd),
    );
  }

  PercentOutcome answer(int option) {
    if (option != current.answer) {
      mistakes++;
      return PercentOutcome.wrong;
    }
    step++;
    return isFinished ? PercentOutcome.finished : PercentOutcome.correct;
  }
}

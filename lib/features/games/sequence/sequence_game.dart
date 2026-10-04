import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja: ① +k / −k ② ×2, ×3, navbatma-navbat +a −b ③ kvadratlar, o'suvchi farq, Fibonachchi.
enum SequenceLevel {
  plus(label: AppStrings.levelSeqPlus, emoji: '🐣'),
  times(label: AppStrings.levelSeqTimes, emoji: '🐥'),
  tricky(label: AppStrings.levelSeqTricky, emoji: '🦅');

  const SequenceLevel({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

class SequenceQuestion {
  const SequenceQuestion(this.shown, this.answer, this.options);

  /// Ko'rsatiladigan 5 ta son; 6-chisi topiladi.
  final List<int> shown;
  final int answer;
  final List<int> options;
}

enum SequenceOutcome { correct, wrong, finished }

/// Ketma-ketlik: qoidani topib, keyingi sonni aytish. 10 ta savol.
class SequenceGame {
  SequenceGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [for (var i = 0; i < questionCount; i++) makeQuestion(level, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;
  static const shownCount = 5;

  final SequenceLevel level;
  late final List<SequenceQuestion> questions;
  int step = 0;
  int mistakes = 0;

  SequenceQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  /// Darajaga mos 6 ta hadli ketma-ketlik.
  static List<int> _terms(SequenceLevel level, Random rnd) {
    int between(int min, int max) => min + rnd.nextInt(max - min + 1);
    const n = shownCount + 1;

    switch (level) {
      case SequenceLevel.plus:
        final k = between(2, 12);
        if (rnd.nextBool()) {
          final start = between(1, 30);
          return [for (var i = 0; i < n; i++) start + k * i];
        }
        final start = k * (n - 1) + between(1, 30);
        return [for (var i = 0; i < n; i++) start - k * i];
      case SequenceLevel.times:
        switch (rnd.nextInt(3)) {
          case 0:
            final start = between(1, 6);
            return [for (var i = 0; i < n; i++) start * pow(2, i).toInt()];
          case 1:
            final start = between(1, 3);
            return [for (var i = 0; i < n; i++) start * pow(3, i).toInt()];
          default:
            final a = between(3, 9);
            final b = between(1, a - 1);
            final terms = [between(1, 10)];
            while (terms.length < n) {
              terms.add(terms.last + (terms.length.isOdd ? a : -b));
            }
            return terms;
        }
      case SequenceLevel.tricky:
        switch (rnd.nextInt(3)) {
          case 0:
            final first = between(1, 6);
            return [for (var i = 0; i < n; i++) (first + i) * (first + i)];
          case 1:
            var d = between(1, 3);
            final terms = [between(1, 10)];
            while (terms.length < n) {
              terms.add(terms.last + d);
              d++;
            }
            return terms;
          default:
            final terms = [between(1, 5), between(1, 5)];
            while (terms.length < n) {
              terms.add(terms[terms.length - 1] + terms[terms.length - 2]);
            }
            return terms;
        }
    }
  }

  static SequenceQuestion makeQuestion(SequenceLevel level, Random rnd) {
    final terms = _terms(level, rnd);
    final shown = terms.sublist(0, shownCount);
    final answer = terms.last;
    // Odatiy xato: oxirgi farqni yana qo'shib qo'yish.
    final lastDiff = shown[shownCount - 1] - shown[shownCount - 2];
    final candidates = <int>{
      shown.last + lastDiff,
      answer + 1,
      answer - 1,
      answer + 2,
      answer - 2,
      answer + 10,
    }.where((v) => v > 0 && v != answer).toList()
      ..shuffle(rnd);
    return SequenceQuestion(
      shown,
      answer,
      [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd),
    );
  }

  SequenceOutcome answer(int option) {
    if (option != current.answer) {
      mistakes++;
      return SequenceOutcome.wrong;
    }
    step++;
    return isFinished ? SequenceOutcome.finished : SequenceOutcome.correct;
  }
}

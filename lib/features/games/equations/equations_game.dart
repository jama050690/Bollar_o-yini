import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja: ① qo'shish/ayirish ② ko'paytirish/bo'lish ③ ikki amalli tenglama.
enum EquationLevel {
  addSub(label: AppStrings.levelEqAdd, emoji: '🐣'),
  mulDiv(label: AppStrings.levelEqMul, emoji: '🐥'),
  twoStep(label: AppStrings.levelEqTwo, emoji: '🦅');

  const EquationLevel({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

class EquationQuestion {
  const EquationQuestion(this.text, this.answer, this.options);

  /// Masalan: "x + 7 = 15".
  final String text;
  final int answer;

  /// 4 ta musbat variant, bittasi to'g'ri.
  final List<int> options;
}

enum EquationOutcome { correct, wrong, finished }

/// Tenglamalar: noma'lum x ni topish. 10 ta savol.
class EquationsGame {
  EquationsGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [for (var i = 0; i < questionCount; i++) makeQuestion(level, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final EquationLevel level;
  late final List<EquationQuestion> questions;
  int step = 0;
  int mistakes = 0;

  EquationQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static EquationQuestion makeQuestion(EquationLevel level, Random rnd) {
    int between(int min, int max) => min + rnd.nextInt(max - min + 1);

    final String text;
    final int x;

    /// Bola amalni teskari bajarmasa chiqadigan javob (masalan, 15 − 7 o'rniga 15 + 7).
    final int mistake;
    switch (level) {
      case EquationLevel.addSub:
        final a = between(2, 50);
        final c = between(2, 50);
        switch (rnd.nextInt(3)) {
          case 0:
            text = 'x + $a = ${c + a}';
            x = c;
            mistake = c + 2 * a;
          case 1:
            text = 'x − $a = $c';
            x = c + a;
            mistake = (c - a).abs();
          default:
            text = '$a + x = ${c + a}';
            x = c;
            mistake = c + 2 * a;
        }
      case EquationLevel.mulDiv:
        final a = between(2, 9);
        final k = between(2, 12);
        if (rnd.nextBool()) {
          text = '$a · x = ${a * k}';
          x = k;
          mistake = a * k - a;
        } else {
          text = 'x : $a = $k';
          x = a * k;
          mistake = k ~/ a;
        }
      case EquationLevel.twoStep:
        final a = between(2, 9);
        x = between(1, 10);
        final b = between(1, 20);
        if (rnd.nextBool() || a * x <= b) {
          text = '$a · x + $b = ${a * x + b}';
          mistake = (a * x + 2 * b) ~/ a;
        } else {
          text = '$a · x − $b = ${a * x - b}';
          mistake = (a * x - 2 * b) ~/ a;
        }
    }
    return _build(text, x, mistake, rnd);
  }

  static EquationQuestion _build(String text, int answer, int mistake, Random rnd) {
    final candidates = <int>{
      mistake,
      answer + 1,
      answer - 1,
      answer + 2,
      answer - 2,
      answer + 10,
      answer - 10,
    }.where((v) => v > 0 && v != answer).toList()
      ..shuffle(rnd);
    return EquationQuestion(
      text,
      answer,
      [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd),
    );
  }

  EquationOutcome answer(int option) {
    if (option != current.answer) {
      mistakes++;
      return EquationOutcome.wrong;
    }
    step++;
    return isFinished ? EquationOutcome.finished : EquationOutcome.correct;
  }
}

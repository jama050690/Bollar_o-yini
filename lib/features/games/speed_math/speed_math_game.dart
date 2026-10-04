import 'dart:math';

import '../../../core/constants/app_strings.dart';

/// Daraja: ① qo'shish/ayirish (100 gacha) ② karra jadvali va bo'lish ③ aralash.
enum SpeedLevel {
  addSub(label: AppStrings.levelAddSub, emoji: '➕'),
  mulDiv(label: AppStrings.levelMulDiv, emoji: '✖️'),
  mixed(label: AppStrings.levelMixed, emoji: '⚡');

  const SpeedLevel({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

class SpeedQuestion {
  const SpeedQuestion(this.text, this.answer, this.options);

  /// Masalan: "36 + 47".
  final String text;
  final int answer;
  final List<int> options;
}

/// Tez hisob: 60 soniyada iloji boricha ko'p misol yechish.
/// Xato jazolanmaydi — misol javob topilguncha qoladi; yulduz to'g'ri javoblar soniga qarab.
class SpeedMathGame {
  SpeedMathGame(this.level, {Random? random}) : _random = random ?? Random() {
    current = makeQuestion(level, _random);
  }

  static const seconds = 60;
  static const optionCount = 4;

  /// Shuncha to'g'ri javob — 3 yulduz / 2 yulduz.
  static const threeStars = 15;
  static const twoStars = 8;

  final SpeedLevel level;
  final Random _random;
  late SpeedQuestion current;
  int correct = 0;

  int get stars => correct >= threeStars
      ? 3
      : correct >= twoStars
      ? 2
      : 1;

  static SpeedQuestion makeQuestion(SpeedLevel level, Random rnd) {
    int between(int min, int max) => min + rnd.nextInt(max - min + 1);

    final kind = switch (level) {
      SpeedLevel.addSub => rnd.nextInt(2),
      SpeedLevel.mulDiv => 2 + rnd.nextInt(2),
      SpeedLevel.mixed => rnd.nextInt(4),
    };
    final String text;
    final int answer;
    switch (kind) {
      case 0:
        final a = between(10, 60);
        final b = between(5, 39);
        text = '$a + $b';
        answer = a + b;
      case 1:
        final a = between(20, 99);
        final b = between(5, a - 1);
        text = '$a − $b';
        answer = a - b;
      case 2:
        final a = between(2, 10);
        final b = between(2, 10);
        text = '$a × $b';
        answer = a * b;
      default:
        final b = between(2, 10);
        answer = between(2, 10);
        text = '${b * answer} : $b';
    }
    final candidates = <int>{
      answer + 1,
      answer - 1,
      answer + 2,
      answer - 2,
      answer + 10,
      answer - 10,
    }.where((v) => v > 0 && v != answer).toList()..shuffle(rnd);
    return SpeedQuestion(text, answer, [answer, ...candidates.take(optionCount - 1)]..shuffle(rnd));
  }

  /// true — to'g'ri, keyingi misol tayyor.
  bool answer(int option) {
    if (option != current.answer) return false;
    correct++;
    current = makeQuestion(level, _random);
    return true;
  }
}

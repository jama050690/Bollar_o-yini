import 'dart:math';

import '../game_result.dart';

/// Daraja = qaysi songacha ko'paytiriladi (×1–2, ×1–5, ×1–10).
enum TimesLevel {
  upTo2(max: 2, emoji: '🐣'),
  upTo5(max: 5, emoji: '🐥'),
  upTo10(max: 10, emoji: '🦅');

  const TimesLevel({required this.max, required this.emoji});

  final int max;
  final String emoji;
}

class TimesQuestion {
  const TimesQuestion(this.a, this.b, this.options);

  /// a qator, har qatorda b ta narsa.
  final int a;
  final int b;
  final List<int> options;

  int get answer => a * b;
  String get text => '$a × $b = ?';
}

enum TimesOutcome { correct, wrong, finished }

/// Karra jadvali: 10 ta misol, 3 ta javob varianti.
class TimesTableGame {
  TimesTableGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = List.generate(questionCount, (_) => _makeQuestion(rnd));
  }

  static const questionCount = 10;

  final TimesLevel level;
  late final List<TimesQuestion> questions;

  int index = 0;
  int mistakes = 0;

  TimesQuestion get current => questions[index];
  bool get isFinished => index == questionCount;
  int get stars => starsForMistakes(mistakes);

  TimesQuestion _makeQuestion(Random rnd) {
    // Kichkintoylar uchun ikkinchi son ham darajadan oshmaydi (5 yoki 10 gacha),
    // shunda rasm (a x b ta olma) ekranga sig'adi va sanash oson.
    final a = 1 + rnd.nextInt(level.max);
    final b = 1 + rnd.nextInt(max(level.max, 5));
    final answer = a * b;

    // Chalg'ituvchi variantlar: qo'shni ko'paytmalar (masalan 3×4 uchun 3×3 va 3×5).
    final options = {answer};
    final candidates = [a * (b + 1), a * (b - 1), (a + 1) * b, (a - 1) * b, answer + 1, answer + 2]
      ..shuffle(rnd);
    for (final c in candidates) {
      if (options.length == 3) break;
      if (c > 0) options.add(c);
    }
    return TimesQuestion(a, b, options.toList()..shuffle(rnd));
  }

  TimesOutcome answer(int value) {
    if (value != current.answer) {
      mistakes++;
      return TimesOutcome.wrong;
    }
    index++;
    return isFinished ? TimesOutcome.finished : TimesOutcome.correct;
  }
}

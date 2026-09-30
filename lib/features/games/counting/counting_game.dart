import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../../../shared/services/tts_service.dart';
import '../game_result.dart';

enum CountingLanguage {
  uzbek(AppStrings.langUzbek, '🇺🇿', TtsService.uzbek),
  russian(AppStrings.langRussian, '🇷🇺', TtsService.russian);

  const CountingLanguage(this.label, this.flag, this.language);

  final String label;
  final String flag;
  final String language;

  /// 1–100 sonini so'z bilan yozadi (ekranda ko'rsatish va ovoz uchun).
  String words(int n) => switch (this) {
        CountingLanguage.uzbek => uzbekNumber(n),
        CountingLanguage.russian => russianNumber(n),
      };
}

enum CountingLevel {
  upTo10(max: 10, emoji: '🐣'),
  upTo20(max: 20, emoji: '🐥'),
  upTo100(max: 100, emoji: '🦅');

  const CountingLevel({required this.max, required this.emoji});

  final int max;
  final String emoji;
}

const _uzOnes = ['', 'bir', 'ikki', 'uch', 'toʻrt', 'besh', 'olti', 'yetti', 'sakkiz', 'toʻqqiz'];
const _uzTens = [
  '', 'oʻn', 'yigirma', 'oʻttiz', 'qirq', 'ellik', 'oltmish', 'yetmish', 'sakson', 'toʻqson',
];

String uzbekNumber(int n) {
  assert(n >= 1 && n <= 100);
  if (n == 100) return 'yuz';
  final tens = _uzTens[n ~/ 10];
  final ones = _uzOnes[n % 10];
  return [tens, ones].where((s) => s.isNotEmpty).join(' ');
}

const _ruOnes = [
  '', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять',
  'десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать',
  'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать',
];
const _ruTens = [
  '', '', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят',
  'восемьдесят', 'девяносто',
];

String russianNumber(int n) {
  assert(n >= 1 && n <= 100);
  if (n == 100) return 'сто';
  if (n < 20) return _ruOnes[n];
  final ones = _ruOnes[n % 10];
  return [_ruTens[n ~/ 10], ones].where((s) => s.isNotEmpty).join(' ');
}

class CountingQuestion {
  const CountingQuestion(this.number, this.options);

  final int number;
  final List<int> options;
}

enum CountingOutcome { correct, wrong, finished }

/// Sanash o'yini: son aytiladi va so'z bilan yoziladi, bola 4 ta raqamdan topadi.
class CountingGame {
  CountingGame(this.language, this.level, {Random? random}) {
    final rnd = random ?? Random();
    final numbers = (List.generate(level.max, (i) => i + 1)..shuffle(rnd)).take(questionCount);
    questions = [for (final n in numbers) CountingQuestion(n, _options(n, rnd))];
  }

  static const questionCount = 10;

  final CountingLanguage language;
  final CountingLevel level;
  late final List<CountingQuestion> questions;

  int index = 0;
  int mistakes = 0;

  CountingQuestion get current => questions[index];
  bool get isFinished => index == questions.length;
  int get stars => starsForMistakes(mistakes);

  /// To'g'ri son + 3 ta yaqin son (masalan 45 uchun 44, 54, 46) — adashtiruvchi, lekin foydali.
  List<int> _options(int n, Random rnd) {
    final options = {n};
    final near = [n - 1, n + 1, n - 10, n + 10, n - 2, n + 2, n + 5, n - 5]..shuffle(rnd);
    for (final c in near) {
      if (options.length == 4) break;
      if (c >= 1 && c <= level.max) options.add(c);
    }
    while (options.length < 4) {
      options.add(1 + rnd.nextInt(level.max));
    }
    return options.toList()..shuffle(rnd);
  }

  CountingOutcome answer(int value) {
    if (value != current.number) {
      mistakes++;
      return CountingOutcome.wrong;
    }
    index++;
    return isFinished ? CountingOutcome.finished : CountingOutcome.correct;
  }
}

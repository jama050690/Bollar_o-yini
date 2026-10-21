import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../../../shared/services/tts_service.dart';
import '../game_result.dart';

enum CountingLanguage {
  uzbek('🇺🇿', TtsService.uzbek),
  russian('🇷🇺', TtsService.russian),
  korean('🇰🇷', TtsService.korean),
  arabic('🇸🇦', TtsService.arabic);

  const CountingLanguage(this.flag, this.language);

  String get label => switch (this) {
        CountingLanguage.uzbek => AppStrings.langUzbek,
        CountingLanguage.russian => AppStrings.langRussian,
        CountingLanguage.korean => AppStrings.langKorean,
        CountingLanguage.arabic => AppStrings.langArabic,
      };

  final String flag;
  final String language;

  /// 1–100 sonini so'z bilan yozadi (ekranda ko'rsatish va ovoz uchun).
  String words(int n) => switch (this) {
        CountingLanguage.uzbek => uzbekNumber(n),
        CountingLanguage.russian => russianNumber(n),
        CountingLanguage.korean => koreanNumber(n),
        CountingLanguage.arabic => arabicNumber(n),
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

// Sino-koreys sonlar: 21 = 이십일 ("ikki-o'n-bir"), bo'shliqsiz yoziladi.
const _koDigits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];

String koreanNumber(int n) {
  assert(n >= 1 && n <= 100);
  if (n == 100) return '백';
  final tens = n ~/ 10;
  // 10 — "십" (일십 emas), 20 — "이십".
  final tensWord = switch (tens) {
    0 => '',
    1 => '십',
    _ => '${_koDigits[tens]}십',
  };
  return tensWord + _koDigits[n % 10];
}

// Arabcha sonlar (muzakkar shakl). 21 = واحد وعشرون — avval birlik, keyin "va" + o'nlik.
const _arOnes = [
  '', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة',
  'عشرة', 'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر',
  'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر',
];
const _arTens = [
  '', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون', 'سبعون', 'ثمانون', 'تسعون',
];

String arabicNumber(int n) {
  assert(n >= 1 && n <= 100);
  if (n == 100) return 'مئة';
  if (n < 20) return _arOnes[n];
  final tens = _arTens[n ~/ 10];
  final ones = _arOnes[n % 10];
  return ones.isEmpty ? tens : '$ones و$tens';
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

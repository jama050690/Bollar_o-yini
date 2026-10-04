import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Oddiy kasr n/d (pitsaning d bo'lagidan n tasi).
class Fraction {
  const Fraction(this.numerator, this.denominator);

  final int numerator;
  final int denominator;

  double get value => numerator / denominator;

  /// Qiymati teng kasrlar (1/2 va 2/4) — variantlarda birga chiqmasligi uchun.
  bool sameValue(Fraction other) => numerator * other.denominator == other.numerator * denominator;

  @override
  bool operator ==(Object other) =>
      other is Fraction && other.numerator == numerator && other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}

/// Daraja: ① maxraj 2–4, ② maxraj 5–8, ③ ikki kasrni solishtirish.
enum FractionLevel {
  basic(label: AppStrings.fracBasic, emoji: '🍕', minDen: 2, maxDen: 4, compare: false),
  more(label: AppStrings.fracMore, emoji: '🥧', minDen: 5, maxDen: 8, compare: false),
  versus(label: AppStrings.fracCompare, emoji: '⚖️', minDen: 2, maxDen: 8, compare: true);

  const FractionLevel({
    required this.label,
    required this.emoji,
    required this.minDen,
    required this.maxDen,
    required this.compare,
  });

  final String label;
  final String emoji;
  final int minDen;
  final int maxDen;

  /// true — ikki pitsadan kattasini tanlash.
  final bool compare;

  List<Fraction> get fractions => [
    for (var d = minDen; d <= maxDen; d++)
      for (var n = 1; n < d; n++) Fraction(n, d),
  ];
}

class FractionQuestion {
  const FractionQuestion(this.answer, this.options);

  /// Topish kerak bo'lgan kasr (solishtirishda — kattasi).
  final Fraction answer;

  /// Topishda 4 ta variant; solishtirishda 2 ta pitsa.
  final List<Fraction> options;
}

enum FractionOutcome { correct, wrong, finished }

/// Kasrlar: pitsa rasmidan kasrni topish yoki ikki kasrni solishtirish. 10 ta savol.
class FractionsGame {
  FractionsGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = [];
    // Ketma-ket bir xil savol chiqmasin.
    while (questions.length < questionCount) {
      final q = makeQuestion(level, rnd);
      if (questions.isNotEmpty && questions.last.answer == q.answer) continue;
      questions.add(q);
    }
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final FractionLevel level;
  late final List<FractionQuestion> questions;
  int step = 0;
  int mistakes = 0;

  FractionQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static FractionQuestion makeQuestion(FractionLevel level, Random rnd) {
    final pool = level.fractions;
    final answer = pool[rnd.nextInt(pool.length)];
    final n = answer.numerator;
    final d = answer.denominator;

    if (level.compare) {
      // Ikkinchi kasr: ko'pincha maxraji yoki surati bir xil — taqqoslash o'rgatiladi.
      final related = pool
          .where((f) => !f.sameValue(answer) && (f.denominator == d || f.numerator == n))
          .toList();
      final source = related.isNotEmpty && rnd.nextInt(3) > 0
          ? related
          : pool.where((f) => !f.sameValue(answer)).toList();
      final other = source[rnd.nextInt(source.length)];
      final bigger = other.value > answer.value ? other : answer;
      return FractionQuestion(bigger, [answer, other]..shuffle(rnd));
    }

    // Odatiy xatolar: surat ±1 yoki maxraj ±1.
    final near = <Fraction>{
      Fraction(n + 1, d),
      Fraction(n - 1, d),
      Fraction(n, d + 1),
      Fraction(n, d - 1),
      Fraction(d - n, d),
    }.where((f) => f.numerator > 0 && f.numerator < f.denominator).toList()..shuffle(rnd);

    final options = <Fraction>[answer];
    void tryAdd(Fraction f) {
      if (options.length < optionCount && !options.any((o) => o.sameValue(f))) options.add(f);
    }

    near.forEach(tryAdd);
    for (final f in List.of(pool)..shuffle(rnd)) {
      tryAdd(f);
    }
    return FractionQuestion(answer, options..shuffle(rnd));
  }

  FractionOutcome answer(Fraction option) {
    if (option != current.answer) {
      mistakes++;
      return FractionOutcome.wrong;
    }
    step++;
    return isFinished ? FractionOutcome.finished : FractionOutcome.correct;
  }
}

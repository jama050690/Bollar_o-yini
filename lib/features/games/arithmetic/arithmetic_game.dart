import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

enum Operation {
  add('+'),
  subtract('−'),
  multiply('×'),
  divide('÷');

  const Operation(this.symbol);

  final String symbol;
}

/// Darajalar: ① + − ② × ÷ ③ hammasi aralash.
enum ArithmeticLevel {
  addSub(label: AppStrings.levelAddSub, emoji: '🐢', ops: [Operation.add, Operation.subtract]),
  mulDiv(label: AppStrings.levelMulDiv, emoji: '🐇', ops: [Operation.multiply, Operation.divide]),
  mixed(label: AppStrings.levelMixed, emoji: '🚀', ops: Operation.values);

  const ArithmeticLevel({required this.label, required this.emoji, required this.ops});

  final String label;
  final String emoji;
  final List<Operation> ops;
}

class ArithmeticQuestion {
  const ArithmeticQuestion({
    required this.a,
    required this.b,
    required this.op,
    required this.options,
  });

  final int a;
  final int b;
  final Operation op;

  /// 4 ta variant (bittasi to'g'ri), aralashtirilgan.
  final List<int> options;

  int get answer => switch (op) {
        Operation.add => a + b,
        Operation.subtract => a - b,
        Operation.multiply => a * b,
        Operation.divide => a ~/ b,
      };

  String get text => '$a ${op.symbol} $b = ?';
}

enum ArithmeticOutcome { correct, wrong, finished }

/// 10 ta misol. Bo'lish har doim qoldiqsiz, ayirish natijasi manfiy emas.
class ArithmeticGame {
  ArithmeticGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    questions = List.generate(questionCount, (_) => makeQuestion(level, rnd));
  }

  static const questionCount = 10;

  final ArithmeticLevel level;
  late final List<ArithmeticQuestion> questions;
  int step = 0;
  int mistakes = 0;

  ArithmeticQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static ArithmeticQuestion makeQuestion(ArithmeticLevel level, Random rnd) {
    final op = level.ops[rnd.nextInt(level.ops.length)];
    late int a;
    late int b;
    switch (op) {
      case Operation.add:
        a = 1 + rnd.nextInt(99);
        b = 1 + rnd.nextInt(100 - a);
      case Operation.subtract:
        a = 2 + rnd.nextInt(99);
        b = 1 + rnd.nextInt(a - 1);
      case Operation.multiply:
        a = 2 + rnd.nextInt(9);
        b = 2 + rnd.nextInt(9);
      case Operation.divide:
        // (javob × b) ÷ b — qoldiq bo'lmaydi.
        b = 2 + rnd.nextInt(9);
        a = (1 + rnd.nextInt(10)) * b;
    }
    final question = ArithmeticQuestion(a: a, b: b, op: op, options: const []);
    final answer = question.answer;

    final spread = op == Operation.multiply ? a + b : 10;
    final options = {answer};
    while (options.length < 4) {
      final offset = 1 + rnd.nextInt(spread);
      final candidate = rnd.nextBool() ? answer + offset : answer - offset;
      if (candidate >= 0) options.add(candidate);
    }
    return ArithmeticQuestion(a: a, b: b, op: op, options: options.toList()..shuffle(rnd));
  }

  ArithmeticOutcome answer(int value) {
    if (value != current.answer) {
      mistakes++;
      return ArithmeticOutcome.wrong;
    }
    step++;
    return isFinished ? ArithmeticOutcome.finished : ArithmeticOutcome.correct;
  }
}

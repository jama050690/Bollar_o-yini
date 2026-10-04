import 'dart:math';

import 'package:aqlli_dostlar/features/games/equations/equations_game.dart';
import 'package:aqlli_dostlar/features/games/geometry/geometry_game.dart';
import 'package:aqlli_dostlar/features/games/percent/percent_game.dart';
import 'package:aqlli_dostlar/features/games/sequence/sequence_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// Har bir savolda: 4 ta turli musbat variant, bittasi to'g'ri javob.
void expectOptions(List<int> options, int answer) {
  expect(options.length, 4);
  expect(options.toSet().length, 4);
  expect(options.where((o) => o == answer).length, 1);
  expect(options.every((o) => o > 0), isTrue);
}

/// "x + 7 = 15" kabi matndagi x o'rniga javobni qo'yib, tenglikni tekshiradi.
bool solves(String text, int x) {
  final parts = text.replaceAll('x', '$x').split(' = ');
  final right = int.parse(parts[1]);
  final t = parts[0].split(' ');
  int apply(int a, String op, int b) => switch (op) {
    '+' => a + b,
    '−' => a - b,
    '·' => a * b,
    ':' => a % b == 0 ? a ~/ b : -1,
    _ => throw ArgumentError(op),
  };
  var value = apply(int.parse(t[0]), t[1], int.parse(t[2]));
  if (t.length == 5) value = apply(value, t[3], int.parse(t[4]));
  return value == right;
}

void main() {
  group('Tenglamalar', () {
    test('har darajada javob tenglamani qanoatlantiradi', () {
      final rnd = Random(1);
      for (final level in EquationLevel.values) {
        for (var i = 0; i < 300; i++) {
          final q = EquationsGame.makeQuestion(level, rnd);
          expect(solves(q.text, q.answer), isTrue, reason: q.text);
          expectOptions(q.options, q.answer);
        }
      }
    });

    test("10 ta savol, xato yulduzni kamaytiradi", () {
      final game = EquationsGame(EquationLevel.twoStep, random: Random(2));
      expect(game.questions.length, 10);
      final wrong = game.current.options.firstWhere((o) => o != game.current.answer);
      expect(game.answer(wrong), EquationOutcome.wrong);
      for (var i = 0; i < 9; i++) {
        expect(game.answer(game.current.answer), EquationOutcome.correct);
      }
      expect(game.answer(game.current.answer), EquationOutcome.finished);
      expect(game.mistakes, 1);
    });
  });

  group('Ketma-ketlik', () {
    test('5 ta son ko\'rsatiladi, variantlar to\'g\'ri', () {
      final rnd = Random(3);
      for (final level in SequenceLevel.values) {
        for (var i = 0; i < 300; i++) {
          final q = SequenceGame.makeQuestion(level, rnd);
          expect(q.shown.length, 5);
          expect(q.shown.every((n) => n > 0), isTrue);
          expectOptions(q.options, q.answer);
        }
      }
    });

    test('1-daraja: farqi doimiy', () {
      final rnd = Random(4);
      for (var i = 0; i < 100; i++) {
        final q = SequenceGame.makeQuestion(SequenceLevel.plus, rnd);
        final d = q.shown[1] - q.shown[0];
        expect(q.answer - q.shown.last, d);
      }
    });
  });

  group('Geometriya', () {
    test('perimetr va yuz to\'g\'ri hisoblanadi', () {
      const rect = GeometryQuestion(GeoShape.rectangle, GeoAsk.perimeter, 5, 3, []);
      expect(rect.answer, 16);
      const area = GeometryQuestion(GeoShape.square, GeoAsk.area, 4, 4, []);
      expect(area.answer, 16);
      const tri = GeometryQuestion(GeoShape.rightTriangle, GeoAsk.area, 6, 4, []);
      expect(tri.answer, 12);
      const side = GeometryQuestion(GeoShape.rectangle, GeoAsk.missingSide, 6, 4, []);
      expect(side.area, 24);
      expect(side.answer, 4);
    });

    test('darajalar mos savol beradi', () {
      final rnd = Random(5);
      for (final level in GeometryLevel.values) {
        for (var i = 0; i < 300; i++) {
          final q = GeometryGame.makeQuestion(level, rnd);
          expectOptions(q.options, q.answer);
          if (q.shape == GeoShape.square) expect(q.width, q.height);
          if (q.shape == GeoShape.rectangle) expect(q.width, isNot(q.height));
          if (q.shape == GeoShape.rightTriangle) expect((q.width * q.height).isEven, isTrue);
          switch (level) {
            case GeometryLevel.perimeter:
              expect(q.ask, GeoAsk.perimeter);
            case GeometryLevel.area:
              expect(q.ask, GeoAsk.area);
            case GeometryLevel.mix:
              expect(q.shape == GeoShape.rightTriangle || q.ask == GeoAsk.missingSide, isTrue);
          }
        }
      }
    });
  });

  group('Foizlar', () {
    test('foiz va chegirma hisobi', () {
      const q = PercentQuestion(80, 25, false, []);
      expect(q.answer, 20);
      const d = PercentQuestion(120, 10, true, []);
      expect(d.answer, 108);
    });

    test('har doim butun javob va to\'g\'ri variantlar', () {
      final rnd = Random(6);
      for (final level in PercentLevel.values) {
        for (var i = 0; i < 300; i++) {
          final q = PercentGame.makeQuestion(level, rnd);
          expect(q.number * q.percent % 100, 0);
          expect(level.percents, contains(q.percent));
          expect(q.isDiscount, level == PercentLevel.discount);
          expectOptions(q.options, q.answer);
        }
      }
    });
  });
}

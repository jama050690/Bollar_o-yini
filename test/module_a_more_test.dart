import 'dart:math';

import 'package:aqlli_dostlar/features/games/match_pairs/match_pairs_game.dart';
import 'package:aqlli_dostlar/features/games/patterns/patterns_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Juftini top', () {
    test('juftliklar: savol va javoblar takrorsiz', () {
      final all = [...foodPairs, ...toolPairs];
      expect(all.map((p) => p.question).toSet().length, all.length);
      expect(all.map((p) => p.answer).toSet().length, all.length);
    });

    test("har bosqichda 10 ta takrorlanmas savol, variantlar soni to'g'ri", () {
      for (final level in PairsLevel.values) {
        final game = MatchPairsGame(level, random: Random(level.index));
        expect(game.questions.map((q) => q.pair).toSet().length, MatchPairsGame.questionCount);
        for (final q in game.questions) {
          expect(q.options.length, level.options);
          expect(q.options.toSet().length, level.options);
          expect(q.options, contains(q.pair.answer));
          expect(level.pairs, contains(q.pair));
        }
      }
    });

    test("noto'g'ri javob — xato; to'g'rilari bilan tugaydi", () {
      final game = MatchPairsGame(PairsLevel.mixed, random: Random(2));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.pair.answer)), PairOutcome.wrong);
      expect(game.current, same(q));
      PairOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.pair.answer);
      }
      expect(last, PairOutcome.finished);
      expect(game.stars, 3);
    });
  });

  group('Naqsh', () {
    test("ketma-ketlik shablonga mos, ❓ o'rni va variantlar to'g'ri", () {
      final rnd = Random(1);
      for (final level in PatternLevel.values) {
        for (var k = 0; k < 200; k++) {
          final q = PatternsGame.makeQuestion(level, rnd);
          expect(q.sequence.length, inInclusiveRange(6, 8));
          expect(q.options.length, level.options);
          expect(q.options.toSet().length, level.options);
          expect(q.options, contains(q.answer));
          if (level != PatternLevel.hard) expect(q.missing, q.sequence.length - 1);
          expect(q.missing, greaterThanOrEqualTo(2));
          // Naqsh haqiqatan takrorlanadi: kamida bitta shablon butun qatorni tushuntiradi.
          final explained = level.units.any((unit) {
            final map = <int, String>{};
            for (var i = 0; i < q.sequence.length; i++) {
              final key = unit[i % unit.length];
              if ((map[key] ??= q.sequence[i]) != q.sequence[i]) return false;
            }
            return map.values.toSet().length == map.length;
          });
          expect(explained, isTrue);
        }
      }
    });

    test("noto'g'ri javob — xato; 10 ta to'g'ri — tugaydi", () {
      final game = PatternsGame(PatternLevel.hard, random: Random(4));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), PatternOutcome.wrong);
      expect(game.mistakes, 1);
      PatternOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, PatternOutcome.finished);
      expect(game.stars, 3);
    });
  });
}

import 'dart:math';

import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/features/games/game_result.dart';
import 'package:aqlli_dostlar/features/games/letter_number/letter_number_game.dart';
import 'package:aqlli_dostlar/features/games/memory_match/memory_game.dart';
import 'package:aqlli_dostlar/features/games/shape_sorter/shape_sorter_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeGroup (FR-2)', () {
    test('yoshga qarab modul tanlanadi', () {
      expect(AgeGroup.fromAge(5), AgeGroup.a);
      expect(AgeGroup.fromAge(7), AgeGroup.a);
      expect(AgeGroup.fromAge(8), AgeGroup.b);
      expect(AgeGroup.fromAge(9), AgeGroup.b);
      expect(AgeGroup.fromAge(10), AgeGroup.c);
      expect(AgeGroup.fromAge(12), AgeGroup.c);
    });
  });

  group('starsForMistakes', () {
    test('kamida 1 yulduz beriladi', () {
      expect(starsForMistakes(0), 3);
      expect(starsForMistakes(1), 3);
      expect(starsForMistakes(3), 2);
      expect(starsForMistakes(100), 1);
    });
  });

  group('MemoryGame', () {
    for (final d in MemoryDifficulty.values) {
      test('${d.name}: ${d.columns}x${d.rows} — har bir belgi aynan 2 marta', () {
        final game = MemoryGame(d, random: Random(1));
        expect(game.cards.length, d.columns * d.rows);
        final counts = <String, int>{};
        for (final c in game.cards) {
          counts[c.symbol] = (counts[c.symbol] ?? 0) + 1;
        }
        expect(counts.values.every((n) => n == 2), isTrue);
      });
    }

    test("juftlik topilsa ochiq qoladi, topilmasa yopiladi", () {
      final game = MemoryGame(MemoryDifficulty.easy, random: Random(2));
      final first = game.cards[0].symbol;
      final pair = game.cards.indexWhere((c) => c.symbol == first, 1);
      final other = game.cards.indexWhere((c) => c.symbol != first);

      expect(game.flip(0), FlipOutcome.firstFlipped);
      expect(game.flip(other), FlipOutcome.mismatched);
      // Kutish paytida boshqa karta bosilmaydi.
      expect(game.flip(pair), FlipOutcome.ignored);
      game.hideMismatched();
      expect(game.cards[0].isFaceUp, isFalse);

      game.flip(0);
      expect(game.flip(pair), FlipOutcome.matched);
      expect(game.cards[0].isMatched && game.cards[pair].isMatched, isTrue);
      expect(game.mismatches, 1);
    });

    test("barcha juftliklar topilsa o'yin tugaydi va 3 yulduz", () {
      final game = MemoryGame(MemoryDifficulty.easy, random: Random(3));
      for (var i = 0; i < game.cards.length; i++) {
        if (game.cards[i].isMatched) continue;
        final pair = game.cards.indexWhere(
          (c) => c.symbol == game.cards[i].symbol && !identical(c, game.cards[i]),
        );
        game.flip(i);
        game.flip(pair);
      }
      expect(game.isFinished, isTrue);
      expect(game.stars, 3);
    });
  });

  group('LetterNumberGame', () {
    test("raqamlar: 3 raund, to'g'ri tartibda bosilsa tugaydi", () {
      final game = LetterNumberGame(SequenceMode.numbers, random: Random(4));
      expect(game.rounds.map((r) => r.length), [5, 7, 10]);

      TapOutcome? last;
      for (var r = 0; r < game.rounds.length; r++) {
        for (final item in List.of(game.currentRound)) {
          last = game.tap(item);
        }
        if (last == TapOutcome.roundFinished) game.startNextRound();
      }
      expect(last, TapOutcome.gameFinished);
      expect(game.stars, 3);
    });

    test("noto'g'ri bosish xato hisoblanadi, lekin o'yin davom etadi", () {
      final game = LetterNumberGame(SequenceMode.letters, random: Random(5));
      final wrong = game.currentRound[1];
      expect(game.tap(wrong), TapOutcome.wrong);
      expect(game.mistakes, 1);
      expect(game.tap(game.currentRound[0]), TapOutcome.correct);
    });

    test("harflar alifbo tartibida ketma-ket", () {
      final game = LetterNumberGame(SequenceMode.letters, random: Random(6));
      for (final round in game.rounds) {
        final start = uzbekLetters.indexOf(round.first);
        expect(round, uzbekLetters.sublist(start, start + round.length));
      }
    });
  });

  group('ShapeSorterGame', () {
    test("to'g'ri savatga tashlasa qabul qilinadi, noto'g'ri bo'lsa qaytadi", () {
      final game = ShapeSorterGame(random: Random(7));
      final toy = game.remaining.first;
      final rightBin = game.currentRound.bins.indexWhere((b) => b.accepts(toy));
      final wrongBin = game.currentRound.bins.indexWhere((b) => !b.accepts(toy));

      expect(game.drop(toy, wrongBin), DropOutcome.wrong);
      expect(game.remaining, contains(toy));
      game.drop(toy, rightBin);
      expect(game.remaining, isNot(contains(toy)));
    });

    test("3 raund: rang, rang, shakl — hammasi saralansa tugaydi", () {
      final game = ShapeSorterGame(random: Random(8));
      expect(game.rounds.map((r) => r.sortBy), [SortBy.color, SortBy.color, SortBy.shape]);

      DropOutcome? last;
      for (var r = 0; r < game.rounds.length; r++) {
        for (final toy in List.of(game.remaining)) {
          last = game.drop(toy, game.currentRound.bins.indexWhere((b) => b.accepts(toy)));
        }
        if (last == DropOutcome.roundFinished) game.startNextRound();
      }
      expect(last, DropOutcome.gameFinished);
      expect(game.stars, 3);
    });
  });
}

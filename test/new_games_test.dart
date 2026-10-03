import 'dart:math';

import 'package:aqlli_dostlar/features/games/arithmetic/arithmetic_game.dart';
import 'package:aqlli_dostlar/features/games/coloring/coloring_game.dart';
import 'package:aqlli_dostlar/features/games/coloring/coloring_pictures.dart';
import 'package:aqlli_dostlar/features/games/crossword/crossword_game.dart';
import 'package:aqlli_dostlar/features/games/translate/translate_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Rasm bo'yash", () {
    test('10 ta rasm, 12 ta rang', () {
      expect(coloringPictures.length, 10);
      expect(coloringPalette.toSet().length, 12);
    });

    test("har bo'lakni bosib bo'yash mumkin (ko'rinadigan joyi bor)", () {
      for (final build in coloringPictures) {
        final picture = build();
        final game = ColoringGame(picture);
        // 100×100 to'rdagi nuqtalar bilan har bo'lakka tegib ko'ramiz.
        final reached = <int>{};
        for (var y = 0.5; y < 100; y += 1) {
          for (var x = 0.5; x < 100; x += 1) {
            final i = game.regionAt(Offset(x, y));
            if (i != null) reached.add(i);
          }
        }
        expect(reached.length, picture.regions.length, reason: picture.name);
      }
    });

    test("hamma bo'lak bo'yalgach tugaydi; tozalash qayta boshlaydi", () {
      final picture = coloringPictures[8](); // yulduz
      final game = ColoringGame(picture);
      expect(game.tap(const Offset(1, 1)), ColoringOutcome.none);

      final points = <int, Offset>{};
      for (var y = 0.5; y < 100; y += 1) {
        for (var x = 0.5; x < 100; x += 1) {
          final i = game.regionAt(Offset(x, y));
          if (i != null) points.putIfAbsent(i, () => Offset(x, y));
        }
      }
      ColoringOutcome? last;
      for (final p in points.values) {
        last = game.tap(p);
      }
      expect(last, ColoringOutcome.finished);
      expect(game.isComplete, isTrue);

      game.clear();
      expect(game.isComplete, isFalse);
      expect(game.colors.every((c) => c == null), isTrue);
    });
  });

  group('Mini-krossvord', () {
    test("oʻ, sh, ch bitta katak", () {
      expect(splitCrosswordLetters('toʻp'), ['t', 'oʻ', 'p']);
      expect(splitCrosswordLetters('toshbaqa'), ['t', 'o', 'sh', 'b', 'a', 'q', 'a']);
      expect(splitCrosswordLetters('choy'), ['ch', 'o', 'y']);
    });

    test("so'zlar banki: 40+ ta, takrorsiz", () {
      expect(crosswordBank.length, greaterThanOrEqualTo(40));
      expect(crosswordBank.map((e) => e.word).toSet().length, crosswordBank.length);
      expect(crosswordBank.map((e) => e.emoji).toSet().length, crosswordBank.length);
    });

    test("har darajada kerakli so'z soni joylashadi va kataklar mos keladi", () {
      for (final level in CrosswordLevel.values) {
        for (var seed = 0; seed < 30; seed++) {
          final puzzle = CrosswordGenerator(Random(seed)).generate(level.words);
          expect(puzzle.words.length, level.words, reason: '$level seed=$seed');
          expect(puzzle.words.map((w) => w.entry.word).toSet().length, level.words);

          // Har bir katakdagi harf shu katakdan o'tuvchi hamma so'zga mos.
          for (final w in puzzle.words) {
            final cells = w.cells;
            for (var i = 0; i < cells.length; i++) {
              expect(puzzle.solution[cells[i]], w.letters[i]);
              expect(cells[i].$1, greaterThanOrEqualTo(0));
              expect(cells[i].$2, greaterThanOrEqualTo(0));
            }
          }
          // Har so'z kamida bitta boshqa so'zni kesib o'tadi (bog'langan).
          for (final w in puzzle.words) {
            final crosses = puzzle.words
                .where((o) => o != w)
                .any((o) => o.cells.toSet().intersection(w.cells.toSet()).isNotEmpty);
            expect(crosses, isTrue);
          }
        }
      }
    });

    test("noto'g'ri harf — xato, to'g'ri harflar bilan krossvord tugaydi", () {
      final game = CrosswordGame(CrosswordLevel.medium, random: Random(3));
      expect(game.tiles.length, greaterThanOrEqualTo(CrosswordGame.tileCount));
      for (final letter in game.selectedWord.letters) {
        expect(game.tiles, contains(letter));
      }

      final right = game.puzzle.solution[game.cursor]!;
      final wrong = game.tiles.firstWhere((t) => t != right);
      expect(game.tapLetter(wrong), CrosswordOutcome.wrong);
      expect(game.mistakes, 1);

      CrosswordOutcome? last;
      while (!game.isFinished) {
        if (game.isWordDone(game.selected)) game.selectNextOpen();
        last = game.tapLetter(game.puzzle.solution[game.cursor]!);
      }
      expect(last, CrosswordOutcome.gameFinished);
      expect(game.stars, 3);
    });
  });

  group('Arifmetika', () {
    test("darajaga mos amallar, qoldiqsiz bo'lish, manfiy yo'q, 4 xil variant", () {
      final rnd = Random(1);
      for (final level in ArithmeticLevel.values) {
        for (var k = 0; k < 300; k++) {
          final q = ArithmeticGame.makeQuestion(level, rnd);
          expect(level.ops, contains(q.op));
          expect(q.answer, greaterThanOrEqualTo(0));
          if (q.op == Operation.divide) expect(q.a % q.b, 0);
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.answer));
          expect(q.options.every((o) => o >= 0), isTrue);
        }
      }
    });

    test("noto'g'ri javob — xato; 10 ta to'g'ri — tugaydi", () {
      final game = ArithmeticGame(ArithmeticLevel.mixed, random: Random(5));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.answer)), ArithmeticOutcome.wrong);
      expect(game.current, same(q));
      ArithmeticOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.answer);
      }
      expect(last, ArithmeticOutcome.finished);
      expect(game.stars, 3);
    });
  });

  group('Tarjimon', () {
    test("30 ta so'z, tarjimalar takrorsiz", () {
      expect(translateWords.length, 30);
      for (final language in TargetLanguage.values) {
        expect(translateWords.map((w) => w.translation(language)).toSet().length, 30);
      }
    });

    test("10 ta takrorlanmas savol, 4 xil variant, to'g'risi ichida", () {
      for (final language in TargetLanguage.values) {
        final game = TranslateGame(language, random: Random(language.index));
        expect(game.questions.map((q) => q.word).toSet().length, TranslateGame.questionCount);
        for (final q in game.questions) {
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.word.translation(language)));
        }
      }
    });

    test("noto'g'ri tarjima — xato, to'g'rilari bilan tugaydi", () {
      final game = TranslateGame(TargetLanguage.english, random: Random(7));
      final q = game.current;
      expect(game.answer(q.options.firstWhere((o) => o != q.word.english)), TranslateOutcome.wrong);
      TranslateOutcome? last;
      while (!game.isFinished) {
        last = game.answer(game.current.word.english);
      }
      expect(last, TranslateOutcome.finished);
      expect(game.mistakes, 1);
    });
  });
}

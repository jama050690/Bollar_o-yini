import 'dart:collection';
import 'dart:math';

import 'package:aqlli_dostlar/features/games/math_adventure/math_adventure_game.dart';
import 'package:aqlli_dostlar/features/games/maze_quiz/maze_quiz_data.dart';
import 'package:aqlli_dostlar/features/games/maze_quiz/maze_quiz_game.dart';
import 'package:aqlli_dostlar/features/games/mini_sudoku/mini_sudoku_game.dart';
import 'package:aqlli_dostlar/features/games/word_builder/word_builder_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Matematik sarguzasht', () {
    test("misollar chegaradan chiqmaydi, manfiy javob yo'q, 4 xil variant", () {
      for (final level in MathLevel.values) {
        final game = MathAdventureGame(level, random: Random(level.index));
        for (final q in game.questions) {
          expect(q.answer, inInclusiveRange(1, level.max));
          expect(q.options.toSet().length, 4);
          expect(q.options, contains(q.answer));
        }
      }
    });

    test("noto'g'ri javob — o'sha savol qoladi, to'g'ri javob — qadam oldinga", () {
      final game = MathAdventureGame(MathLevel.upTo20, random: Random(1));
      final q = game.current;
      final wrong = q.options.firstWhere((o) => o != q.answer);
      expect(game.answer(wrong), AnswerOutcome.wrong);
      expect(game.current, same(q));
      expect(game.step, 0);

      for (var i = 0; i < MathAdventureGame.questionCount - 1; i++) {
        expect(game.answer(game.current.answer), AnswerOutcome.correct);
      }
      expect(game.answer(game.current.answer), AnswerOutcome.finished);
      expect(game.mistakes, 1);
      expect(game.stars, 3);
    });
  });

  group("So'z quramchisi", () {
    test("sh, ch, oʻ, gʻ bitta harf hisoblanadi", () {
      expect(splitUzbekLetters('mushuk'), ['m', 'u', 'sh', 'u', 'k']);
      expect(splitUzbekLetters('choy'), ['ch', 'o', 'y']);
      expect(splitUzbekLetters('oʻrdak'), ['oʻ', 'r', 'd', 'a', 'k']);
      expect(splitUzbekLetters('gʻoz'), ['gʻ', 'o', 'z']);
    });

    test("so'zlar bazasi: 40+ so'z, 3-9 harf, har darajada kamida 8 ta", () {
      expect(wordBank.length, greaterThanOrEqualTo(40));
      expect(wordBank.map((e) => e.word).toSet().length, wordBank.length);
      for (final entry in wordBank) {
        expect(entry.letters.length, inInclusiveRange(3, 9), reason: entry.word);
        expect(WordLevel.values.where((l) => l.fits(entry)).length, 1, reason: entry.word);
      }
      for (final level in WordLevel.values) {
        expect(
          wordBank.where(level.fits).length,
          greaterThanOrEqualTo(WordBuilderGame.wordCount),
          reason: level.name,
        );
      }
    });

    test("har darajada so'zlar harf soniga mos", () {
      for (final level in WordLevel.values) {
        final game = WordBuilderGame(level, random: Random(level.index));
        expect(game.words.length, WordBuilderGame.wordCount);
        for (final w in game.words) {
          expect(w.letters.length, inInclusiveRange(level.minLetters, level.maxLetters));
        }
      }
    });

    test("8 ta so'zni to'g'ri yig'ib o'yin tugaydi", () {
      final game = WordBuilderGame(WordLevel.long, random: Random(3));
      expect(game.words.length, WordBuilderGame.wordCount);

      LetterOutcome? last;
      for (var w = 0; w < WordBuilderGame.wordCount; w++) {
        final letters = game.currentLetters;
        for (var i = 0; i < letters.length; i++) {
          final tile = List.generate(game.tiles.length, (j) => j)
              .firstWhere((j) => !game.usedTiles.contains(j) && game.tiles[j] == letters[i]);
          last = game.tapTile(tile);
        }
        if (last == LetterOutcome.wordFinished) game.nextWord();
      }
      expect(last, LetterOutcome.gameFinished);
      expect(game.mistakes, 0);
    });

    test("noto'g'ri harf xato hisoblanadi", () {
      final game = WordBuilderGame(WordLevel.medium, random: Random(5));
      final expected = game.currentLetters.first;
      final wrongIndex = game.tiles.indexWhere((t) => t != expected);
      expect(game.tapTile(wrongIndex), LetterOutcome.wrong);
      expect(game.mistakes, 1);
      expect(game.placed, 0);
    });
  });

  group('Labirint-kviz', () {
    test("har darajada 2 ta labirint, o'lcham to'g'ri, chiqishga faqat eshiklar orqali", () {
      for (final level in MazeLevel.values) {
        expect(level.maps.length, 2);
        for (final map in [...level.maps, if (level == MazeLevel.medium) ...mazeMaps]) {
          final maze = Maze.parse(map);
          expect(maze.size, level.size);
          expect(map.every((row) => row.length == level.size), isTrue);
          expect(maze.doorCount, greaterThan(0));
          expect(_reachable(maze, throughDoors: true), isTrue);
          expect(_reachable(maze, throughDoors: false), isFalse);
        }
        expect(MazeQuizGame(level: level).mazeCount, 2);
      }
    });

    test('savollar: 20+, javob indeksi to\'g\'ri', () {
      expect(quizQuestions.length, greaterThanOrEqualTo(20));
      for (final q in quizQuestions) {
        expect(q.options.length, 3);
        expect(q.answerIndex, inInclusiveRange(0, 2));
      }
    });

    test("devorga yurib bo'lmaydi, eshikda savol chiqadi", () {
      final game = MazeQuizGame(random: Random(1), maps: mazeMaps);
      expect(game.move(Direction.up), MoveOutcome.blocked);
      expect(game.player, game.maze.start);

      // 1-labirint: S → o'ngga 3 → pastga 2 → o'ngda eshik.
      for (var i = 0; i < 3; i++) {
        expect(game.move(Direction.right), MoveOutcome.moved);
      }
      expect(game.move(Direction.down), MoveOutcome.moved);
      expect(game.move(Direction.down), MoveOutcome.moved);
      expect(game.move(Direction.right), MoveOutcome.question);
      expect(game.move(Direction.left), MoveOutcome.blocked, reason: 'savol ochiq');

      final q = game.pendingQuestion!;
      expect(game.answer((q.answerIndex + 1) % 3), QuizOutcome.wrong);
      expect(game.mistakes, 1);
      expect(game.answer(q.answerIndex), QuizOutcome.correct);
      expect(game.player, const Pos(2, 4));
      expect(game.pendingQuestion, isNull);
    });
  });

  group('Mini-Sudoku', () {
    test("8 ta sehrli kvadrat, hammasida qator/ustun/diagonal = 15", () {
      expect(magicSquares.length, 8);
      expect(magicSquares.map((s) => s.join()).toSet().length, 8);
      for (final s in magicSquares) {
        expect(s.toSet(), {1, 2, 3, 4, 5, 6, 7, 8, 9});
        for (var i = 0; i < 3; i++) {
          expect(s[i * 3] + s[i * 3 + 1] + s[i * 3 + 2], 15);
          expect(s[i] + s[i + 3] + s[i + 6], 15);
        }
        expect(s[0] + s[4] + s[8], 15);
        expect(s[2] + s[4] + s[6], 15);
      }
    });

    test("daraja bo'yicha bo'sh kataklar soni", () {
      for (final level in SudokuLevel.values) {
        final game = MiniSudokuGame(level, random: Random(level.index));
        expect(game.cells.where((c) => c == null).length, level.empty);
        expect(game.givens.length, 9 - level.empty);
      }
    });

    test("noto'g'ri raqam xato, to'g'ri raqamlar bilan 3 boshqotirma tugaydi", () {
      final game = MiniSudokuGame(SudokuLevel.hard, random: Random(7));
      PlaceOutcome? last;
      var checkedWrong = false;

      for (var p = 0; p < MiniSudokuGame.puzzleCount; p++) {
        while (!game.isPuzzleComplete) {
          final cell = game.cells.indexOf(null);
          if (!checkedWrong) {
            final wrong = List.generate(9, (i) => i + 1).firstWhere((v) => !game.isValid(cell, v));
            expect(game.place(cell, wrong), PlaceOutcome.wrong);
            checkedWrong = true;
          }
          final value = List.generate(9, (i) => i + 1).firstWhere((v) => game.isValid(cell, v));
          last = game.place(cell, value);
        }
        if (last == PlaceOutcome.puzzleFinished) game.nextPuzzle();
      }
      expect(last, PlaceOutcome.gameFinished);
      expect(game.mistakes, 1);
      expect(game.stars, 3);
    });
  });
}

/// BFS: boshlanishdan chiqishga yo'l bormi.
bool _reachable(Maze maze, {required bool throughDoors}) {
  final seen = {maze.start};
  final queue = Queue.of([maze.start]);
  while (queue.isNotEmpty) {
    final p = queue.removeFirst();
    if (maze.at(p) == Cell.exit) return true;
    for (final d in Direction.values) {
      final next = p.move(d);
      final cell = maze.at(next);
      if (cell == Cell.wall || (cell == Cell.door && !throughDoors)) continue;
      if (seen.add(next)) queue.add(next);
    }
  }
  return false;
}

import 'package:aqlli_dostlar/features/games/block_coding/block_coding_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dasturni matndan yozadi: F — oldinga, L — chapga, R — o'ngga, 2..5 — 🔁 shuncha marta.
/// [body] — takrorlanadigan qism.
void _write(BlockCodingGame game, String main, [String body = '']) {
  game.clear();
  void addAll(String code) {
    for (final ch in code.split('')) {
      final digit = int.tryParse(ch);
      if (digit != null) {
        expect(game.add(BlockType.loop), isTrue, reason: 'loop: $code');
        final index = game.program.length - 1;
        while (game.program[index].count != digit) {
          game.cycleLoopCount(index);
        }
        continue;
      }
      final type = switch (ch) {
        'F' => BlockType.forward,
        'L' => BlockType.left,
        _ => BlockType.right,
      };
      expect(game.add(type), isTrue, reason: 'blok: $code');
    }
  }

  addAll(main);
  game.editingLoop = true;
  addAll(body);
  game.editingLoop = false;
}

/// Har bir topshiriq uchun namunaviy yechim (asosiy dastur, takrorlash ichi).
const _solutions = {
  CodingLevel.easy: [
    ('FFF', ''),
    ('FFFLFF', ''),
    ('FRFLFFLF', ''),
    ('LFFFLFFFFLFFF', ''),
  ],
  CodingLevel.medium: [
    ('FRFFLFFFLFF', ''),
    ('FFLFFFFFRFFRFF', ''),
    ('LFFFFRFFFFFRFFRFFF', ''),
    ('FFFFFRFFFRFFRFLFFLFFFLFFFF', ''),
  ],
  CodingLevel.hard: [
    ('5', 'F'),
    ('3', 'FFFR'),
    ('4', 'FLFR'),
    ('2', 'FFLFFR'),
  ],
};

void main() {
  group('Robot dasturchi', () {
    test("har darajada 4 ta topshiriq, hammasi yechiladi va bloklar chegarasiga sig'adi", () {
      for (final level in CodingLevel.values) {
        final game = BlockCodingGame(level: level);
        expect(game.puzzleCount, 4);
        for (var i = 0; i < game.puzzleCount; i++) {
          final (main, body) = _solutions[level]![i];
          _write(game, main, body);
          final limit = game.puzzle.maxBlocks;
          if (limit != null) expect(game.usedBlocks, lessThanOrEqualTo(limit));
          final result = game.run();
          expect(result.outcome, RunOutcome.success, reason: '${level.name} #${i + 1}');
          expect(result.trace.last.pos, game.puzzle.goal);
          game.nextPuzzle();
        }
        expect(game.mistakes, 0);
        expect(game.stars, 3);
      }
    });

    test("faqat qiyin darajada bloklar cheklangan va 🔁 bor", () {
      for (final level in CodingLevel.values) {
        final game = BlockCodingGame(level: level);
        expect(game.canAdd(BlockType.loop), level == CodingLevel.hard);
        expect(game.puzzle.maxBlocks == null, level != CodingLevel.hard);
      }
    });

    test("to'siqqa urilish — xato, dastur o'chmaydi", () {
      final game = BlockCodingGame(level: CodingLevel.easy)..puzzleIndex = 2;
      _write(game, 'FF'); // (2,2) da to'siq
      final result = game.run();
      expect(result.outcome, RunOutcome.crashed);
      expect(game.mistakes, 1);
      expect(game.program.length, 2);
      expect(result.trace.last.pos, const Pos(2, 1));
    });

    test("maydondan chiqib ketish ham to'siq hisoblanadi", () {
      final game = BlockCodingGame(level: CodingLevel.easy)..puzzleIndex = 3;
      _write(game, 'F'); // robot pastga qaragan, pastki chekkada
      expect(game.run().outcome, RunOutcome.crashed);
    });

    test("yetib bormaslik — xato, bo'sh dastur — xato emas", () {
      final game = BlockCodingGame(level: CodingLevel.easy);
      expect(game.run().outcome, RunOutcome.empty);
      expect(game.mistakes, 0);
      _write(game, 'F');
      expect(game.run().outcome, RunOutcome.notReached);
      expect(game.mistakes, 1);
    });

    test('maqsadga yetganda robot darhol to\'xtaydi', () {
      final game = BlockCodingGame(level: CodingLevel.easy);
      _write(game, 'FFFFF'); // 4- va 5-buyruq kerak emas, chekkaga urilmaydi
      final result = game.run();
      expect(result.outcome, RunOutcome.success);
      expect(result.trace.length, 4);
    });

    test('burilish robotning o\'ziga nisbatan', () {
      expect(Heading.north.turnLeft, Heading.west);
      expect(Heading.north.turnRight, Heading.east);
      expect(Heading.south.turnLeft, Heading.east);
      expect(Heading.west.turnRight, Heading.north);
    });

    test("bloklar chegarasi va 🔁 ichida 🔁 yo'q", () {
      final game = BlockCodingGame(level: CodingLevel.hard); // chegara: 3
      expect(game.add(BlockType.forward), isTrue);
      expect(game.add(BlockType.loop), isTrue);
      game.editingLoop = true;
      expect(game.canAdd(BlockType.loop), isFalse);
      expect(game.add(BlockType.forward), isTrue);
      expect(game.add(BlockType.forward), isFalse);
      expect(game.usedBlocks, 3);
      game.removeLast();
      expect(game.loopBody, isEmpty);
    });

    test('🔁 soni 2 → 5 oralig\'ida aylanadi va dastur yoyiladi', () {
      final game = BlockCodingGame(level: CodingLevel.hard);
      _write(game, '2', 'FR');
      expect(game.compile(), [
        BlockType.forward,
        BlockType.right,
        BlockType.forward,
        BlockType.right,
      ]);
      for (var i = 0; i < 3; i++) {
        game.cycleLoopCount(0);
      }
      expect(game.program.first.count, 5);
      game.cycleLoopCount(0);
      expect(game.program.first.count, BlockCodingGame.minLoopCount);
    });

    test('keyingi topshiriqda dastur tozalanadi', () {
      final game = BlockCodingGame(level: CodingLevel.easy);
      _write(game, 'FFF');
      game.nextPuzzle();
      expect(game.puzzleIndex, 1);
      expect(game.program, isEmpty);
    });
  });
}

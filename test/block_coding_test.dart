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
        game.changeLoopCount(digit - game.loopCount);
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

  // Avval takrorlash ichi, keyin asosiy dastur (🔁 qo'shilganda tab o'zi almashmasligi uchun).
  game.editingLoop = true;
  addAll(body);
  game.editingLoop = false;
  addAll(main);
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

    test('🔁 soni 2..5 oralig\'ida ➖/➕ bilan o\'zgaradi va dastur yoyiladi', () {
      final game = BlockCodingGame(level: CodingLevel.hard);
      _write(game, '2', 'FR');
      expect(game.compile(), [
        BlockType.forward,
        BlockType.right,
        BlockType.forward,
        BlockType.right,
      ]);
      game.changeLoopCount(-1);
      expect(game.loopCount, BlockCodingGame.minLoopCount);
      for (var i = 0; i < 5; i++) {
        game.changeLoopCount(1);
      }
      expect(game.loopCount, BlockCodingGame.maxLoopCount);
      expect(game.compile().length, 10);
    });

    test('ikki 🔁 bloki bir xil takrorlash ichini bajaradi', () {
      final game = BlockCodingGame(level: CodingLevel.hard)..puzzleIndex = 3; // chegara: 7
      _write(game, '2L2', 'F');
      expect(game.compile(), [
        BlockType.forward,
        BlockType.forward,
        BlockType.left,
        BlockType.forward,
        BlockType.forward,
      ]);
    });

    test("bo'sh 🔁 — xato emas, robot yurmaydi", () {
      final game = BlockCodingGame(level: CodingLevel.hard);
      _write(game, 'FF2');
      expect(game.hasEmptyLoop, isTrue);
      final result = game.run();
      expect(result.outcome, RunOutcome.emptyLoop);
      expect(result.trace, hasLength(1));
      expect(game.mistakes, 0);
    });

    test("ichi bo'sh 🔁 qo'shilganda tab takrorlash ichiga o'tadi", () {
      final game = BlockCodingGame(level: CodingLevel.hard)..puzzleIndex = 3;
      game.add(BlockType.loop);
      expect(game.editingLoop, isTrue);
      game.add(BlockType.forward);
      expect(game.loopBody, [BlockType.forward]);

      // Ichi to'la bo'lsa — tab almashmaydi.
      game.editingLoop = false;
      game.add(BlockType.loop);
      expect(game.editingLoop, isFalse);
    });

    test('tozalash takrorlash sonini ham qaytaradi', () {
      final game = BlockCodingGame(level: CodingLevel.hard);
      _write(game, '4', 'F');
      game.clear();
      expect(game.loopCount, BlockCodingGame.minLoopCount);
      expect(game.editingLoop, isFalse);
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

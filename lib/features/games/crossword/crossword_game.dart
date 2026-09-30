import 'dart:math';

import '../game_result.dart';

/// Katak koordinatasi: (qator, ustun).
typedef Cell = (int, int);

/// O'zbek so'zini harflarga ajratadi: sh, ch, oʻ, gʻ — bitta katak.
List<String> splitCrosswordLetters(String word) {
  const digraphs = ['sh', 'ch', 'oʻ', 'gʻ'];
  final result = <String>[];
  var i = 0;
  while (i < word.length) {
    if (i + 1 < word.length && digraphs.contains(word.substring(i, i + 2))) {
      result.add(word.substring(i, i + 2));
      i += 2;
    } else {
      result.add(word[i]);
      i += 1;
    }
  }
  return result;
}

class CrosswordEntry {
  const CrosswordEntry(this.word, this.emoji);

  final String word;

  /// Rasm-ishora (so'z o'rniga ko'rsatiladi).
  final String emoji;

  List<String> get letters => splitCrosswordLetters(word);
}

const crosswordBank = [
  CrosswordEntry('olma', '🍎'),
  CrosswordEntry('nok', '🍐'),
  CrosswordEntry('uzum', '🍇'),
  CrosswordEntry('tarvuz', '🍉'),
  CrosswordEntry('qovun', '🍈'),
  CrosswordEntry('limon', '🍋'),
  CrosswordEntry('banan', '🍌'),
  CrosswordEntry('sabzi', '🥕'),
  CrosswordEntry('piyoz', '🧅'),
  CrosswordEntry('non', '🍞'),
  CrosswordEntry('sut', '🥛'),
  CrosswordEntry('tuxum', '🥚'),
  CrosswordEntry('choy', '🍵'),
  CrosswordEntry('asal', '🍯'),
  CrosswordEntry('mushuk', '🐱'),
  CrosswordEntry('ot', '🐴'),
  CrosswordEntry('sigir', '🐮'),
  CrosswordEntry('tovuq', '🐔'),
  CrosswordEntry('baliq', '🐟'),
  CrosswordEntry('qush', '🐦'),
  CrosswordEntry('ayiq', '🐻'),
  CrosswordEntry('sher', '🦁'),
  CrosswordEntry('fil', '🐘'),
  CrosswordEntry('tulki', '🦊'),
  CrosswordEntry('quyon', '🐰'),
  CrosswordEntry('ilon', '🐍'),
  CrosswordEntry('toshbaqa', '🐢'),
  CrosswordEntry('ari', '🐝'),
  CrosswordEntry('kapalak', '🦋'),
  CrosswordEntry('quyosh', '☀️'),
  CrosswordEntry('oy', '🌙'),
  CrosswordEntry('yulduz', '⭐'),
  CrosswordEntry('bulut', '☁️'),
  CrosswordEntry('qor', '❄️'),
  CrosswordEntry('gul', '🌸'),
  CrosswordEntry('daraxt', '🌳'),
  CrosswordEntry('uy', '🏠'),
  CrosswordEntry('kitob', '📖'),
  CrosswordEntry('qalam', '✏️'),
  CrosswordEntry('soat', '⏰'),
  CrosswordEntry('kalit', '🔑'),
  CrosswordEntry('toʻp', '⚽'),
  CrosswordEntry('qoʻl', '✋'),
  CrosswordEntry('mashina', '🚗'),
  CrosswordEntry('kema', '🚢'),
];

/// Darajalar: 5, 8, 12 so'z.
enum CrosswordLevel {
  small(words: 5, emoji: '🐢'),
  medium(words: 8, emoji: '🐇'),
  large(words: 12, emoji: '🚀');

  const CrosswordLevel({required this.words, required this.emoji});

  final int words;
  final String emoji;
}

/// Taxtaga joylashtirilgan so'z.
class PlacedWord {
  const PlacedWord(this.entry, this.row, this.col, this.horizontal);

  final CrosswordEntry entry;
  final int row;
  final int col;
  final bool horizontal;

  List<String> get letters => entry.letters;

  List<Cell> get cells => [
        for (var i = 0; i < letters.length; i++)
          horizontal ? (row, col + i) : (row + i, col),
      ];
}

class CrosswordPuzzle {
  CrosswordPuzzle(this.words) {
    for (final w in words) {
      final cells = w.cells;
      for (var i = 0; i < cells.length; i++) {
        solution[cells[i]] = w.letters[i];
      }
    }
    rows = solution.keys.map((c) => c.$1).reduce(max) + 1;
    cols = solution.keys.map((c) => c.$2).reduce(max) + 1;
  }

  final List<PlacedWord> words;
  final Map<Cell, String> solution = {};
  late final int rows;
  late final int cols;
}

/// Krossvord tuzuvchi: har yangi so'z mavjud so'zlarni umumiy harf orqali kesib o'tadi.
/// Yonma-yon tegib turgan so'zlar va bir yo'nalishda ustma-ust tushish taqiqlangan.
class CrosswordGenerator {
  CrosswordGenerator(this.random);

  final Random random;

  CrosswordPuzzle generate(int count, {List<CrosswordEntry> bank = crosswordBank}) {
    List<PlacedWord> best = [];
    for (var attempt = 0; attempt < 200 && best.length < count; attempt++) {
      final placed = _tryBuild(count, bank);
      if (placed.length > best.length) best = placed;
    }
    return CrosswordPuzzle(_normalize(best));
  }

  List<PlacedWord> _tryBuild(int count, List<CrosswordEntry> bank) {
    final pool = [...bank]..shuffle(random);
    final grid = <Cell, String>{};
    final directions = <Cell, Set<bool>>{};
    final placed = <PlacedWord>[];

    void put(PlacedWord w) {
      final cells = w.cells;
      for (var i = 0; i < cells.length; i++) {
        grid[cells[i]] = w.letters[i];
        (directions[cells[i]] ??= {}).add(w.horizontal);
      }
      placed.add(w);
    }

    // Birinchi so'z — uzunroq bo'lsa kesishish imkoniyati ko'p.
    final firstIndex = pool.indexWhere((e) => e.letters.length >= 4);
    put(PlacedWord(pool.removeAt(firstIndex), 0, 0, true));

    var progress = true;
    while (placed.length < count && progress) {
      progress = false;
      for (final entry in [...pool]) {
        final options = _placements(entry, grid, directions);
        if (options.isEmpty) continue;
        put(options[random.nextInt(options.length)]);
        pool.remove(entry);
        progress = true;
        if (placed.length == count) break;
      }
    }
    return placed;
  }

  List<PlacedWord> _placements(
    CrosswordEntry entry,
    Map<Cell, String> grid,
    Map<Cell, Set<bool>> directions,
  ) {
    final letters = entry.letters;
    final result = <PlacedWord>[];
    for (final MapEntry(key: cell, value: letter) in grid.entries) {
      for (var i = 0; i < letters.length; i++) {
        if (letters[i] != letter) continue;
        for (final horizontal in [true, false]) {
          final row = horizontal ? cell.$1 : cell.$1 - i;
          final col = horizontal ? cell.$2 - i : cell.$2;
          final candidate = PlacedWord(entry, row, col, horizontal);
          if (_fits(candidate, grid, directions)) result.add(candidate);
        }
      }
    }
    return result;
  }

  bool _fits(PlacedWord w, Map<Cell, String> grid, Map<Cell, Set<bool>> directions) {
    final dr = w.horizontal ? 0 : 1;
    final dc = w.horizontal ? 1 : 0;
    final cells = w.cells;
    // So'z oldi va orqasi bo'sh bo'lishi kerak.
    if (grid.containsKey((w.row - dr, w.col - dc))) return false;
    final last = cells.last;
    if (grid.containsKey((last.$1 + dr, last.$2 + dc))) return false;

    var crossings = 0;
    for (var i = 0; i < cells.length; i++) {
      final (r, c) = cells[i];
      final existing = grid[cells[i]];
      if (existing != null) {
        if (existing != w.letters[i]) return false;
        if (directions[cells[i]]!.contains(w.horizontal)) return false;
        crossings++;
      } else {
        // Yangi katakning yon qo'shnilari bo'sh — so'zlar yopishib qolmaydi.
        if (grid.containsKey((r + dc, c + dr))) return false;
        if (grid.containsKey((r - dc, c - dr))) return false;
      }
    }
    return crossings > 0;
  }

  /// Koordinatalarni (0, 0) dan boshlanadigan qilib suradi.
  List<PlacedWord> _normalize(List<PlacedWord> words) {
    final minRow = words.expand((w) => w.cells).map((c) => c.$1).reduce(min);
    final minCol = words.expand((w) => w.cells).map((c) => c.$2).reduce(min);
    return [
      for (final w in words) PlacedWord(w.entry, w.row - minRow, w.col - minCol, w.horizontal),
    ];
  }
}

enum CrosswordOutcome { correct, wrong, wordFinished, gameFinished }

/// O'yin: rasm-ishorani bosib so'zni tanlaydi, harf tugmalari bilan kataklarni to'ldiradi.
class CrosswordGame {
  CrosswordGame(this.level, {Random? random}) : _random = random ?? Random() {
    puzzle = CrosswordGenerator(_random).generate(level.words);
    select(0);
  }

  /// Harf tugmalari soni (so'z harflari + chalg'ituvchilar).
  static const tileCount = 8;
  static const _extraLetters = [
    'a', 'b', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', //
    'r', 's', 't', 'u', 'v', 'x', 'y', 'z', 'oʻ', 'gʻ', 'sh', 'ch',
  ];

  final CrosswordLevel level;
  final Random _random;
  late final CrosswordPuzzle puzzle;

  final Map<Cell, String> filled = {};
  int selected = 0;
  List<String> tiles = [];
  int mistakes = 0;

  PlacedWord get selectedWord => puzzle.words[selected];
  int get stars => starsForMistakes(mistakes);

  bool isWordDone(int index) => puzzle.words[index].cells.every(filled.containsKey);
  bool get isFinished => puzzle.solution.keys.every(filled.containsKey);

  /// Tanlangan so'zdagi birinchi bo'sh katak (harf shu yerga yoziladi).
  Cell? get cursor {
    for (final cell in selectedWord.cells) {
      if (!filled.containsKey(cell)) return cell;
    }
    return null;
  }

  void select(int index) {
    selected = index;
    final letters = selectedWord.letters.toSet();
    final extras = _extraLetters.where((l) => !letters.contains(l)).toList()..shuffle(_random);
    tiles = [...letters, ...extras.take(max(0, tileCount - letters.length))]..shuffle(_random);
  }

  /// Katak bosilsa — shu katakdan o'tuvchi so'z tanlanadi.
  /// Kesishgan katak: tanlangan so'z ichida bo'lsa — ikkinchi so'zga o'tadi.
  void selectCell(Cell cell) {
    final indexes = [
      for (var i = 0; i < puzzle.words.length; i++)
        if (puzzle.words[i].cells.contains(cell)) i,
    ];
    if (indexes.isEmpty) return;
    if (indexes.contains(selected)) {
      if (indexes.length > 1) select(indexes.firstWhere((i) => i != selected));
      return;
    }
    final open = indexes.where((i) => !isWordDone(i));
    select(open.isNotEmpty ? open.first : indexes.first);
  }

  CrosswordOutcome tapLetter(String letter) {
    final cell = cursor;
    if (cell == null) return CrosswordOutcome.wordFinished;
    if (puzzle.solution[cell] != letter) {
      mistakes++;
      return CrosswordOutcome.wrong;
    }
    filled[cell] = letter;
    if (isFinished) return CrosswordOutcome.gameFinished;
    if (isWordDone(selected)) return CrosswordOutcome.wordFinished;
    return CrosswordOutcome.correct;
  }

  /// Keyingi tugallanmagan so'zni tanlaydi.
  void selectNextOpen() {
    for (var k = 1; k <= puzzle.words.length; k++) {
      final i = (selected + k) % puzzle.words.length;
      if (!isWordDone(i)) {
        select(i);
        return;
      }
    }
  }
}

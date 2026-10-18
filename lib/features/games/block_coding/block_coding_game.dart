import '../../../core/constants/app_strings.dart';
import '../game_result.dart';
import 'block_coding_data.dart';

/// Robot qaragan tomon. Burilish robotning o'ziga nisbatan (chapga / o'ngga).
enum Heading {
  north(-1, 0),
  east(0, 1),
  south(1, 0),
  west(0, -1);

  const Heading(this.dRow, this.dCol);

  final int dRow;
  final int dCol;

  Heading get turnLeft => Heading.values[(index + 3) % 4];
  Heading get turnRight => Heading.values[(index + 1) % 4];
}

class Pos {
  const Pos(this.row, this.col);

  final int row;
  final int col;

  Pos move(Heading h) => Pos(row + h.dRow, col + h.dCol);

  @override
  bool operator ==(Object other) => other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

/// Robotning bir lahzadagi holati (animatsiya uchun).
class RobotState {
  const RobotState(this.pos, this.heading);

  final Pos pos;
  final Heading heading;
}

/// Bitta topshiriq: maydon, robotning boshlang'ich holati, maqsad va bloklar chegarasi.
class CodingPuzzle {
  CodingPuzzle.parse(List<String> rows, {this.maxBlocks})
    : size = rows.length,
      rocks = {
        for (var r = 0; r < rows.length; r++)
          for (var c = 0; c < rows[r].length; c++)
            if (rows[r][c] == '#') Pos(r, c),
      },
      goal = _find(rows, 'G').$1,
      start = _robot(rows);

  final int size;
  final Set<Pos> rocks;
  final Pos goal;
  final RobotState start;

  /// null — cheklanmagan.
  final int? maxBlocks;

  static (Pos, String) _find(List<String> rows, String chars) {
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        if (chars.contains(rows[r][c])) return (Pos(r, c), rows[r][c]);
      }
    }
    throw ArgumentError('Maydonda "$chars" topilmadi');
  }

  static RobotState _robot(List<String> rows) {
    final (pos, ch) = _find(rows, '^v<>');
    final heading = switch (ch) {
      '^' => Heading.north,
      'v' => Heading.south,
      '<' => Heading.west,
      _ => Heading.east,
    };
    return RobotState(pos, heading);
  }

  bool isFree(Pos p) =>
      p.row >= 0 && p.col >= 0 && p.row < size && p.col < size && !rocks.contains(p);
}

enum BlockType { forward, left, right, loop }

/// Dasturdagi bitta blok. Faqat [BlockType.loop] uchun [count] ma'noga ega.
class ProgramBlock {
  ProgramBlock(this.type, {this.count = BlockCodingGame.minLoopCount});

  final BlockType type;
  int count;
}

enum RunOutcome { empty, success, crashed, notReached }

/// Dastur bajarilishi natijasi: robot bosib o'tgan holatlar va yakun.
class RunResult {
  const RunResult(this.trace, this.outcome);

  /// Birinchi element — boshlang'ich holat, keyin har buyruqdan keyingi holat.
  final List<RobotState> trace;
  final RunOutcome outcome;
}

/// Daraja: oson va o'rta — cheklovsiz, qiyin — bloklar kam, 🔁 takrorlash bor.
enum CodingLevel {
  easy(emoji: '🐣'),
  medium(emoji: '🐥'),
  hard(emoji: '🦅');

  const CodingLevel({required this.emoji});

  final String emoji;

  String get label => switch (this) {
    CodingLevel.easy => AppStrings.levelEasy,
    CodingLevel.medium => AppStrings.levelMedium,
    CodingLevel.hard => AppStrings.levelHard,
  };

  bool get hasLoop => this == CodingLevel.hard;

  List<CodingPuzzle> get puzzles => switch (this) {
    CodingLevel.easy => [for (final m in codingMapsEasy) CodingPuzzle.parse(m)],
    CodingLevel.medium => [for (final m in codingMapsMedium) CodingPuzzle.parse(m)],
    CodingLevel.hard => [
      for (var i = 0; i < codingMapsHard.length; i++)
        CodingPuzzle.parse(codingMapsHard[i], maxBlocks: codingHardLimits[i]),
    ],
  };
}

/// Robot dasturchi mantiqi: bola bloklardan dastur tuzadi, robot uni bajaradi.
/// Xato dastur o'chirilmaydi — bola uni tuzatadi (debugging).
class BlockCodingGame {
  BlockCodingGame({this.level = CodingLevel.easy, List<CodingPuzzle>? puzzles})
    : _puzzles = puzzles ?? level.puzzles;

  static const minLoopCount = 2;
  static const maxLoopCount = 5;

  /// Cheklovsiz darajalarda ham dastur ekrandan oshib ketmasligi uchun.
  static const maxProgramLength = 32;

  final CodingLevel level;
  final List<CodingPuzzle> _puzzles;

  int puzzleIndex = 0;
  int mistakes = 0;

  /// Asosiy dastur.
  final List<ProgramBlock> program = [];

  /// 🔁 bloki takrorlaydigan qism (faqat qiyin darajada).
  final List<ProgramBlock> loopBody = [];

  /// true — yangi bloklar takrorlash ichiga qo'shiladi.
  bool editingLoop = false;

  CodingPuzzle get puzzle => _puzzles[puzzleIndex];
  int get puzzleCount => _puzzles.length;
  bool get isLastPuzzle => puzzleIndex == _puzzles.length - 1;
  int get stars => starsForMistakes(mistakes);

  int get usedBlocks => program.length + loopBody.length;

  List<ProgramBlock> get _target => editingLoop ? loopBody : program;

  bool canAdd(BlockType type) {
    if (type == BlockType.loop && (!level.hasLoop || editingLoop)) return false;
    final limit = puzzle.maxBlocks;
    if (limit != null) return usedBlocks < limit;
    return _target.length < maxProgramLength;
  }

  bool add(BlockType type) {
    if (!canAdd(type)) return false;
    _target.add(ProgramBlock(type));
    return true;
  }

  void removeLast() {
    final target = _target;
    if (target.isNotEmpty) target.removeLast();
  }

  void clear() {
    program.clear();
    loopBody.clear();
    editingLoop = false;
  }

  /// 🔁 blokining sonini aylantiradi: 2 → 3 → 4 → 5 → 2.
  void cycleLoopCount(int index) {
    final block = program[index];
    if (block.type != BlockType.loop) return;
    block.count = block.count >= maxLoopCount ? minLoopCount : block.count + 1;
  }

  /// Dasturni oddiy buyruqlar ro'yxatiga yoyadi (takrorlash ichida takrorlash yo'q).
  List<BlockType> compile() => [
    for (final block in program)
      if (block.type == BlockType.loop)
        for (var i = 0; i < block.count; i++) ...loopBody.map((b) => b.type)
      else
        block.type,
  ];

  /// Dasturni bajaradi. Robot maqsadga yetsa, darhol to'xtaydi.
  /// Yiqilish yoki yetib bormaslik — xato sifatida sanaladi.
  RunResult run() {
    final commands = compile();
    var state = puzzle.start;
    final trace = [state];
    if (commands.isEmpty) return RunResult(trace, RunOutcome.empty);

    for (final command in commands) {
      switch (command) {
        case BlockType.forward:
          final next = state.pos.move(state.heading);
          if (!puzzle.isFree(next)) {
            mistakes++;
            return RunResult(trace, RunOutcome.crashed);
          }
          state = RobotState(next, state.heading);
        case BlockType.left:
          state = RobotState(state.pos, state.heading.turnLeft);
        case BlockType.right:
          state = RobotState(state.pos, state.heading.turnRight);
        case BlockType.loop:
          break;
      }
      trace.add(state);
      if (state.pos == puzzle.goal) return RunResult(trace, RunOutcome.success);
    }
    mistakes++;
    return RunResult(trace, RunOutcome.notReached);
  }

  void nextPuzzle() {
    if (isLastPuzzle) return;
    puzzleIndex++;
    clear();
  }
}

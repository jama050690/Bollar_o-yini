import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';
import 'maze_quiz_data.dart';

enum Cell { wall, path, door, exit }

enum Direction {
  up(-1, 0),
  down(1, 0),
  left(0, -1),
  right(0, 1);

  const Direction(this.dRow, this.dCol);

  final int dRow;
  final int dCol;
}

class Pos {
  const Pos(this.row, this.col);

  final int row;
  final int col;

  Pos move(Direction d) => Pos(row + d.dRow, col + d.dCol);

  @override
  bool operator ==(Object other) => other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

/// Bitta labirint: kataklar, boshlanish va chiqish.
class Maze {
  Maze.parse(List<String> rows)
    : size = rows.length,
      cells = [
        for (final row in rows)
          [
            for (final ch in row.split(''))
              switch (ch) {
                '#' => Cell.wall,
                'D' => Cell.door,
                'E' => Cell.exit,
                _ => Cell.path,
              },
          ],
      ],
      start = _find(rows, 'S');

  final int size;
  final List<List<Cell>> cells;
  final Pos start;

  static Pos _find(List<String> rows, String ch) {
    for (var r = 0; r < rows.length; r++) {
      final c = rows[r].indexOf(ch);
      if (c >= 0) return Pos(r, c);
    }
    throw ArgumentError('Labirintda "$ch" topilmadi');
  }

  Cell at(Pos p) {
    if (p.row < 0 || p.col < 0 || p.row >= size || p.col >= size) return Cell.wall;
    return cells[p.row][p.col];
  }

  int get doorCount => cells.expand((row) => row).where((c) => c == Cell.door).length;
}

enum MoveOutcome { moved, blocked, question, mazeFinished, gameFinished }

enum QuizOutcome { correct, wrong }

/// Daraja labirint o'lchami bilan belgilanadi; har darajada 2 ta labirint.
enum MazeLevel {
  small(size: 5, emoji: '🐣'),
  medium(size: 7, emoji: '🐥'),
  large(size: 9, emoji: '🦅');

  const MazeLevel({required this.size, required this.emoji});

  final int size;
  final String emoji;

  String get label => AppStrings.mazeSize(size);

  List<List<String>> get maps => switch (this) {
    MazeLevel.small => mazeMaps5,
    MazeLevel.medium => mazeMaps.sublist(1),
    MazeLevel.large => mazeMaps9,
  };
}

/// Labirint-kviz mantiqi: darajadagi labirintlar ketma-ket, eshiklarda savol.
class MazeQuizGame {
  MazeQuizGame({Random? random, MazeLevel level = MazeLevel.medium, List<List<String>>? maps})
    : _mazes = [for (final m in maps ?? level.maps) Maze.parse(m)],
      _questions = List.of(quizQuestions)..shuffle(random ?? Random()) {
    _resetMaze();
  }

  final List<Maze> _mazes;
  final List<QuizQuestion> _questions;
  int _questionIndex = 0;

  int mazeIndex = 0;
  int mistakes = 0;
  late Pos player;

  /// Ochilgan eshiklar (joriy labirintda).
  final Set<Pos> openedDoors = {};

  /// Javob kutilayotgan eshik va savol.
  Pos? pendingDoor;
  QuizQuestion? pendingQuestion;

  Maze get maze => _mazes[mazeIndex];
  int get mazeCount => _mazes.length;
  bool get isLastMaze => mazeIndex == _mazes.length - 1;
  int get stars => starsForMistakes(mistakes);

  void _resetMaze() {
    player = maze.start;
    openedDoors.clear();
    pendingDoor = null;
    pendingQuestion = null;
  }

  QuizQuestion _nextQuestion() {
    final q = _questions[_questionIndex % _questions.length];
    _questionIndex++;
    return q;
  }

  MoveOutcome move(Direction d) {
    if (pendingQuestion != null) return MoveOutcome.blocked;
    final target = player.move(d);
    switch (maze.at(target)) {
      case Cell.wall:
        return MoveOutcome.blocked;
      case Cell.door when !openedDoors.contains(target):
        pendingDoor = target;
        pendingQuestion = _nextQuestion();
        return MoveOutcome.question;
      case Cell.exit:
        player = target;
        return isLastMaze ? MoveOutcome.gameFinished : MoveOutcome.mazeFinished;
      case Cell.door:
      case Cell.path:
        player = target;
        return MoveOutcome.moved;
    }
  }

  /// Savolga javob: to'g'ri bo'lsa eshik ochiladi va o'yinchi eshikka o'tadi.
  QuizOutcome answer(int optionIndex) {
    final q = pendingQuestion!;
    if (optionIndex != q.answerIndex) {
      mistakes++;
      return QuizOutcome.wrong;
    }
    openedDoors.add(pendingDoor!);
    player = pendingDoor!;
    pendingDoor = null;
    pendingQuestion = null;
    return QuizOutcome.correct;
  }

  void nextMaze() {
    if (isLastMaze) return;
    mazeIndex++;
    _resetMaze();
  }
}

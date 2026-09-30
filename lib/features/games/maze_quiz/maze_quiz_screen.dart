import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'maze_quiz_game.dart';

const _gameId = 'maze_quiz';

/// Labirint-kviz: strelkalar bilan chiqishga yetib borish, eshiklarda savol.
class MazeQuizScreen extends ConsumerStatefulWidget {
  const MazeQuizScreen({super.key});

  @override
  ConsumerState<MazeQuizScreen> createState() => _MazeQuizScreenState();
}

class _MazeQuizScreenState extends ConsumerState<MazeQuizScreen> {
  final _game = MazeQuizGame();
  final _stopwatch = Stopwatch()..start();
  Timer? _timer;
  int? _wrongOption;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SoundService get _sound => ref.read(soundServiceProvider);

  void _onMove(Direction d) {
    if (_celebrating) return;
    final outcome = _game.move(d);
    setState(() {});

    switch (outcome) {
      case MoveOutcome.moved:
      case MoveOutcome.blocked:
      case MoveOutcome.question:
        break;
      case MoveOutcome.mazeFinished:
        _sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1300), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            _game.nextMaze();
          });
        });
      case MoveOutcome.gameFinished:
        _stopwatch.stop();
        _sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1300), () {
          if (!mounted) return;
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: _game.stars, duration: _stopwatch.elapsed),
          );
        });
    }
  }

  void _onAnswer(int index) {
    final outcome = _game.answer(index);
    _timer?.cancel();
    setState(() => _wrongOption = outcome == QuizOutcome.wrong ? index : null);
    if (outcome == QuizOutcome.correct) {
      _sound.play(SoundService.correct);
    } else {
      _sound.play(SoundService.tryAgain);
      _timer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _wrongOption = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _game.pendingQuestion;
    return GameScaffold(
      title: AppStrings.mazeQuizTitle,
      color: AgeGroup.b.color,
      trailing: Text(
        AppStrings.round(_game.mazeIndex + 1, _game.mazeCount),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Labirint ekranning yuqori qismini egallaydi, pastda boshqaruv.
          final side = min(constraints.maxWidth - 32, constraints.maxHeight * 0.5);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: SizedBox.square(
                  dimension: side,
                  child: _MazeBoard(game: _game, celebrating: _celebrating),
                ),
              ),
              const SizedBox(height: 12),
              if (_celebrating)
                const Center(
                  child: Text(AppStrings.wellDone, style: TextStyle(fontSize: 36)),
                )
              else if (question == null) ...[
                const Center(
                  child: Text(AppStrings.mazeHint, style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 12),
                _ArrowPad(onMove: _onMove),
              ] else
                _QuestionPanel(
                  text: question.text,
                  options: question.options,
                  wrongOption: _wrongOption,
                  onAnswer: _onAnswer,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MazeBoard extends StatelessWidget {
  const _MazeBoard({required this.game, required this.celebrating});

  final MazeQuizGame game;
  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    final maze = game.maze;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        crossAxisCount: maze.size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var r = 0; r < maze.size; r++)
            for (var c = 0; c < maze.size; c++) _buildCell(Pos(r, c), maze.at(Pos(r, c))),
        ],
      ),
    );
  }

  Widget _buildCell(Pos pos, Cell cell) {
    final isPlayer = pos == game.player;
    final isPendingDoor = pos == game.pendingDoor;
    final String symbol;
    if (isPlayer) {
      symbol = celebrating ? '🥳' : '🧒';
    } else if (cell == Cell.exit) {
      symbol = '🏁';
    } else if (cell == Cell.door && !game.openedDoors.contains(pos)) {
      symbol = '🚪';
    } else {
      symbol = '';
    }

    return Container(
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cell == Cell.wall
            ? const Color(0xFF5D4037)
            : isPendingDoor
                ? const Color(0xFFFFF59D)
                : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(symbol, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}

/// Katta strelka tugmalari (min 64 dp, NFR-1).
class _ArrowPad extends StatelessWidget {
  const _ArrowPad({required this.onMove});

  final ValueChanged<Direction> onMove;

  @override
  Widget build(BuildContext context) {
    Widget button(Direction d, IconData icon) => Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: Colors.white,
            elevation: 3,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onMove(d),
              child: SizedBox.square(
                dimension: 80,
                child: Icon(icon, size: 52, color: AppColors.text),
              ),
            ),
          ),
        );

    return Column(
      children: [
        button(Direction.up, Icons.arrow_upward_rounded),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button(Direction.left, Icons.arrow_back_rounded),
            const SizedBox(width: 88),
            button(Direction.right, Icons.arrow_forward_rounded),
          ],
        ),
        button(Direction.down, Icons.arrow_downward_rounded),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.text,
    required this.options,
    required this.wrongOption,
    required this.onAnswer,
  });

  final String text;
  final List<String> options;
  final int? wrongOption;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🚪 $text',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          SizedBox(
            height: 36,
            child: Center(
              child: wrongOption != null
                  ? const Text(
                      AppStrings.tryAgain,
                      style: TextStyle(fontSize: 20, color: Color(0xFFFB8C00)),
                    )
                  : null,
            ),
          ),
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      i == wrongOption ? const Color(0xFFFFE0B2) : AgeGroup.b.color.withValues(alpha: 0.35),
                  foregroundColor: AppColors.text,
                  textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                onPressed: () => onAnswer(i),
                child: Text(options[i]),
              ),
            ),
        ],
      ),
    );
  }
}

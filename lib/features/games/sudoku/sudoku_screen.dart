import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'sudoku_game.dart';

const _gameId = 'sudoku';

/// Sudoku 4×4 va 6×6: katakni tanlab, raqam tugmasini bosish.
class SudokuScreen extends ConsumerStatefulWidget {
  const SudokuScreen({super.key});

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  SudokuGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  (int, int)? _selected;
  int? _wrong;
  bool _done = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(SudokuLevel level) {
    setState(() => _game = SudokuGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onCellTap(int r, int c) {
    final game = _game!;
    if (_done || game.cells[r][c] != null) return;
    setState(() {
      _selected = (r, c);
      _wrong = null;
    });
  }

  void _onDigit(int value) {
    final game = _game!;
    final selected = _selected;
    if (_done || selected == null) return;

    final (r, c) = selected;
    final outcome = game.enter(r, c, value);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    switch (outcome) {
      case SudokuOutcome.ignored:
        break;
      case SudokuOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = value);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case SudokuOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _selected = null;
        });
      case SudokuOutcome.finished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() {
          _wrong = null;
          _selected = null;
          _done = true;
        });
        _timer = Timer(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: game.stars, duration: _stopwatch.elapsed),
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.sudokuBigTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              '✏️ ${game.blanksLeft}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(SudokuGame game) {
    final n = game.size;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _done
              ? AppStrings.wellDone
              : _selected == null
              ? AppStrings.sudokuPickCell
              : AppStrings.sudokuBigRule,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Tashqi chegara (2 × 3 px) ham sig'ishi kerak.
            final cell = min((constraints.maxWidth - 6) / n, 80.0);
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.text, width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var r = 0; r < n; r++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [for (var c = 0; c < n; c++) _buildCell(game, r, c, cell)],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(
          height: 44,
          child: Center(
            child: _wrong != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ),
        // Raqam tugmalari
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var v = 1; v <= n; v++)
              Material(
                color: v == _wrong ? const Color(0xFFFFE0B2) : Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  onTap: () => _onDigit(v),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Center(
                      child: Text(
                        '$v',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(SudokuGame game, int r, int c, double size) {
    final value = game.cells[r][c];
    final given = game.given[r][c];
    final selected = _selected == (r, c);
    // Qutilar chegarasi qalinroq.
    final thickRight = (c + 1) % game.level.boxCols == 0 && c != game.size - 1;
    final thickBottom = (r + 1) % game.level.boxRows == 0 && r != game.size - 1;
    return GestureDetector(
      onTap: () => _onCellTap(r, c),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF59D)
              : _done
              ? const Color(0xFFC8E6C9)
              : given
              ? const Color(0xFFF1F1F1)
              : Colors.white,
          border: Border(
            right: BorderSide(color: AppColors.text, width: thickRight ? 3 : 0.5),
            bottom: BorderSide(color: AppColors.text, width: thickBottom ? 3 : 0.5),
          ),
        ),
        child: Text(
          value == null ? '' : '$value',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: given ? AppColors.text : const Color(0xFF1E88E5),
          ),
        ),
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<SudokuLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseLevel, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final level in SudokuLevel.values)
                  ChoiceCard(
                    emoji: level.emoji,
                    label: level.label,
                    color: Colors.white,
                    onTap: () => onSelected(level),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

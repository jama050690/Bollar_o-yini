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
import 'block_coding_game.dart';

const _gameId = 'block_coding';
const _stepDelay = Duration(milliseconds: 380);
const _pauseDelay = Duration(milliseconds: 1300);

const _blockEmoji = {
  BlockType.forward: '⬆️',
  BlockType.left: '↩️',
  BlockType.right: '↪️',
  BlockType.loop: '🔁',
};

const _blockColor = {
  BlockType.forward: Color(0xFF81D4FA),
  BlockType.left: Color(0xFFFFCC80),
  BlockType.right: Color(0xFFFFCC80),
  BlockType.loop: Color(0xFFCE93D8),
};

String _blockLabel(BlockType type) => switch (type) {
  BlockType.forward => AppStrings.codingForward,
  BlockType.left => AppStrings.codingLeft,
  BlockType.right => AppStrings.codingRight,
  BlockType.loop => AppStrings.codingLoop,
};

/// Robot dasturchi: bloklardan dastur tuzib, robotni 🔋 gacha olib borish (TZ, 9-o'yin).
class BlockCodingScreen extends ConsumerStatefulWidget {
  const BlockCodingScreen({super.key});

  @override
  ConsumerState<BlockCodingScreen> createState() => _BlockCodingScreenState();
}

class _BlockCodingScreenState extends ConsumerState<BlockCodingScreen> {
  BlockCodingGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;

  /// Animatsiya paytida ko'rsatilayotgan holat; null — boshlang'ich holat.
  RobotState? _shown;
  bool _running = false;
  bool _crashed = false;
  bool _celebrating = false;
  String? _message;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SoundService get _sound => ref.read(soundServiceProvider);

  void _start(CodingLevel level) {
    setState(() => _game = BlockCodingGame(level: level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _edit(VoidCallback change) {
    if (_running) return;
    setState(() {
      change();
      _message = null;
    });
  }

  void _run() {
    final game = _game!;
    if (_running) return;
    final result = game.run();
    if (result.outcome == RunOutcome.empty) return;
    if (result.outcome == RunOutcome.emptyLoop) {
      // Xato emas — faqat keyingi qadamni ko'rsatamiz.
      setState(() {
        _message = AppStrings.codingEmptyLoop;
        game.editingLoop = true;
      });
      return;
    }

    setState(() {
      _running = true;
      _message = null;
      _shown = result.trace.first;
    });
    var step = 0;
    _timer?.cancel();
    _timer = Timer.periodic(_stepDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      step++;
      if (step < result.trace.length) {
        setState(() => _shown = result.trace[step]);
        return;
      }
      timer.cancel();
      _finishRun(result.outcome);
    });
  }

  void _finishRun(RunOutcome outcome) {
    final game = _game!;
    if (outcome == RunOutcome.success) {
      final last = game.isLastPuzzle;
      if (last) {
        _stopwatch.stop();
        _sound.play(SoundService.win);
      } else {
        _sound.play(SoundService.correct);
      }
      setState(() => _celebrating = true);
      _timer = Timer(_pauseDelay, () {
        if (!mounted) return;
        if (last) {
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: game.stars, duration: _stopwatch.elapsed),
          );
          return;
        }
        setState(() {
          game.nextPuzzle();
          _celebrating = false;
          _running = false;
          _shown = null;
        });
      });
      return;
    }

    // Xato: dastur saqlanadi, bola uni tuzatadi.
    _sound.play(SoundService.tryAgain);
    setState(() {
      _crashed = outcome == RunOutcome.crashed;
      _message = _crashed ? AppStrings.codingCrash : AppStrings.codingNotReached;
    });
    _timer = Timer(_pauseDelay, () {
      if (!mounted) return;
      setState(() {
        _crashed = false;
        _running = false;
        _shown = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.codingTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.puzzleIndex + 1, game.puzzleCount),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(BlockCodingGame game) {
    final limit = game.puzzle.maxBlocks;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth - 32, constraints.maxHeight * 0.38);
        final hasLoop = game.level.hasLoop;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (hasLoop)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _blockColor[BlockType.loop]!.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppStrings.codingLoopSteps,
                  style: const TextStyle(fontSize: 18, color: AppColors.text, height: 1.35),
                ),
              )
            else
              Text(
                AppStrings.codingHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: AppColors.text),
              ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox.square(
                dimension: side,
                child: _Board(
                  puzzle: game.puzzle,
                  robot: _shown ?? game.puzzle.start,
                  crashed: _crashed,
                  celebrating: _celebrating,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  _celebrating ? AppStrings.wellDone : (_message ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _celebrating ? 30 : 20,
                    fontWeight: FontWeight.bold,
                    color: _celebrating ? AppColors.text : const Color(0xFFFB8C00),
                  ),
                ),
              ),
            ),
            // "Ishga tushir" maydon ostida — ekranni aylantirmasdan ko'rinadi.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  icon: Icons.backspace_rounded,
                  label: AppStrings.codingUndo,
                  color: Colors.white,
                  onTap: _running ? null : () => _edit(game.removeLast),
                ),
                _ActionButton(
                  icon: Icons.delete_sweep_rounded,
                  label: AppStrings.codingClear,
                  color: Colors.white,
                  onTap: _running ? null : () => _edit(game.clear),
                ),
                _ActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: AppStrings.codingRun,
                  color: const Color(0xFFA5D6A7),
                  onTap: _running || game.program.isEmpty ? null : _run,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasLoop) ...[
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: AppStrings.codingProgram,
                      selected: !game.editingLoop,
                      onTap: () => _edit(() => game.editingLoop = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TabButton(
                      label: AppStrings.codingLoopBody,
                      selected: game.editingLoop,
                      onTap: () => _edit(() => game.editingLoop = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            _Palette(
              types: [
                BlockType.forward,
                BlockType.left,
                BlockType.right,
                if (hasLoop) BlockType.loop,
              ],
              enabled: (type) => !_running && game.canAdd(type),
              onAdd: (type) => _edit(() => game.add(type)),
            ),
            const SizedBox(height: 12),
            _ProgramRow(
              title: AppStrings.codingProgram,
              blocks: game.program,
              loopBody: game.loopBody,
              loopCount: game.loopCount,
              selected: hasLoop && !game.editingLoop,
              onSelect: hasLoop ? () => _edit(() => game.editingLoop = false) : null,
            ),
            if (hasLoop) ...[
              const SizedBox(height: 8),
              _ProgramRow(
                title: AppStrings.codingLoopInside(game.loopCount),
                blocks: game.loopBody,
                loopBody: game.loopBody,
                loopCount: game.loopCount,
                selected: game.editingLoop,
                onSelect: () => _edit(() => game.editingLoop = true),
                counter: _LoopCounter(
                  count: game.loopCount,
                  onLess: _running || game.loopCount <= BlockCodingGame.minLoopCount
                      ? null
                      : () => _edit(() => game.changeLoopCount(-1)),
                  onMore: _running || game.loopCount >= BlockCodingGame.maxLoopCount
                      ? null
                      : () => _edit(() => game.changeLoopCount(1)),
                ),
              ),
            ],
            if (limit != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  AppStrings.codingBlocks(game.usedBlocks, limit),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<CodingLevel> onSelected;

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
                for (final level in CodingLevel.values)
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

class _Board extends StatelessWidget {
  const _Board({
    required this.puzzle,
    required this.robot,
    required this.crashed,
    required this.celebrating,
  });

  final CodingPuzzle puzzle;
  final RobotState robot;
  final bool crashed;
  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF90A4AE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        crossAxisCount: puzzle.size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var r = 0; r < puzzle.size; r++)
            for (var c = 0; c < puzzle.size; c++) _buildCell(Pos(r, c)),
        ],
      ),
    );
  }

  Widget _buildCell(Pos pos) {
    final Widget content;
    if (pos == robot.pos) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          _emoji(crashed ? '💥' : (celebrating ? '🥳' : '🤖')),
          if (!crashed && !celebrating)
            Align(
              alignment: Alignment.topRight,
              child: RotatedBox(
                quarterTurns: robot.heading.index,
                child: const FractionallySizedBox(
                  widthFactor: 0.4,
                  heightFactor: 0.4,
                  child: FittedBox(
                    child: Icon(Icons.navigation_rounded, color: Color(0xFF1565C0)),
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (pos == puzzle.goal) {
      content = _emoji('🔋');
    } else if (puzzle.rocks.contains(pos)) {
      content = _emoji('🪨');
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: puzzle.rocks.contains(pos) ? const Color(0xFFB0BEC5) : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: content,
    );
  }

  Widget _emoji(String symbol) => FittedBox(
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Text(symbol, style: const TextStyle(fontSize: 32)),
    ),
  );
}

/// Qo'shiladigan bloklar: katta tugmalar (min 64 dp, NFR-1).
class _Palette extends StatelessWidget {
  const _Palette({required this.types, required this.enabled, required this.onAdd});

  final List<BlockType> types;
  final bool Function(BlockType) enabled;
  final ValueChanged<BlockType> onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final type in types)
          _ActionButton(
            emoji: _blockEmoji[type],
            label: _blockLabel(type),
            color: _blockColor[type]!,
            onTap: enabled(type) ? () => onAdd(type) : null,
          ),
      ],
    );
  }
}

/// Qiyin darajada bloklar qayerga qo'shilishini tanlaydigan katta tab tugma.
class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? AgeGroup.c.color : Colors.white,
        elevation: selected ? 3 : 1,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Takrorlash soni: ➖ son ➕.
class _LoopCounter extends StatelessWidget {
  const _LoopCounter({required this.count, required this.onLess, required this.onMore});

  final int count;
  final VoidCallback? onLess;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String label, VoidCallback? onTap) => Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: _blockColor[BlockType.loop],
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Tooltip(
            message: label,
            child: SizedBox.square(
              dimension: AppSizes.minTapTarget,
              child: Icon(icon, size: 36, color: AppColors.text),
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove_rounded, AppStrings.codingLess, onLess),
        SizedBox(
          width: 52,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        button(Icons.add_rounded, AppStrings.codingMore, onMore),
      ],
    );
  }
}

/// Dastur qatori. Tanlangan qator (bloklar shu yerga qo'shiladi) rangli ramka bilan ajraladi.
class _ProgramRow extends StatelessWidget {
  const _ProgramRow({
    required this.title,
    required this.blocks,
    required this.loopBody,
    required this.loopCount,
    required this.selected,
    this.onSelect,
    this.counter,
  });

  final String title;
  final List<BlockType> blocks;

  /// 🔁 bloki ichida nima takrorlanishini ko'rsatish uchun.
  final List<BlockType> loopBody;
  final int loopCount;
  final bool selected;
  final VoidCallback? onSelect;
  final Widget? counter;

  @override
  Widget build(BuildContext context) {
    final accent = AgeGroup.c.color;
    return Material(
      color: selected ? Color.alphaBlend(accent.withValues(alpha: 0.12), Colors.white) : Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onSelect,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget + 40),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: selected ? accent : Colors.transparent, width: 4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ?counter,
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final type in blocks) _chip(type)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BlockType type) {
    final isLoop = type == BlockType.loop;
    return Semantics(
      label: isLoop ? AppStrings.codingLoopTimes(loopCount) : _blockLabel(type),
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTapTarget,
            minHeight: AppSizes.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _blockColor[type],
            borderRadius: BorderRadius.circular(14),
          ),
          child: isLoop ? _loopContent() : Text(_blockEmoji[type]!, style: _chipStyle),
        ),
      ),
    );
  }

  static const _chipStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  /// `🔁×3 [ ⬆️ ↪️ ]` — ichi bo'sh bo'lsa `[ ? ]`.
  Widget _loopContent() {
    final empty = loopBody.isEmpty;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${_blockEmoji[BlockType.loop]}×$loopCount', style: _chipStyle),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: empty ? const Color(0xFFFFE0B2) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: empty ? const Color(0xFFFB8C00) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            empty ? '?' : loopBody.map((t) => _blockEmoji[t]).join(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.emoji,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? emoji;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: color,
        elevation: enabled ? 3 : 0,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 96, minHeight: 80),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (emoji != null)
                  Text(emoji!, style: const TextStyle(fontSize: 30))
                else
                  Icon(icon, size: 34, color: AppColors.text),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

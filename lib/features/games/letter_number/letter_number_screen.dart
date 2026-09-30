import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'letter_number_game.dart';

const _gameId = 'letter_number';

/// Harf-Raqam bog'chasi: harf/raqamlarni to'g'ri tartibda bosish.
class LetterNumberScreen extends ConsumerStatefulWidget {
  const LetterNumberScreen({super.key});

  @override
  ConsumerState<LetterNumberScreen> createState() => _LetterNumberScreenState();
}

class _LetterNumberScreenState extends ConsumerState<LetterNumberScreen> {
  LetterNumberGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  SequenceItem? _wrongItem;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SoundService get _sound => ref.read(soundServiceProvider);

  void _start(SequenceMode mode) {
    setState(() => _game = LetterNumberGame(mode));
    _stopwatch
      ..reset()
      ..start();
    _playTarget();
  }

  void _playTarget() {
    final game = _game!;
    final key = game.target.soundKey;
    _sound.play(
      game.mode == SequenceMode.numbers ? SoundService.number(key) : SoundService.letter(key),
    );
  }

  void _onTileTap(SequenceItem item) {
    final game = _game!;
    if (_celebrating || game.isDone(item)) return;

    final outcome = game.tap(item);
    _timer?.cancel();
    setState(() => _wrongItem = outcome == TapOutcome.wrong ? item : null);

    switch (outcome) {
      case TapOutcome.correct:
        _playTarget();
      case TapOutcome.wrong:
        _sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _wrongItem = null);
        });
      case TapOutcome.roundFinished:
        _sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            game.startNextRound();
          });
          _playTarget();
        });
      case TapOutcome.gameFinished:
        _stopwatch.stop();
        _sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1000), () {
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
      title: AppStrings.letterNumberTitle,
      color: AgeGroup.a.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.roundIndex + 1, game.rounds.length),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _ModePicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(LetterNumberGame game) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TargetPanel(
          game: game,
          celebrating: _celebrating,
          showTryAgain: _wrongItem != null,
          onSpeakerTap: _playTarget,
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final item in game.currentTiles)
              _Tile(
                item: item,
                done: game.isDone(item),
                wrong: item == _wrongItem,
                onTap: () => _onTileTap(item),
              ),
          ],
        ),
      ],
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.onSelected});

  final ValueChanged<SequenceMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseMode, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final mode in SequenceMode.values)
                  ChoiceCard(
                    emoji: mode.emoji,
                    label: mode.label,
                    color: Colors.white,
                    onTap: () => onSelected(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Yuqori panel: qaysi belgini bosish kerakligi va shu paytgacha to'plangan ketma-ketlik.
class _TargetPanel extends StatelessWidget {
  const _TargetPanel({
    required this.game,
    required this.celebrating,
    required this.showTryAgain,
    required this.onSpeakerTap,
  });

  final LetterNumberGame game;
  final bool celebrating;
  final bool showTryAgain;
  final VoidCallback onSpeakerTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        children: [
          if (celebrating)
            const Text(AppStrings.wellDone, style: TextStyle(fontSize: 40))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(AppStrings.findThis, style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Text(
                  game.target.label,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  iconSize: 44,
                  onPressed: onSpeakerTap,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
          const SizedBox(height: 8),
          // To'plangan ketma-ketlik: A B D _ _
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final item in game.currentRound)
                Text(
                  game.isDone(item) ? item.label : '_',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: game.isDone(item) ? const Color(0xFF43A047) : Colors.black26,
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 32,
            child: showTryAgain
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.item,
    required this.done,
    required this.wrong,
    required this.onTap,
  });

  final SequenceItem item;
  final bool done;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFFC8E6C9)
        : wrong
            ? const Color(0xFFFFE0B2)
            : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 2),
          boxShadow: done
              ? null
              : const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 48, color: Color(0xFF43A047))
            : Text(
                item.label,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
      ),
    );
  }
}

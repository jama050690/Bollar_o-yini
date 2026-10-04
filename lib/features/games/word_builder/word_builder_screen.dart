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
import 'word_builder_game.dart';

const _gameId = 'word_builder';

/// So'z quramchisi: rasmga qarab aralash harflardan so'z yig'ish.
class WordBuilderScreen extends ConsumerStatefulWidget {
  const WordBuilderScreen({super.key});

  @override
  ConsumerState<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends ConsumerState<WordBuilderScreen> {
  WordBuilderGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrongTile;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(WordLevel level) {
    setState(() => _game = WordBuilderGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onTileTap(int index) {
    final game = _game!;
    if (_celebrating || game.usedTiles.contains(index)) return;

    final outcome = game.tapTile(index);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrongTile = outcome == LetterOutcome.wrong ? index : null);

    switch (outcome) {
      case LetterOutcome.correct:
        break;
      case LetterOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _wrongTile = null);
        });
      case LetterOutcome.wordFinished:
        sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1300), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            game.nextWord();
          });
        });
      case LetterOutcome.gameFinished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1300), () {
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
      title: AppStrings.wordBuilderTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.wordIndex + 1, game.words.length),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(WordBuilderGame game) {
    final letters = game.currentLetters;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rasm (so'z ma'nosi)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              Text(game.current.emoji, style: const TextStyle(fontSize: 96)),
              Text(
                _celebrating ? AppStrings.wellDone : AppStrings.buildWord,
                style: const TextStyle(fontSize: 22, color: AppColors.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Yig'ilayotgan so'z: bo'sh kataklar
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < letters.length; i++)
              _Slot(letter: i < game.placed ? letters[i] : null),
          ],
        ),
        SizedBox(
          height: 40,
          child: Center(
            child: _wrongTile != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ),
        // Aralash harf kartochkalari
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < game.tiles.length; i++)
              _LetterTile(
                letter: game.tiles[i],
                used: game.usedTiles.contains(i),
                wrong: i == _wrongTile,
                onTap: () => _onTileTap(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<WordLevel> onSelected;

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
                for (final level in WordLevel.values)
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

class _Slot extends StatelessWidget {
  const _Slot({required this.letter});

  final String? letter;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 64,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter == null ? Colors.white54 : const Color(0xFFC8E6C9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26, width: 2),
      ),
      child: Text(
        letter ?? '',
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.text),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.used,
    required this.wrong,
    required this.onTap,
  });

  final String letter;
  final bool used;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: used ? 0.25 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: wrong ? const Color(0xFFFFE0B2) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12, width: 2),
            boxShadow: used
                ? null
                : const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

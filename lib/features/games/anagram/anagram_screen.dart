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
import 'anagram_game.dart';

const _gameId = 'anagram';

/// Anagramma: faqat turkum maslahati bilan aralash harflardan so'z tuzish.
class AnagramScreen extends ConsumerStatefulWidget {
  const AnagramScreen({super.key});

  @override
  ConsumerState<AnagramScreen> createState() => _AnagramScreenState();
}

class _AnagramScreenState extends ConsumerState<AnagramScreen> {
  AnagramGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;

  /// So'z to'ldi, lekin noto'g'ri — kataklar qisqa vaqt to'q sariq.
  bool _wrong = false;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(AnagramLevel level) {
    setState(() => _game = AnagramGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  bool get _locked => _wrong || _celebrating;

  void _onTileTap(int index) {
    final game = _game!;
    if (_locked) return;

    final outcome = game.place(index);
    final sound = ref.read(soundServiceProvider);
    setState(() {});

    switch (outcome) {
      case AnagramOutcome.ignored:
      case AnagramOutcome.placed:
        break;
      case AnagramOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = true);
        _timer = Timer(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _wrong = false;
            game.clear();
          });
        });
      case AnagramOutcome.correct:
        sound.play(SoundService.correct);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1300), () {
          if (!mounted) return;
          setState(() {
            _celebrating = false;
            game.nextWord();
          });
        });
      case AnagramOutcome.finished:
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

  void _onSlotTap(int slot) {
    if (_locked) return;
    setState(() => _game!.removeAt(slot));
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.anagramTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.wordIndex + 1, game.words.length),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(AnagramGame game) {
    final slotColor = _wrong
        ? const Color(0xFFFFE0B2)
        : _celebrating
        ? const Color(0xFFC8E6C9)
        : Colors.white;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Maslahat: so'z turkumi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              Text(
                game.current.category.label,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _celebrating ? AppStrings.wellDone : AppStrings.anagramHint,
                style: const TextStyle(fontSize: 22, color: AppColors.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Tuzilayotgan so'z: bosilsa harf qaytadi
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < game.tiles.length; i++)
              GestureDetector(
                onTap: () => _onSlotTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i < game.placed.length ? slotColor : Colors.white54,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: Text(
                    i < game.placed.length ? game.tiles[game.placed[i]] : '',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 48,
          child: Center(
            child: Text(
              _wrong
                  ? AppStrings.tryAgain
                  : game.placed.isNotEmpty && !_celebrating
                  ? AppStrings.anagramRemove
                  : '',
              style: TextStyle(
                fontSize: _wrong ? 22 : 16,
                color: _wrong ? const Color(0xFFFB8C00) : AppColors.text,
              ),
            ),
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
                used: game.placed.contains(i),
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

  final ValueChanged<AnagramLevel> onSelected;

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
                for (final level in AnagramLevel.values)
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

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.letter, required this.used, required this.onTap});

  final String letter;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: used ? 0.25 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12, width: 2),
            boxShadow: used
                ? null
                : const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

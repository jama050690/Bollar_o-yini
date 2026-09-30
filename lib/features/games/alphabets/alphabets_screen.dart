import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/widgets/choice_card.dart';
import '../../../shared/widgets/game_scaffold.dart';
import '../game_result.dart';
import 'alphabets_game.dart';

const _gameId = 'alphabets';

/// Alifbolar: o'zbek (lotin), rus, ingliz harflarini eshitib/ko'rib topish.
class AlphabetsScreen extends ConsumerStatefulWidget {
  const AlphabetsScreen({super.key});

  @override
  ConsumerState<AlphabetsScreen> createState() => _AlphabetsScreenState();
}

class _AlphabetsScreenState extends ConsumerState<AlphabetsScreen> {
  AlphabetsGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  AlphabetLetter? _wrong;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(Alphabet alphabet) {
    setState(() => _game = AlphabetsGame(alphabet));
    _stopwatch
      ..reset()
      ..start();
    _speak();
  }

  void _speak() {
    final game = _game!;
    if (game.isFinished) return;
    ref.read(ttsServiceProvider).speak(game.current.target.spoken, language: game.alphabet.language);
  }

  void _onAnswer(AlphabetLetter letter) {
    final game = _game!;
    if (_celebrating || game.isFinished) return;

    final outcome = game.answer(letter);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrong = outcome == LetterAnswer.wrong ? letter : null);

    switch (outcome) {
      case LetterAnswer.correct:
        sound.play(SoundService.correct);
        // To'g'ri javob ovozi tugashini kutib, keyingi harfni aytamiz.
        _timer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) _speak();
        });
      case LetterAnswer.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case LetterAnswer.finished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() => _celebrating = true);
        _timer = Timer(const Duration(milliseconds: 1200), () {
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
      title: AppStrings.alphabetsTitle,
      color: AgeGroup.a.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.index, game.questions.length),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _AlphabetPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(AlphabetsGame game) {
    if (_celebrating || game.isFinished) {
      return const Center(child: Text(AppStrings.wellDone, style: TextStyle(fontSize: 44)));
    }
    final q = game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              Text(
                '${game.alphabet.flag}  ${AppStrings.findLetter}',
                style: const TextStyle(fontSize: 26, color: AppColors.text),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kichik harf ko'rsatiladi, bola katta harfini topadi.
                  Text(
                    q.target.lower,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    iconSize: 56,
                    onPressed: _speak,
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
                ],
              ),
            ],
          ),
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            for (final letter in q.options)
              _LetterButton(
                label: letter.upper,
                wrong: letter == _wrong,
                onTap: () => _onAnswer(letter),
              ),
          ],
        ),
      ],
    );
  }
}

class _AlphabetPicker extends StatelessWidget {
  const _AlphabetPicker({required this.onSelected});

  final ValueChanged<Alphabet> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseAlphabet, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final alphabet in Alphabet.values)
                  ChoiceCard(
                    emoji: alphabet.flag,
                    label: alphabet.label,
                    color: Colors.white,
                    onTap: () => onSelected(alphabet),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({required this.label, required this.wrong, required this.onTap});

  final String label;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: wrong ? const Color(0xFFFFE0B2) : Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

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
import 'counting_game.dart';

const _gameId = 'counting';

/// Sanash: o'zbek yoki rus tilida aytilgan sonni raqamlardan topish (100 gacha).
class CountingScreen extends ConsumerStatefulWidget {
  const CountingScreen({super.key});

  @override
  ConsumerState<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends ConsumerState<CountingScreen> {
  CountingLanguage? _language;
  CountingGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrong;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(CountingLevel level) {
    setState(() => _game = CountingGame(_language!, level));
    _stopwatch
      ..reset()
      ..start();
    _speak();
  }

  void _speak() {
    final game = _game!;
    if (game.isFinished) return;
    ref.read(ttsServiceProvider).speak(
          game.language.words(game.current.number),
          language: game.language.language,
        );
  }

  void _onAnswer(int value) {
    final game = _game!;
    if (_celebrating || game.isFinished) return;

    final outcome = game.answer(value);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrong = outcome == CountingOutcome.wrong ? value : null);

    switch (outcome) {
      case CountingOutcome.correct:
        sound.play(SoundService.correct);
        _timer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) _speak();
        });
      case CountingOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case CountingOutcome.finished:
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
      title: AppStrings.countingTitle,
      color: AgeGroup.a.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.index, game.questions.length),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: switch ((_language, game)) {
        (null, _) => _Picker(
            title: AppStrings.chooseLanguage,
            cards: [
              for (final lang in CountingLanguage.values)
                (lang.flag, lang.label, () => setState(() => _language = lang)),
            ],
          ),
        (_, null) => _Picker(
            title: AppStrings.chooseLevel,
            cards: [
              for (final level in CountingLevel.values)
                (level.emoji, AppStrings.upTo(level.max), () => _start(level)),
            ],
          ),
        (_, final CountingGame g) => _buildGame(g),
      },
    );
  }

  Widget _buildGame(CountingGame game) {
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
                '${game.language.flag}  ${AppStrings.findNumber}',
                style: const TextStyle(fontSize: 26, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      game.language.words(q.number),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
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
            for (final option in q.options)
              _NumberButton(
                value: option,
                wrong: option == _wrong,
                onTap: () => _onAnswer(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.title, required this.cards});

  final String title;
  final List<(String emoji, String label, VoidCallback onTap)> cards;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final (emoji, label, onTap) in cards)
                  ChoiceCard(emoji: emoji, label: label, color: Colors.white, onTap: onTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({required this.value, required this.wrong, required this.onTap});

  final int value;
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
            '$value',
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

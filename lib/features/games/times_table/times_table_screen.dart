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
import 'times_table_game.dart';

const _gameId = 'times_table';

/// Karra jadvali: misol + sanash uchun rasm (a qator × b ta olma).
class TimesTableScreen extends ConsumerStatefulWidget {
  const TimesTableScreen({super.key});

  @override
  ConsumerState<TimesTableScreen> createState() => _TimesTableScreenState();
}

class _TimesTableScreenState extends ConsumerState<TimesTableScreen> {
  TimesTableGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrongOption;
  bool _celebrating = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(TimesLevel level) {
    setState(() => _game = TimesTableGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(int value) {
    final game = _game!;
    if (_celebrating || game.isFinished) return;

    final outcome = game.answer(value);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();
    setState(() => _wrongOption = outcome == TimesOutcome.wrong ? value : null);

    switch (outcome) {
      case TimesOutcome.correct:
        sound.play(SoundService.correct);
      case TimesOutcome.wrong:
        sound.play(SoundService.tryAgain);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrongOption = null);
        });
      case TimesOutcome.finished:
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
      title: AppStrings.timesTableTitle,
      color: AgeGroup.a.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(game.index, TimesTableGame.questionCount),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(TimesTableGame game) {
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
                q.text,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              _CountingPicture(rows: q.a, perRow: q.b),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: Center(
            child: _wrongOption != null
                ? const Text(
                    AppStrings.tryAgain,
                    style: TextStyle(fontSize: 22, color: Color(0xFFFB8C00)),
                  )
                : null,
          ),
        ),
        Row(
          children: [
            for (final option in q.options)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _AnswerButton(
                    value: option,
                    wrong: option == _wrongOption,
                    onTap: () => _onAnswer(option),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<TimesLevel> onSelected;

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
                for (final level in TimesLevel.values)
                  ChoiceCard(
                    emoji: level.emoji,
                    label: AppStrings.timesLevel(level.max),
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

/// a qator × b ta olma — bola sanab javob topishi uchun.
class _CountingPicture extends StatelessWidget {
  const _CountingPicture({required this.rows, required this.perRow});

  final int rows;
  final int perRow;

  @override
  Widget build(BuildContext context) {
    // Ko'p bo'lsa emoji kichrayadi, lekin hammasi ko'rinadi.
    final size = perRow > 5 || rows > 5 ? 22.0 : 34.0;
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var c = 0; c < perRow; c++)
                  Text('🍎', style: TextStyle(fontSize: size)),
              ],
            ),
          ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.value, required this.wrong, required this.onTap});

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
        child: SizedBox(
          height: 96,
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

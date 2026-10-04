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
import '../translate/translate_game.dart' show TargetLanguage;
import 'translate_plus_game.dart';

const _gameId = 'translate_plus';

/// Tarjimon+: so'z, birikma va gaplarni rus/ingliz tiliga tarjima qilish (ovoz bilan).
class TranslatePlusScreen extends ConsumerStatefulWidget {
  const TranslatePlusScreen({super.key});

  @override
  ConsumerState<TranslatePlusScreen> createState() => _TranslatePlusScreenState();
}

class _TranslatePlusScreenState extends ConsumerState<TranslatePlusScreen> {
  TargetLanguage? _language;
  TranslatePlusGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  String? _wrong;

  /// To'g'ri topilgan savol: tarjima ko'rsatilib, ovozda aytiladi.
  PhraseQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(TranslatePlusLevel level) {
    setState(() => _game = TranslatePlusGame(_language!, level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(String option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    if (outcome == PhraseOutcome.wrong) {
      sound.play(SoundService.tryAgain);
      setState(() => _wrong = option);
      _timer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _wrong = null);
      });
      return;
    }

    sound.play(outcome == PhraseOutcome.finished ? SoundService.win : SoundService.correct);
    setState(() {
      _wrong = null;
      _solved = question;
    });
    // To'g'ri javob ovozi tugagach, tarjimani chet tilida aytamiz.
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref.read(ttsServiceProvider).speak(question.answer, language: game.language.ttsLanguage);
      _timer = Timer(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        if (outcome == PhraseOutcome.finished) {
          _stopwatch.stop();
          finishGame(
            context,
            ref,
            GameResult(gameId: _gameId, stars: game.stars, duration: _stopwatch.elapsed),
          );
        } else {
          setState(() => _solved = null);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return GameScaffold(
      title: AppStrings.translatePlusTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, TranslatePlusGame.questionCount),
                TranslatePlusGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: _language == null
          ? _LanguagePicker(onSelected: (language) => setState(() => _language = language))
          : game == null
          ? _LevelPicker(onSelected: _start)
          : _buildGame(game),
    );
  }

  Widget _buildGame(TranslatePlusGame game) {
    final q = _solved ?? game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              Text(q.item.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(
                q.item.uzbek,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _solved != null
                    ? '${game.language.flag}  ${q.answer}  ✅'
                    : '${game.language.flag}  ${AppStrings.translateHint}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: AppColors.primary),
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
        for (final option in q.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Material(
              color: option == _wrong
                  ? const Color(0xFFFFE0B2)
                  : _solved != null && option == q.answer
                  ? const Color(0xFFC8E6C9)
                  : Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                onTap: () => _onAnswer(option),
                child: SizedBox(
                  height: 72,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.onSelected});

  final ValueChanged<TargetLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.chooseLanguage, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final language in TargetLanguage.values)
                  ChoiceCard(
                    emoji: language.flag,
                    label: language.label,
                    color: Colors.white,
                    onTap: () => onSelected(language),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<TranslatePlusLevel> onSelected;

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
                for (final level in TranslatePlusLevel.values)
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

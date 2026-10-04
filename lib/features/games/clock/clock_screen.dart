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
import 'clock_game.dart';

const _gameId = 'clock';

/// Soat: analog soatga qarab vaqtni aytish (butun, yarim soat, 5 daqiqa).
class ClockScreen extends ConsumerStatefulWidget {
  const ClockScreen({super.key});

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen> {
  ClockGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  String? _wrong;

  /// To'g'ri topilgan savol qisqa vaqt yashil holda ko'rsatiladi.
  ClockQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(ClockLevel level) {
    setState(() => _game = ClockGame(level));
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

    switch (outcome) {
      case ClockOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case ClockOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _solved = null);
        });
      case ClockOutcome.finished:
        _stopwatch.stop();
        sound.play(SoundService.win);
        setState(() {
          _wrong = null;
          _solved = question;
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
      title: AppStrings.clockTitle,
      color: AgeGroup.b.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, ClockGame.questionCount),
                ClockGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(ClockGame game) {
    final q = _solved ?? game.current;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth - 80, constraints.maxHeight * 0.42);
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
                  Center(
                    child: SizedBox.square(
                      dimension: side,
                      child: CustomPaint(painter: ClockPainter(q.time)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _solved != null ? '${q.answer}  ✅' : AppStrings.whatTime,
                    style: const TextStyle(fontSize: 26, color: AppColors.text),
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
              childAspectRatio: 2,
              children: [
                for (final option in q.options)
                  Material(
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
                      child: Center(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Analog soat: 12 ta raqam, qisqa qizil soat va uzun ko'k daqiqa ko'rsatkichi.
class ClockPainter extends CustomPainter {
  const ClockPainter(this.time);

  final ClockTime time;

  static const _hourColor = Color(0xFFE53935);
  static const _minuteColor = Color(0xFF1E88E5);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFFF8E1));
    canvas.drawCircle(
      center,
      r - r * 0.03,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = AppColors.text,
    );

    // Daqiqa chiziqchalari (har 5 daqiqada qalinroq).
    for (var i = 0; i < 60; i++) {
      final angle = i * pi / 30 - pi / 2;
      final dir = Offset(cos(angle), sin(angle));
      final big = i % 5 == 0;
      canvas.drawLine(
        center + dir * (r * (big ? 0.80 : 0.85)),
        center + dir * (r * 0.90),
        Paint()
          ..color = AppColors.text
          ..strokeWidth = big ? r * 0.025 : r * 0.01,
      );
    }

    // Raqamlar 1–12.
    for (var n = 1; n <= 12; n++) {
      final angle = n * pi / 6 - pi / 2;
      final painter = TextPainter(
        text: TextSpan(
          text: '$n',
          style: TextStyle(fontSize: r * 0.2, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = center + Offset(cos(angle), sin(angle)) * (r * 0.64);
      painter.paint(canvas, pos - Offset(painter.width / 2, painter.height / 2));
    }

    void hand(double angle, double length, double width, Color color) {
      canvas.drawLine(
        center,
        center + Offset(cos(angle), sin(angle)) * length,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    final minuteAngle = time.minute * pi / 30 - pi / 2;
    final hourAngle = ((time.hour % 12) + time.minute / 60) * pi / 6 - pi / 2;
    hand(hourAngle, r * 0.45, r * 0.09, _hourColor);
    hand(minuteAngle, r * 0.75, r * 0.05, _minuteColor);
    canvas.drawCircle(center, r * 0.07, Paint()..color = AppColors.text);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => oldDelegate.time != time;
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<ClockLevel> onSelected;

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
                for (final level in ClockLevel.values)
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

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
import 'geometry_game.dart';

const _gameId = 'geometry';

/// Geometriya: chizilgan shaklning perimetri, yuzi va noma'lum tomoni.
class GeometryScreen extends ConsumerStatefulWidget {
  const GeometryScreen({super.key});

  @override
  ConsumerState<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends ConsumerState<GeometryScreen> {
  GeometryGame? _game;
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int? _wrong;

  /// To'g'ri topilgan savol qisqa vaqt yashil holda ko'rsatiladi.
  GeometryQuestion? _solved;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(GeometryLevel level) {
    setState(() => _game = GeometryGame(level));
    _stopwatch
      ..reset()
      ..start();
  }

  void _onAnswer(int option) {
    final game = _game!;
    if (_solved != null || game.isFinished) return;

    final question = game.current;
    final outcome = game.answer(option);
    final sound = ref.read(soundServiceProvider);
    _timer?.cancel();

    switch (outcome) {
      case GeometryOutcome.wrong:
        sound.play(SoundService.tryAgain);
        setState(() => _wrong = option);
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _wrong = null);
        });
      case GeometryOutcome.correct:
        sound.play(SoundService.correct);
        setState(() {
          _wrong = null;
          _solved = question;
        });
        _timer = Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _solved = null);
        });
      case GeometryOutcome.finished:
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
      title: AppStrings.geometryTitle,
      color: AgeGroup.c.color,
      trailing: game == null
          ? null
          : Text(
              AppStrings.round(
                (game.step + (_solved == null ? 1 : 0)).clamp(1, GeometryGame.questionCount),
                GeometryGame.questionCount,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      child: game == null ? _LevelPicker(onSelected: _start) : _buildGame(game),
    );
  }

  Widget _buildGame(GeometryGame game) {
    final q = _solved ?? game.current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomPaint(painter: ShapePainter(q)),
              ),
              const SizedBox(height: 12),
              Text(
                _solved != null ? '${_format(q, q.answer)}  ✅' : _questionText(q),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: AppColors.text),
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
          childAspectRatio: 1.8,
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _format(q, option),
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
              ),
          ],
        ),
      ],
    );
  }
}

/// Javob birligi: perimetr va tomon — sm, yuz — sm².
String _format(GeometryQuestion q, int value) =>
    q.ask == GeoAsk.area ? AppStrings.cm2(value) : AppStrings.cm(value);

String _questionText(GeometryQuestion q) => switch (q.ask) {
  GeoAsk.perimeter => AppStrings.perimeterQuestion,
  GeoAsk.area => AppStrings.areaQuestion,
  GeoAsk.missingSide => AppStrings.missingSideQuestion(q.area),
};

/// Shaklni tomonlariga mutanosib chizadi; pastki tomon — eni, chap tomon — bo'yi.
/// Noma'lum tomon o'rnida "?" yoziladi.
class ShapePainter extends CustomPainter {
  ShapePainter(this.question);

  final GeometryQuestion question;

  @override
  void paint(Canvas canvas, Size size) {
    final q = question;
    const labelSpace = 56.0;
    final maxW = size.width - labelSpace * 2;
    final maxH = size.height - labelSpace;
    final unit = min(maxW / q.width, maxH / q.height);
    final w = q.width * unit;
    final h = q.height * unit;
    final rect = Rect.fromLTWH((size.width - w) / 2, (size.height - labelSpace / 2 - h) / 2, w, h);

    final path = Path();
    if (q.shape == GeoShape.rightTriangle) {
      path
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..close();
    } else {
      path.addRect(rect);
    }
    final stroke = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(path, Paint()..color = const Color(0xFFC8E6C9))
      ..drawPath(path, stroke);

    // To'g'ri burchak belgisi (pastki chap burchak).
    const mark = 14.0;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - mark)
        ..lineTo(rect.left + mark, rect.bottom - mark)
        ..lineTo(rect.left + mark, rect.bottom),
      stroke..strokeWidth = 2,
    );

    _label(canvas, AppStrings.cm(q.width), Offset(rect.center.dx, rect.bottom + 18));
    final heightText = q.ask == GeoAsk.missingSide ? '?' : AppStrings.cm(q.height);
    _label(canvas, heightText, Offset(rect.left - 30, rect.center.dy));
  }

  void _label(Canvas canvas, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => oldDelegate.question != question;
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.onSelected});

  final ValueChanged<GeometryLevel> onSelected;

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
                for (final level in GeometryLevel.values)
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

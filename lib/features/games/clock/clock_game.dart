import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Daraja: daqiqa qadami (butun soat, yarim soat, 5 daqiqa).
enum ClockLevel {
  hours(label: AppStrings.clockHours, emoji: '🕐', minuteStep: 60),
  halves(label: AppStrings.clockHalves, emoji: '🕧', minuteStep: 30),
  fives(label: AppStrings.clockFives, emoji: '🕔', minuteStep: 5);

  const ClockLevel({required this.label, required this.emoji, required this.minuteStep});

  final String label;
  final String emoji;
  final int minuteStep;

  /// Darajadagi barcha mumkin bo'lgan vaqtlar.
  List<ClockTime> get times => [
    for (var h = 1; h <= 12; h++)
      for (var m = 0; m < 60; m += minuteStep) ClockTime(h, m),
  ];

  bool allows(ClockTime t) => t.minute % minuteStep == 0;
}

/// Analog soatdagi vaqt: soat 1–12, daqiqa 0–55.
class ClockTime {
  const ClockTime(this.hour, this.minute);

  final int hour;
  final int minute;

  /// Soat ko'rsatkichini 1–12 oralig'ida aylantiradi (13 → 1, 0 → 12).
  factory ClockTime.wrap(int hour, int minute) => ClockTime((hour - 1) % 12 + 1, minute % 60);

  String get text => '$hour:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => text;
}

class ClockQuestion {
  const ClockQuestion(this.time, this.options);

  final ClockTime time;

  /// 4 ta variant matni ("3:30"), bittasi to'g'ri.
  final List<String> options;

  String get answer => time.text;
}

enum ClockOutcome { correct, wrong, finished }

/// Soat: analog soatga qarab vaqtni topish. 10 ta takrorlanmas savol.
class ClockGame {
  ClockGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    final times = level.times..shuffle(rnd);
    questions = [for (final t in times.take(questionCount)) makeQuestion(level, t, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final ClockLevel level;
  late final List<ClockQuestion> questions;
  int step = 0;
  int mistakes = 0;

  ClockQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  /// Chalg'ituvchi variantlar bolalarning odatiy xatolariga o'xshaydi:
  /// bir soat farq, boshqa daqiqa va ko'rsatkichlarni almashtirib o'qish.
  static ClockQuestion makeQuestion(ClockLevel level, ClockTime time, Random rnd) {
    final h = time.hour;
    final m = time.minute;
    final step = level.minuteStep;
    final near = <ClockTime>{
      ClockTime.wrap(h + 1, m),
      ClockTime.wrap(h - 1, m),
      ClockTime.wrap(h, m + step),
      ClockTime.wrap(h, m - step),
      // Ko'rsatkichlar almashtirilgan: daqiqa ko'rsatkichi soat deb o'qilgan.
      ClockTime.wrap(m == 0 ? 12 : m ~/ 5, h * 5),
    }.where((t) => t != time && level.allows(t)).toList()..shuffle(rnd);

    final options = <ClockTime>{time, ...near.take(optionCount - 1)};
    final all = level.times..shuffle(rnd);
    for (final t in all) {
      if (options.length == optionCount) break;
      options.add(t);
    }
    return ClockQuestion(time, [for (final t in options) t.text]..shuffle(rnd));
  }

  ClockOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return ClockOutcome.wrong;
    }
    step++;
    return isFinished ? ClockOutcome.finished : ClockOutcome.correct;
  }
}

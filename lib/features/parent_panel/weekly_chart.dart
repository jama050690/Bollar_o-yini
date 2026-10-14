import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'weekly_report.dart';

/// Oxirgi 7 kunlik o'yin vaqti — ustunli grafik. Oxirgi ustun — bugun.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.days, this.barColor = AppColors.primary});

  final List<DayMinutes> days;
  final Color barColor;

  static const _maxBarHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = days.fold(0, (m, d) => d.minutes > m ? d.minutes : m);
    final total = days.fold(0, (sum, d) => sum + d.minutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.weekTotal(total),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < days.length; i++)
              Expanded(
                child: _Bar(
                  day: days[i],
                  isToday: i == days.length - 1,
                  height: maxMinutes == 0 ? 0 : _maxBarHeight * days[i].minutes / maxMinutes,
                  color: barColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.isToday,
    required this.height,
    required this.color,
  });

  final DayMinutes day;
  final bool isToday;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = AppStrings.weekdaysShort[day.date.weekday - 1];

    return Semantics(
      label: AppStrings.dayMinutes(label, day.minutes),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                day.minutes > 0 ? '${day.minutes}' : '',
                style: const TextStyle(fontSize: 13, color: AppColors.text),
              ),
            ),
            const SizedBox(height: 2),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: height),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, h, _) => Container(
                // Bo'sh kunlar ham ko'rinsin — ingichka chiziq.
                height: h < 3 ? 3 : h,
                decoration: BoxDecoration(
                  color: isToday ? color : color.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fanlar bo'yicha o'rtacha yulduzlar va kuchli/zaif tomon.
class SubjectSummary extends StatelessWidget {
  const SubjectSummary({super.key, required this.scores});

  final List<SubjectScore> scores;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16, color: AppColors.text);
    final tips = strengths(scores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.subjectsTitle, style: style.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (scores.isEmpty)
          Text(AppStrings.subjectsEmpty, style: style)
        else
          for (final score in scores)
            Text(
              AppStrings.subjectStars(
                '${score.subject.emoji} ${score.subject.label}',
                score.averageStars.toStringAsFixed(1),
              ),
              style: style,
            ),
        if (tips != null) ...[
          const SizedBox(height: 6),
          Text(AppStrings.strongSubject(tips.strongest.label), style: style),
          Text(AppStrings.practiceSubject(tips.weakest.label), style: style),
        ],
      ],
    );
  }
}

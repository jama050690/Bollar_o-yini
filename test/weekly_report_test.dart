import 'package:aqlli_dostlar/core/constants/age_group.dart';
import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/features/games/game_catalog.dart';
import 'package:aqlli_dostlar/features/parent_panel/weekly_chart.dart';
import 'package:aqlli_dostlar/features/parent_panel/weekly_report.dart';
import 'package:aqlli_dostlar/features/progress/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GameProgress _p(int stars, {int plays = 1}) =>
    GameProgress(bestStars: stars, plays: plays, totalSeconds: 60);

void main() {
  group('weekMinutes', () {
    test("oxirgi 7 kunni eskidan bugungacha qaytaradi, oy chegarasida ham", () {
      final week = weekMinutes(
        'p1',
        {
          'p1|2026-10-01': 600,
          'p1|2026-09-28': 125,
          'p1|2026-09-24': 9999, // 8 kun oldin — kirmaydi
          'p2|2026-10-01': 300, // boshqa profil
        },
        DateTime(2026, 10, 1),
      );
      expect(week, hasLength(7));
      expect(week.first.date, DateTime(2026, 9, 25));
      expect(week.last.date, DateTime(2026, 10, 1));
      expect(week.last.minutes, 10);
      expect(week[3].minutes, 2);
      expect(week.fold(0, (s, d) => s + d.minutes), 12);
    });
  });

  group('subjectScores', () {
    test("katalogdagi har bir o'yin fanga biriktirilgan", () {
      final ids = [
        for (final group in AgeGroup.values) ...gamesFor(group).map((g) => g.id),
      ];
      for (final id in ids) {
        expect(kGameSubjects.containsKey(id), isTrue, reason: id);
      }
    });

    test("fan bo'yicha o'rtacha yulduz, o'ynalmagan fan va boshqa profil kirmaydi", () {
      final scores = subjectScores('p1', {
        'p1|arithmetic': _p(3),
        'p1|counting': _p(2),
        'p1|alphabets': _p(1),
        'p1|geo_quiz': _p(0, plays: 0),
        'p2|patterns': _p(3),
      });
      expect(scores.map((s) => s.subject), [Subject.math, Subject.language]);
      expect(scores.first.averageStars, 2.5);
      expect(scores.first.playedGames, 2);
    });

    test("kuchli/zaif tomon kamida 2 fan va farq bo'lsa chiqadi", () {
      final one = subjectScores('p1', {'p1|arithmetic': _p(3)});
      expect(strengths(one), isNull);

      final equal = subjectScores('p1', {'p1|arithmetic': _p(2), 'p1|alphabets': _p(2)});
      expect(strengths(equal), isNull);

      final mixed = subjectScores('p1', {
        'p1|arithmetic': _p(1),
        'p1|alphabets': _p(3),
        'p1|patterns': _p(2),
      });
      final tips = strengths(mixed)!;
      expect(tips.strongest, Subject.language);
      expect(tips.weakest, Subject.math);
    });
  });

  testWidgets("grafik va fanlar 360dp ekranda sig'adi", (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final week = weekMinutes('p1', {'p1|2026-10-14': 1800, 'p1|2026-10-12': 600},
        DateTime(2026, 10, 14));
    final scores = subjectScores('p1', {'p1|arithmetic': _p(1), 'p1|alphabets': _p(3)});

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [WeeklyChart(days: week), SubjectSummary(scores: scores)]),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.weekTotal(40)), findsOneWidget);
    expect(find.text('Ch'), findsOneWidget); // 14-oktabr 2026 — chorshanba
    expect(find.text('30'), findsOneWidget);
    expect(find.text(AppStrings.strongSubject(AppStrings.subjectLanguage)), findsOneWidget);
    expect(find.text(AppStrings.practiceSubject(AppStrings.subjectMath)), findsOneWidget);
  });

  testWidgets("hech narsa o'ynalmagan bo'lsa ham xatosiz chiqadi", (tester) async {
    final week = weekMinutes('p1', const {}, DateTime(2026, 10, 14));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [WeeklyChart(days: week), const SubjectSummary(scores: [])]),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.weekTotal(0)), findsOneWidget);
    expect(find.text(AppStrings.subjectsEmpty), findsOneWidget);
  });
}

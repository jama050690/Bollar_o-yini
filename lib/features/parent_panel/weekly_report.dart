import '../../core/constants/app_strings.dart';
import '../progress/progress_providers.dart';
import 'screen_time_providers.dart';

/// O'yinlar qaysi fanga tegishli (ota-ona hisoboti uchun).
enum Subject {
  math('🔢', AppStrings.subjectMath),
  language('🔤', AppStrings.subjectLanguage),
  logic('🧩', AppStrings.subjectLogic),
  creative('🎨', AppStrings.subjectCreative),
  world('🌍', AppStrings.subjectWorld);

  const Subject(this.emoji, this.label);

  final String emoji;
  final String label;
}

/// O'yin id → fan. Har bir o'yin aynan bitta fanga kiradi.
const kGameSubjects = {
  // Modul A
  'memory_match': Subject.logic,
  'letter_number': Subject.language,
  'shape_sorter': Subject.creative,
  'times_table': Subject.math,
  'alphabets': Subject.language,
  'counting': Subject.math,
  'shape_builder': Subject.creative,
  'coloring': Subject.creative,
  'match_pairs': Subject.logic,
  'patterns': Subject.logic,
  // Modul B
  'math_adventure': Subject.math,
  'word_builder': Subject.language,
  'maze_quiz': Subject.logic,
  'mini_sudoku': Subject.logic,
  'crossword': Subject.language,
  'arithmetic': Subject.math,
  'translate': Subject.language,
  'clock': Subject.math,
  'shop': Subject.math,
  'fractions': Subject.math,
  // Modul C
  'equations': Subject.math,
  'sequence': Subject.logic,
  'geometry': Subject.creative,
  'percent': Subject.math,
  'geo_quiz': Subject.world,
  'nature_quiz': Subject.world,
  'anagram': Subject.language,
  'translate_plus': Subject.language,
  'speed_math': Subject.math,
  'sudoku': Subject.logic,
};

/// Bir kunlik o'yin vaqti.
class DayMinutes {
  const DayMinutes(this.date, this.minutes);

  final DateTime date;
  final int minutes;
}

/// Oxirgi 7 kun (eskidan bugungacha) bo'yicha o'yin daqiqalari.
/// [screenTime] kalitlari: "profilId|yyyy-MM-dd" → soniya.
List<DayMinutes> weekMinutes(String profileId, Map<String, int> screenTime, DateTime today) {
  return [
    for (var i = 6; i >= 0; i--)
      () {
        final date = DateTime(today.year, today.month, today.day - i);
        final seconds = screenTime['$profileId|${dayKey(date)}'] ?? 0;
        return DayMinutes(date, seconds ~/ 60);
      }(),
  ];
}

/// Bitta fan bo'yicha natija: o'ynalgan o'yinlardagi eng yaxshi yulduzlarning o'rtachasi.
class SubjectScore {
  const SubjectScore(this.subject, this.averageStars, this.playedGames);

  final Subject subject;
  final double averageStars;
  final int playedGames;
}

/// Bola o'ynagan fanlar bo'yicha natijalar (o'ynalmagan fanlar kirmaydi).
/// [progress] kalitlari: "profilId|oyinId".
List<SubjectScore> subjectScores(String profileId, Map<String, GameProgress> progress) {
  final prefix = '$profileId|';
  final stars = <Subject, List<int>>{};
  for (final entry in progress.entries) {
    if (!entry.key.startsWith(prefix) || entry.value.plays == 0) continue;
    final subject = kGameSubjects[entry.key.substring(prefix.length)];
    if (subject == null) continue;
    (stars[subject] ??= []).add(entry.value.bestStars);
  }
  return [
    for (final subject in Subject.values)
      if (stars[subject] case final list?)
        SubjectScore(subject, list.reduce((a, b) => a + b) / list.length, list.length),
  ];
}

/// Kuchli va mashq kerak bo'lgan fan. Kamida 2 ta fan o'ynalgan va natijalar
/// farq qilgandagina beriladi — aks holda xulosa chiqarish erta.
({Subject strongest, Subject weakest})? strengths(List<SubjectScore> scores) {
  if (scores.length < 2) return null;
  final sorted = [...scores]..sort((a, b) => b.averageStars.compareTo(a.averageStars));
  if (sorted.first.averageStars == sorted.last.averageStars) return null;
  return (strongest: sorted.first.subject, weakest: sorted.last.subject);
}

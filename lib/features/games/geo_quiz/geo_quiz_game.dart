import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Bitta savol manbai. [wrong] bo'sh bo'lsa, noto'g'ri variantlar daraja [GeoLevel.pool]idan olinadi.
class GeoItem {
  const GeoItem(this.emoji, this.prompt, this.answer, {this.wrong = const []});

  final String emoji;

  /// Savol matni; poytaxt darajalarida — davlat nomi.
  final String prompt;
  final String answer;
  final List<String> wrong;
}

// dart format off
const _uzbekistanItems = [
  GeoItem('🏙️', 'Oʻzbekiston poytaxti qaysi?', 'Toshkent'),
  GeoItem('🗺️', 'Xorazm viloyati markazi qaysi?', 'Urganch'),
  GeoItem('🗺️', 'Qashqadaryo viloyati markazi qaysi?', 'Qarshi'),
  GeoItem('🗺️', 'Surxondaryo viloyati markazi qaysi?', 'Termiz'),
  GeoItem('🗺️', 'Sirdaryo viloyati markazi qaysi?', 'Guliston'),
  GeoItem('🗺️', 'Qoraqalpogʻiston poytaxti qaysi?', 'Nukus'),
  GeoItem('🕌', 'Registon maydoni qaysi shaharda?', 'Samarqand'),
  GeoItem('🏰', 'Ark qalʼasi qaysi shaharda?', 'Buxoro'),
  GeoItem('🧱', 'Ichan qalʼa qaysi shaharda?', 'Xiva'),
  GeoItem('🗼', 'Minorai Kalon qaysi shaharda?', 'Buxoro'),
  GeoItem('🏛️', 'Oqsaroy qaysi shaharda?', 'Shahrisabz'),
  GeoItem('🔢', 'Oʻzbekistonda nechta viloyat bor?', '12', wrong: ['10', '14', '7']),
  GeoItem('🏳️', 'Oʻzbekiston bayrogʻi qaysi?', '🇺🇿', wrong: ['🇰🇿', '🇹🇯', '🇹🇲']),
];

const _uzbekistanPool = [
  'Toshkent', 'Samarqand', 'Buxoro', 'Xiva', 'Urganch', 'Qarshi', 'Termiz', 'Guliston',
  'Nukus', 'Shahrisabz', 'Andijon', 'Namangan', 'Fargʻona', 'Jizzax', 'Navoiy',
];

/// Poytaxt darajalarida prompt — davlat nomi, emoji — bayroq.
const _asiaItems = [
  GeoItem('🇰🇿', 'Qozogʻiston', 'Astana'),
  GeoItem('🇰🇬', 'Qirgʻiziston', 'Bishkek'),
  GeoItem('🇹🇯', 'Tojikiston', 'Dushanbe'),
  GeoItem('🇹🇲', 'Turkmaniston', 'Ashxobod'),
  GeoItem('🇦🇫', 'Afgʻoniston', 'Kobul'),
  GeoItem('🇨🇳', 'Xitoy', 'Pekin'),
  GeoItem('🇯🇵', 'Yaponiya', 'Tokio'),
  GeoItem('🇰🇷', 'Janubiy Koreya', 'Seul'),
  GeoItem('🇮🇳', 'Hindiston', 'Dehli'),
  GeoItem('🇹🇷', 'Turkiya', 'Anqara'),
  GeoItem('🇮🇷', 'Eron', 'Tehron'),
  GeoItem('🇵🇰', 'Pokiston', 'Islomobod'),
  GeoItem('🇸🇦', 'Saudiya Arabistoni', 'Ar-Riyod'),
  GeoItem('🇲🇳', 'Mongoliya', 'Ulan-Bator'),
  GeoItem('🇹🇭', 'Tailand', 'Bangkok'),
  GeoItem('🇦🇪', 'BAA', 'Abu-Dabi'),
];

const _worldItems = [
  GeoItem('🇷🇺', 'Rossiya', 'Moskva'),
  GeoItem('🇫🇷', 'Fransiya', 'Parij'),
  GeoItem('🇩🇪', 'Germaniya', 'Berlin'),
  GeoItem('🇬🇧', 'Buyuk Britaniya', 'London'),
  GeoItem('🇮🇹', 'Italiya', 'Rim'),
  GeoItem('🇪🇸', 'Ispaniya', 'Madrid'),
  GeoItem('🇺🇸', 'AQSH', 'Vashington'),
  GeoItem('🇨🇦', 'Kanada', 'Ottava'),
  GeoItem('🇦🇺', 'Avstraliya', 'Kanberra'),
  GeoItem('🇪🇬', 'Misr', 'Qohira'),
  GeoItem('🇦🇷', 'Argentina', 'Buenos-Ayres'),
  GeoItem('🇲🇽', 'Meksika', 'Mexiko'),
  GeoItem('🇬🇷', 'Gretsiya', 'Afina'),
  GeoItem('🇵🇹', 'Portugaliya', 'Lissabon'),
  GeoItem('🇵🇱', 'Polsha', 'Varshava'),
  GeoItem('🇺🇦', 'Ukraina', 'Kiyev'),
];
// dart format on

/// Daraja: ① Oʻzbekiston shaharlari ② Osiyo poytaxtlari ③ dunyo poytaxtlari.
enum GeoLevel {
  uzbekistan(label: AppStrings.levelUzbekistan, emoji: '🇺🇿', items: _uzbekistanItems),
  asia(label: AppStrings.levelAsia, emoji: '🌏', items: _asiaItems, capitals: true),
  world(label: AppStrings.levelWorld, emoji: '🌍', items: _worldItems, capitals: true);

  const GeoLevel({
    required this.label,
    required this.emoji,
    required this.items,
    this.capitals = false,
  });

  final String label;
  final String emoji;
  final List<GeoItem> items;

  /// true — savol "Davlat poytaxti qaysi?" shaklida.
  final bool capitals;

  /// Noto'g'ri variantlar manbai.
  List<String> get pool =>
      capitals ? [for (final item in items) item.answer] : _uzbekistanPool;
}

class GeoQuestion {
  const GeoQuestion(this.emoji, this.text, this.answer, this.options);

  final String emoji;
  final String text;
  final String answer;
  final List<String> options;
}

enum GeoOutcome { correct, wrong, finished }

/// Geografiya kvizi: shaharlar, poytaxtlar, bayroqlar. 10 ta takrorlanmas savol.
class GeoQuizGame {
  GeoQuizGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    final items = List.of(level.items)..shuffle(rnd);
    questions = [for (final item in items.take(questionCount)) makeQuestion(level, item, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final GeoLevel level;
  late final List<GeoQuestion> questions;
  int step = 0;
  int mistakes = 0;

  GeoQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  static GeoQuestion makeQuestion(GeoLevel level, GeoItem item, Random rnd) {
    final text = level.capitals ? AppStrings.capitalOf(item.prompt) : item.prompt;
    final wrong = item.wrong.isNotEmpty
        ? List.of(item.wrong)
        : (level.pool.toSet()..remove(item.answer)).toList();
    wrong.shuffle(rnd);
    return GeoQuestion(
      item.emoji,
      text,
      item.answer,
      [item.answer, ...wrong.take(optionCount - 1)]..shuffle(rnd),
    );
  }

  GeoOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return GeoOutcome.wrong;
    }
    step++;
    return isFinished ? GeoOutcome.finished : GeoOutcome.correct;
  }
}

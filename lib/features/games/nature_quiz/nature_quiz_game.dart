import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// Savol: rasm, matn, to'g'ri javob va 3 ta noto'g'ri variant.
class NatureItem {
  const NatureItem(this.emoji, this.prompt, this.answer, this.wrong);

  final String emoji;
  final String prompt;
  final String answer;
  final List<String> wrong;
}

// dart format off
const _animalItems = [
  NatureItem('🐋', 'Eng katta hayvon qaysi?', 'Koʻk kit', ['Fil', 'Jirafa', 'Akula']),
  NatureItem('🦒', 'Eng baland boʻyli hayvon qaysi?', 'Jirafa', ['Fil', 'Tuya', 'Ot']),
  NatureItem('🐆', 'Eng tez yuguradigan hayvon qaysi?', 'Gepard', ['Sher', 'Ot', 'Quyon']),
  NatureItem('🦇', 'Qaysi sutemizuvchi ucha oladi?', 'Koʻrshapalak', ['Sincap', 'Kalamush', 'Mushuk']),
  NatureItem('🐧', 'Pingvinlar qayerda yashaydi?', 'Antarktida', ['Sahro', 'Oʻrmon', 'Togʻ']),
  NatureItem('🐸', 'Qurbaqaning bolasi nima deyiladi?', 'Itbaliq', ['Kuchuk', 'Qoʻzichoq', 'Joʻja']),
  NatureItem('🐻', 'Qishda uyquga ketadigan hayvon qaysi?', 'Ayiq', ['Boʻri', 'Tulki', 'Quyon']),
  NatureItem('🐪', 'Choʻlda suvsiz uzoq yura oladigan hayvon?', 'Tuya', ['Ot', 'Sigir', 'Fil']),
  NatureItem('🕷️', 'Oʻrgimchakning nechta oyogʻi bor?', '8', ['6', '4', '10']),
  NatureItem('🐝', 'Asal beradigan hasharot qaysi?', 'Asalari', ['Chivin', 'Kapalak', 'Chumoli']),
  NatureItem('🐬', 'Qaysi biri sutemizuvchi?', 'Delfin', ['Akula', 'Toshbaqa', 'Timsoh']),
  NatureItem('🦋', 'Kapalak avval kim boʻlgan?', 'Tirtil', ['Chivin', 'Qoʻngʻiz', 'Chumoli']),
  NatureItem('🦉', 'Kechasi ov qiladigan qush qaysi?', 'Boyqush', ['Chumchuq', 'Kabutar', 'Tovus']),
];

const _plantItems = [
  NatureItem('🌳', 'Daraxtlar havoga nima chiqaradi?', 'Kislorod', ['Tutun', 'Chang', 'Qum']),
  NatureItem('🌱', 'Oʻsimlik oʻsishi uchun nima kerak?', 'Suv va quyosh', ['Qorongʻilik', 'Tuz', 'Shakar']),
  NatureItem('🌵', 'Kaktus qayerda oʻsadi?', 'Choʻlda', ['Botqoqda', 'Muzlikda', 'Dengiz tubida']),
  NatureItem('🍂', 'Kuzda barglar qanday rangga kiradi?', 'Sariq', ['Koʻk', 'Oq', 'Binafsha']),
  NatureItem('🍎', 'Olma qayerda oʻsadi?', 'Daraxtda', ['Yer ostida', 'Suvda', 'Toshda']),
  NatureItem('🥔', 'Kartoshkaning yeyiladigan qismi qayerda?', 'Yer ostida', ['Shoxida', 'Gulida', 'Bargida']),
  NatureItem('🐝', 'Asalari guldan nima yigʻadi?', 'Nektar', ['Suv', 'Barg', 'Tuproq']),
  NatureItem('🌲', 'Qishda ham yashil turadigan daraxt?', 'Archa', ['Olma', 'Tut', 'Terak']),
  NatureItem('☁️', 'Oʻzbekistonning "oq oltini" nima?', 'Paxta', ['Bugʻdoy', 'Sholi', 'Makkajoʻxori']),
  NatureItem('🍞', 'Un va non nimadan tayyorlanadi?', 'Bugʻdoy', ['Paxta', 'Lavlagi', 'Kungaboqar']),
  NatureItem('🍃', 'Bargga yashil rang beradigan modda?', 'Xlorofill', ['Suv', 'Tuproq', 'Shakar']),
  NatureItem('🌷', 'Bahorda qirlarda ochiladigan yovvoyi qizil gul?', 'Lola', ['Atirgul', 'Kungaboqar', 'Moychechak']),
];

const _earthSkyItems = [
  NatureItem('🌈', 'Kamalakda nechta rang bor?', '7', ['5', '6', '9']),
  NatureItem('❄️', 'Suv necha gradusda muzlaydi?', '0 °C', ['10 °C', '100 °C', '50 °C']),
  NatureItem('♨️', 'Suv necha gradusda qaynaydi?', '100 °C', ['50 °C', '0 °C', '200 °C']),
  NatureItem('☀️', 'Yerga eng yaqin yulduz qaysi?', 'Quyosh', ['Oy', 'Qutb yulduzi', 'Sirius']),
  NatureItem('🌍', 'Yer Quyosh atrofini necha kunda aylanadi?', '365', ['30', '7', '100']),
  NatureItem('🌕', 'Oy Yerning nimasi?', 'Yoʻldoshi', ['Yulduzi', 'Kometasi', 'Buluti']),
  NatureItem('⚡', 'Chaqmoqdan keyin nima eshitiladi?', 'Momaqaldiroq', ['Shamol', 'Yomgʻir', 'Qor']),
  NatureItem('🌋', 'Ichidan lava otiladigan togʻ nima?', 'Vulqon', ['Muzlik', 'Vodiy', 'Orol']),
  NatureItem('🗓️', 'Bir yilda nechta fasl bor?', '4', ['2', '3', '12']),
  NatureItem('🍁', 'Barglar toʻkiladigan fasl qaysi?', 'Kuz', ['Bahor', 'Yoz', 'Qish']),
  NatureItem('🌸', 'Daraxtlar qaysi faslda gullaydi?', 'Bahor', ['Kuz', 'Qish', 'Yoz']),
  NatureItem('🌊', 'Eng katta okean qaysi?', 'Tinch okeani', ['Atlantika okeani', 'Hind okeani', 'Shimoliy Muz okeani']),
  NatureItem('🪐', 'Halqali sayyora qaysi?', 'Saturn', ['Mars', 'Venera', 'Merkuriy']),
  NatureItem('💧', 'Bulut nimadan iborat?', 'Suv tomchilari', ['Paxta', 'Tutun', 'Qum']),
];
// dart format on

/// Daraja: ① hayvonlar ② oʻsimliklar ③ Yer va osmon (fasllar, hodisalar, sayyoralar).
enum NatureLevel {
  animals(label: AppStrings.levelAnimals, emoji: '🐾', items: _animalItems),
  plants(label: AppStrings.levelPlants, emoji: '🌱', items: _plantItems),
  earthSky(label: AppStrings.levelEarthSky, emoji: '🌦️', items: _earthSkyItems);

  const NatureLevel({required this.label, required this.emoji, required this.items});

  final String label;
  final String emoji;
  final List<NatureItem> items;
}

class NatureQuestion {
  const NatureQuestion(this.emoji, this.text, this.answer, this.options);

  final String emoji;
  final String text;
  final String answer;
  final List<String> options;
}

enum NatureOutcome { correct, wrong, finished }

/// Tabiat kvizi: hayvonlar, oʻsimliklar, tabiat hodisalari. 10 ta takrorlanmas savol.
class NatureQuizGame {
  NatureQuizGame(this.level, {Random? random}) {
    final rnd = random ?? Random();
    final items = List.of(level.items)..shuffle(rnd);
    questions = [
      for (final item in items.take(questionCount))
        NatureQuestion(
          item.emoji,
          item.prompt,
          item.answer,
          [item.answer, ...item.wrong]..shuffle(rnd),
        ),
    ];
  }

  static const questionCount = 10;

  final NatureLevel level;
  late final List<NatureQuestion> questions;
  int step = 0;
  int mistakes = 0;

  NatureQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  NatureOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return NatureOutcome.wrong;
    }
    step++;
    return isFinished ? NatureOutcome.finished : NatureOutcome.correct;
  }
}

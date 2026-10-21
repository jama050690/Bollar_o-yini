import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';
import '../translate/translate_game.dart' show TargetLanguage;

/// O'zbekcha so'z/birikma/gap va uning ruscha, inglizcha, koreyscha, arabcha tarjimasi.
class PhraseItem {
  const PhraseItem(this.emoji, this.uzbek, this.russian, this.english, this.korean, this.arabic);

  final String emoji;
  final String uzbek;
  final String russian;
  final String english;
  final String korean;
  final String arabic;

  String translation(TargetLanguage language) => switch (language) {
        TargetLanguage.russian => russian,
        TargetLanguage.english => english,
        TargetLanguage.korean => korean,
        TargetLanguage.arabic => arabic,
      };
}

// dart format off
const _wordItems = [
  PhraseItem('🏫', 'maktab', 'школа', 'school', '학교', 'مدرسة'),
  PhraseItem('👩‍🏫', 'oʻqituvchi', 'учитель', 'teacher', '선생님', 'معلم'),
  PhraseItem('🤝', 'doʻst', 'друг', 'friend', '친구', 'صديق'),
  PhraseItem('👨‍👩‍👧', 'oila', 'семья', 'family', '가족', 'عائلة'),
  PhraseItem('🏙️', 'shahar', 'город', 'city', '도시', 'مدينة'),
  PhraseItem('🌞', 'kun', 'день', 'day', '낮', 'نهار'),
  PhraseItem('🌃', 'tun', 'ночь', 'night', '밤', 'ليل'),
  PhraseItem('🌷', 'bahor', 'весна', 'spring', '봄', 'ربيع'),
  PhraseItem('⛄', 'qish', 'зима', 'winter', '겨울', 'شتاء'),
  PhraseItem('🌧️', 'yomgʻir', 'дождь', 'rain', '비', 'مطر'),
  PhraseItem('🎒', 'sumka', 'сумка', 'bag', '가방', 'حقيبة'),
  PhraseItem('🚌', 'avtobus', 'автобус', 'bus', '버스', 'حافلة'),
  PhraseItem('📅', 'hafta', 'неделя', 'week', '일주일', 'أسبوع'),
  PhraseItem('🍳', 'nonushta', 'завтрак', 'breakfast', '아침 식사', 'فطور'),
  PhraseItem('🏥', 'kasalxona', 'больница', 'hospital', '병원', 'مستشفى'),
  PhraseItem('🗺️', 'xarita', 'карта', 'map', '지도', 'خريطة'),
  PhraseItem('🏖️', 'yoz', 'лето', 'summer', '여름', 'صيف'),
  PhraseItem('🍂', 'kuz', 'осень', 'autumn', '가을', 'خريف'),
  PhraseItem('☁️', 'bulut', 'облако', 'cloud', '구름', 'سحابة'),
  PhraseItem('🌬️', 'shamol', 'ветер', 'wind', '바람', 'رياح'),
  PhraseItem('🌊', 'dengiz', 'море', 'sea', '바다', 'بحر'),
  PhraseItem('⛰️', 'togʻ', 'гора', 'mountain', '산', 'جبل'),
  PhraseItem('🏞️', 'park', 'парк', 'park', '공원', 'حديقة'),
  PhraseItem('🏪', 'doʻkon', 'магазин', 'shop', '가게', 'متجر'),
  PhraseItem('🧑‍🎓', 'oʻquvchi', 'ученик', 'student', '학생', 'طالب'),
  PhraseItem('🧑‍⚕️', 'shifokor', 'врач', 'doctor', '의사', 'طبيب'),
  PhraseItem('👩', 'ona', 'мама', 'mother', '엄마', 'أم'),
  PhraseItem('👨', 'ota', 'папа', 'father', '아빠', 'أب'),
  PhraseItem('🎂', 'tugʻilgan kun', 'день рождения', 'birthday', '생일', 'عيد ميلاد'),
  PhraseItem('🎁', 'sovgʻa', 'подарок', 'gift', '선물', 'هدية'),
];

const _phraseItems = [
  PhraseItem('🍎', 'qizil olma', 'красное яблоко', 'red apple', '빨간 사과', 'تفاحة حمراء'),
  PhraseItem('🐱', 'kichkina mushuk', 'маленькая кошка', 'small cat', '작은 고양이', 'قطة صغيرة'),
  PhraseItem('🏠', 'katta uy', 'большой дом', 'big house', '큰 집', 'بيت كبير'),
  PhraseItem('🏎️', 'tez mashina', 'быстрая машина', 'fast car', '빠른 자동차', 'سيارة سريعة'),
  PhraseItem('☀️', 'issiq kun', 'жаркий день', 'hot day', '더운 날', 'يوم حار'),
  PhraseItem('❄️', 'sovuq qish', 'холодная зима', 'cold winter', '추운 겨울', 'شتاء بارد'),
  PhraseItem('📗', 'yangi kitob', 'новая книга', 'new book', '새 책', 'كتاب جديد'),
  PhraseItem('🌳', 'baland daraxt', 'высокое дерево', 'tall tree', '키 큰 나무', 'شجرة طويلة'),
  PhraseItem('💧', 'toza suv', 'чистая вода', 'clean water', '깨끗한 물', 'ماء نظيف'),
  PhraseItem('🐶', 'yaxshi it', 'хорошая собака', 'good dog', '착한 개', 'كلب طيب'),
  PhraseItem('🌸', 'chiroyli gul', 'красивый цветок', 'beautiful flower', '예쁜 꽃', 'زهرة جميلة'),
  PhraseItem('🍞', 'yumshoq non', 'мягкий хлеб', 'soft bread', '부드러운 빵', 'خبز طري'),
  PhraseItem('🌕', 'yorugʻ oy', 'яркая луна', 'bright moon', '밝은 달', 'قمر مضيء'),
  PhraseItem('🥛', 'iliq sut', 'тёплое молоко', 'warm milk', '따뜻한 우유', 'حليب دافئ'),
  PhraseItem('🐦', 'koʻk qush', 'синяя птица', 'blue bird', '파란 새', 'طائر أزرق'),
  PhraseItem('🐘', 'katta fil', 'большой слон', 'big elephant', '큰 코끼리', 'فيل كبير'),
  PhraseItem('🍉', 'shirin tarvuz', 'сладкий арбуз', 'sweet watermelon', '달콤한 수박', 'بطيخ حلو'),
  PhraseItem('🐈‍⬛', 'qora mushuk', 'чёрная кошка', 'black cat', '검은 고양이', 'قطة سوداء'),
  PhraseItem('🍌', 'sariq banan', 'жёлтый банан', 'yellow banana', '노란 바나나', 'موز أصفر'),
  PhraseItem('☁️', 'oq bulut', 'белое облако', 'white cloud', '하얀 구름', 'سحابة بيضاء'),
  PhraseItem('⛰️', 'baland togʻ', 'высокая гора', 'high mountain', '높은 산', 'جبل عالٍ'),
  PhraseItem('🌊', 'koʻk dengiz', 'синее море', 'blue sea', '파란 바다', 'بحر أزرق'),
  PhraseItem('🐟', 'kichkina baliq', 'маленькая рыбка', 'small fish', '작은 물고기', 'سمكة صغيرة'),
  PhraseItem('🌹', 'qizil gul', 'красный цветок', 'red flower', '빨간 꽃', 'زهرة حمراء'),
  PhraseItem('🍵', 'issiq choy', 'горячий чай', 'hot tea', '뜨거운 차', 'شاي ساخن'),
  PhraseItem('👗', 'yangi koʻylak', 'новое платье', 'new dress', '새 원피스', 'فستان جديد'),
  PhraseItem('🧒', 'aqlli bola', 'умный ребёнок', 'clever child', '똑똑한 아이', 'طفل ذكي'),
  PhraseItem('👩', 'mehribon ona', 'добрая мама', 'kind mother', '다정한 엄마', 'أم حنون'),
  PhraseItem('🛣️', 'uzun yoʻl', 'длинная дорога', 'long road', '긴 길', 'طريق طويل'),
  PhraseItem('🥖', 'mazali non', 'вкусный хлеб', 'tasty bread', '맛있는 빵', 'خبز لذيذ'),
];

const _sentenceItems = [
  PhraseItem('🏫', 'Men maktabga boraman.', 'Я иду в школу.', 'I go to school.', '나는 학교에 가요.', 'أنا أذهب إلى المدرسة.'),
  PhraseItem('📖', 'Men kitob oʻqiyman.', 'Я читаю книгу.', 'I read a book.', '나는 책을 읽어요.', 'أنا أقرأ كتابًا.'),
  PhraseItem('☀️', 'Bugun havo issiq.', 'Сегодня жарко.', 'It is hot today.', '오늘은 더워요.', 'الجو حار اليوم.'),
  PhraseItem('🐱', 'Mening mushugim bor.', 'У меня есть кошка.', 'I have a cat.', '나는 고양이가 있어요.', 'عندي قطة.'),
  PhraseItem('⚽', 'Biz futbol oʻynaymiz.', 'Мы играем в футбол.', 'We play football.', '우리는 축구를 해요.', 'نحن نلعب كرة القدم.'),
  PhraseItem('👋', 'Salom, isming nima?', 'Привет, как тебя зовут?', 'Hi, what is your name?', '안녕, 이름이 뭐야?', 'مرحبًا، ما اسمك؟'),
  PhraseItem('🙏', 'Katta rahmat!', 'Большое спасибо!', 'Thank you very much!', '정말 고마워요!', 'شكرًا جزيلًا!'),
  PhraseItem('🌙', 'Xayrli tun!', 'Спокойной ночи!', 'Good night!', '잘 자요!', 'تصبح على خير!'),
  PhraseItem('🍵', 'Men choy ichaman.', 'Я пью чай.', 'I drink tea.', '나는 차를 마셔요.', 'أنا أشرب الشاي.'),
  PhraseItem('👨‍👩‍👧', 'Bu mening oilam.', 'Это моя семья.', 'This is my family.', '이건 우리 가족이에요.', 'هذه عائلتي.'),
  PhraseItem('🎂', 'Men oʻn yoshdaman.', 'Мне десять лет.', 'I am ten years old.', '나는 열 살이에요.', 'عمري عشر سنوات.'),
  PhraseItem('🌧️', 'Yomgʻir yogʻyapti.', 'Идёт дождь.', 'It is raining.', '비가 와요.', 'إنها تمطر.'),
  PhraseItem('🏠', 'Mening uyim katta.', 'Мой дом большой.', 'My house is big.', '우리 집은 커요.', 'بيتي كبير.'),
  PhraseItem('🍎', 'Men olma yeyman.', 'Я ем яблоко.', 'I eat an apple.', '나는 사과를 먹어요.', 'أنا آكل تفاحة.'),
  PhraseItem('😺', 'Mushuk uxlayapti.', 'Кошка спит.', 'The cat is sleeping.', '고양이가 자고 있어요.', 'القطة نائمة.'),
  PhraseItem('💧', 'Men suv ichaman.', 'Я пью воду.', 'I drink water.', '나는 물을 마셔요.', 'أنا أشرب الماء.'),
  PhraseItem('🤝', 'Biz doʻstmiz.', 'Мы друзья.', 'We are friends.', '우리는 친구예요.', 'نحن أصدقاء.'),
  PhraseItem('🎨', 'Men rasm chizaman.', 'Я рисую.', 'I draw a picture.', '나는 그림을 그려요.', 'أنا أرسم صورة.'),
  PhraseItem('❄️', 'Qor yogʻyapti.', 'Идёт снег.', 'It is snowing.', '눈이 와요.', 'إنها تثلج.'),
  PhraseItem('❤️', 'Men onamni yaxshi koʻraman.', 'Я люблю маму.', 'I love my mom.', '나는 엄마를 사랑해요.', 'أنا أحب أمي.'),
  PhraseItem('🥶', 'Bugun havo sovuq.', 'Сегодня холодно.', 'It is cold today.', '오늘은 추워요.', 'الجو بارد اليوم.'),
  PhraseItem('🌅', 'Xayrli tong!', 'Доброе утро!', 'Good morning!', '좋은 아침이에요!', 'صباح الخير!'),
  PhraseItem('🙇', 'Kechirasiz!', 'Извините!', 'Sorry!', '미안해요!', 'آسف!'),
  PhraseItem('🏞️', 'Men parkka boraman.', 'Я иду в парк.', 'I go to the park.', '나는 공원에 가요.', 'أنا أذهب إلى الحديقة.'),
  PhraseItem('🐦', 'Qushlar uchyapti.', 'Птицы летят.', 'The birds are flying.', '새들이 날아요.', 'الطيور تطير.'),
  PhraseItem('🏠', 'Men uyga boraman.', 'Я иду домой.', 'I go home.', '나는 집에 가요.', 'أنا أذهب إلى البيت.'),
  PhraseItem('👋', 'Koʻrishguncha!', 'До встречи!', 'See you later!', '또 만나요!', 'إلى اللقاء!'),
  PhraseItem('🙋', 'Mening ismim Ali.', 'Меня зовут Али.', 'My name is Ali.', '내 이름은 알리예요.', 'اسمي علي.'),
  PhraseItem('🍏', 'Olma qizil.', 'Яблоко красное.', 'The apple is red.', '사과는 빨개요.', 'التفاحة حمراء.'),
  PhraseItem('😋', 'Juda mazali!', 'Очень вкусно!', 'It is very tasty!', '정말 맛있어요!', 'لذيذ جدًا!'),
];
// dart format on

/// Daraja: ① so'zlar ② so'z birikmalari ③ qisqa gaplar.
enum TranslatePlusLevel {
  words(emoji: '🔤', items: _wordItems),
  phrases(emoji: '🧩', items: _phraseItems),
  sentences(emoji: '💬', items: _sentenceItems);

  const TranslatePlusLevel({required this.emoji, required this.items});

  String get label => switch (this) {
        TranslatePlusLevel.words => AppStrings.levelWords,
        TranslatePlusLevel.phrases => AppStrings.levelPhrases,
        TranslatePlusLevel.sentences => AppStrings.levelSentences,
      };

  final String emoji;
  final List<PhraseItem> items;
}

class PhraseQuestion {
  const PhraseQuestion(this.item, this.answer, this.options);

  final PhraseItem item;
  final String answer;
  final List<String> options;
}

enum PhraseOutcome { correct, wrong, finished }

/// Tarjimon+: o'zbekcha so'z/birikma/gapning tarjimasini topish. 10 ta takrorlanmas savol.
class TranslatePlusGame {
  TranslatePlusGame(this.language, this.level, {Random? random}) {
    final rnd = random ?? Random();
    final items = List.of(level.items)..shuffle(rnd);
    questions = [for (final item in items.take(questionCount)) _question(item, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final TargetLanguage language;
  final TranslatePlusLevel level;
  late final List<PhraseQuestion> questions;
  int step = 0;
  int mistakes = 0;

  PhraseQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  PhraseQuestion _question(PhraseItem item, Random rnd) {
    final others = level.items.where((i) => i != item).toList()..shuffle(rnd);
    final answer = item.translation(language);
    return PhraseQuestion(
      item,
      answer,
      [answer, for (final o in others.take(optionCount - 1)) o.translation(language)]..shuffle(rnd),
    );
  }

  PhraseOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return PhraseOutcome.wrong;
    }
    step++;
    return isFinished ? PhraseOutcome.finished : PhraseOutcome.correct;
  }
}

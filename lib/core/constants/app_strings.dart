import 'app_language.dart';

/// Ilovadagi barcha UI matnlari bitta joyda: o'zbek, rus va ingliz tillarida (FR-8).
/// Til [AppStrings.current] orqali tanlanadi (uni appLanguageProvider o'rnatadi).
/// Tilga bog'liq bo'lmagan belgilar (+ − × ÷, 4×4 ...) `const` bo'lib qoladi.
///
/// Eslatma: o'yinlar ichidagi o'quv kontenti (so'zlar, savollar) hozircha o'zbek tilida.
abstract final class AppStrings {
  static AppLanguage current = AppLanguage.uz;

  static String _t(String uz, String ru, String en) => switch (current) {
        AppLanguage.uz => uz,
        AppLanguage.ru => ru,
        AppLanguage.en => en,
      };

  static List<String> _l(List<String> uz, List<String> ru, List<String> en) => switch (current) {
        AppLanguage.uz => uz,
        AppLanguage.ru => ru,
        AppLanguage.en => en,
      };

  static const appName = "Aqlli Do'stlar";

  // ---------- Til ----------
  static String get languageTitle => _t('🌐 Til', '🌐 Язык', '🌐 Language');
  static String get languageHint => _t(
        "Ilova tili. O'yinlardagi o'quv mashqlari o'zbek tilida qoladi",
        'Язык приложения. Учебные задания в играх остаются на узбекском',
        'App language. Learning tasks inside games stay in Uzbek',
      );

  // ---------- Profil ----------
  static String get createProfileTitle => _t('Yangi profil', 'Новый профиль', 'New profile');
  static String get nameLabel => _t('Isming nima?', 'Как тебя зовут?', "What's your name?");
  static String get nameHint => _t('Ismingni yoz', 'Напиши своё имя', 'Type your name');
  static String get ageLabel => _t('Yoshing nechida?', 'Сколько тебе лет?', 'How old are you?');
  static String get avatarLabel => _t("Do'stingni tanla", 'Выбери друга', 'Pick your buddy');
  static String get saveProfile => _t('Tayyor!', 'Готово!', 'Done!');
  static String get whoPlays => _t("Kim o'ynaydi?", 'Кто играет?', "Who's playing?");
  static String get addProfile => _t('Yangi', 'Новый', 'New');

  // ---------- Bosh menyu ----------
  static String hello(String name) => _t('Salom, $name!', 'Привет, $name!', 'Hi, $name!');
  static String get moduleATitle => _t('Kichkintoylar', 'Малыши', 'Little ones');
  static String get moduleBTitle => _t("O'rta guruh", 'Средняя группа', 'Middle group');
  static String get moduleCTitle => _t('Kattalar', 'Старшие', 'Big kids');
  static String ageRange(int min, int max) =>
      _t('$min-$max yosh', '$min-$max лет', '$min-$max years');
  static String lockedFor(int min, int max) =>
      _t('🔒 $min-$max yoshlilar uchun', '🔒 Для $min-$max лет', '🔒 For ages $min-$max');
  static String get comingSoon =>
      _t("Tez orada yangi o'yinlar! 🚀", 'Скоро новые игры! 🚀', 'New games coming soon! 🚀');

  // ---------- O'yinlar ----------
  static String get memoryTitle => _t('Xotira', 'Память', 'Memory');
  static String get letterNumberTitle => _t('Harf-Raqam', 'Буквы-Цифры', 'Letters & Numbers');
  static String get shapeSorterTitle => _t('Rang-Shakl', 'Цвет и форма', 'Colors & Shapes');

  static String get chooseLevel => _t('Darajani tanla', 'Выбери уровень', 'Choose a level');
  static String get levelEasy => _t('Oson', 'Легко', 'Easy');
  static String get levelMedium => _t("O'rta", 'Средне', 'Medium');
  static String get levelHard => _t('Qiyin', 'Сложно', 'Hard');

  static String get chooseMode => _t("Nimani o'ynaymiz?", 'Во что играем?', 'What shall we play?');
  static String get modeNumbers => _t('Raqamlar', 'Цифры', 'Numbers');
  static String get modeLetters => _t('Harflar', 'Буквы', 'Letters');
  static String get findThis => _t('Buni top:', 'Найди это:', 'Find this:');

  static String get sortByColor =>
      _t('Ranglariga qarab sarala', 'Разложи по цвету', 'Sort by color');
  static String get sortByShape =>
      _t('Shakliga qarab sarala', 'Разложи по форме', 'Sort by shape');

  // ---------- Modul A (qo'shimcha) ----------
  static String get timesTableTitle => _t('Karra jadvali', 'Таблица умножения', 'Times tables');
  static String timesLevel(int max) => '×1 – ×$max';

  static String get alphabetsTitle => _t('Alifbolar', 'Алфавиты', 'Alphabets');
  static String get chooseAlphabet => _t('Alifboni tanla', 'Выбери алфавит', 'Choose an alphabet');
  static String get findLetter => _t('Qaysi harf?', 'Какая буква?', 'Which letter?');

  static String get countingTitle => _t('Sanash', 'Счёт', 'Counting');
  static String get chooseLanguage => _t('Tilni tanla', 'Выбери язык', 'Choose a language');
  static String get findNumber => _t('Qaysi son?', 'Какое число?', 'Which number?');

  static String get langUzbek => _t('Oʻzbek', 'Узбекский', 'Uzbek');
  static String get langRussian => _t('Rus', 'Русский', 'Russian');
  static String get langEnglish => _t('Ingliz', 'Английский', 'English');

  static String get shapeBuilderTitle =>
      _t('Shakldan buyum', 'Собери из фигур', 'Build with shapes');
  static String get dragShapes =>
      _t('Shakllarni joyiga sudra', 'Перетащи фигуры на место', 'Drag the shapes into place');
  static String get objHouse => _t('Uy', 'Дом', 'House');
  static String get objCar => _t('Mashina', 'Машина', 'Car');
  static String get objTree => _t('Daraxt', 'Дерево', 'Tree');
  static String get objRocket => _t('Raketa', 'Ракета', 'Rocket');
  static String get objCat => _t('Mushuk', 'Кошка', 'Cat');

  static String get coloringTitle => _t("Rasm bo'yash", 'Раскраска', 'Coloring');
  static String get choosePicture => _t('Rasmni tanla', 'Выбери картинку', 'Choose a picture');
  static String get coloringHint => _t(
        'Rangni tanla va rasmni bos',
        'Выбери цвет и нажми на картинку',
        'Pick a color and tap the picture',
      );
  static String get coloringDone => _t('Tayyor! ✅', 'Готово! ✅', 'Done! ✅');
  static String get clearAll => _t('Tozalash', 'Очистить', 'Clear');
  static String get picBalloons => _t('Sharlar', 'Шарики', 'Balloons');
  static String get picApple => _t('Olma', 'Яблоко', 'Apple');
  static String get picPear => _t('Nok', 'Груша', 'Pear');
  static String get picStrawberry => _t('Qulupnay', 'Клубника', 'Strawberry');
  static String get picCat => _t('Mushuk', 'Кошка', 'Cat');
  static String get picFish => _t('Baliq', 'Рыбка', 'Fish');
  static String get picButterfly => _t('Kapalak', 'Бабочка', 'Butterfly');
  static String get picHouse => _t('Uy', 'Дом', 'House');
  static String get picStar => _t('Yulduz', 'Звезда', 'Star');
  static String get picFlower => _t('Gul', 'Цветок', 'Flower');

  static String get matchPairsTitle => _t('Juftini top', 'Найди пару', 'Find the pair');
  static String get findPair => _t('Juftini top:', 'Найди пару:', 'Find the pair:');
  static String get pairsFood => _t('Ovqati', 'Еда', 'Food');
  static String get pairsTools => _t('Asbobi', 'Инструменты', 'Tools');
  static String get pairsMixed => _t('Aralash', 'Вперемешку', 'Mixed');

  static String get patternsTitle => _t('Naqsh', 'Узоры', 'Patterns');
  static String get continuePattern => _t('Nima keladi?', 'Что дальше?', 'What comes next?');

  // ---------- Modul B ----------
  static String get mathTitle =>
      _t('Matematik sarguzasht', 'Математическое приключение', 'Math adventure');
  static String upTo(int max) => _t('$max gacha', 'до $max', 'up to $max');

  static String get wordBuilderTitle => _t("So'z quramchisi", 'Собери слово', 'Word builder');
  static String get buildWord =>
      _t("Harflardan so'z yig'", 'Собери слово из букв', 'Make a word from the letters');

  static String get mazeQuizTitle => _t('Labirint-kviz', 'Лабиринт-викторина', 'Maze quiz');
  static String get mazeHint => _t(
        '🚪 Eshikdagi savolga javob ber!',
        '🚪 Ответь на вопрос у двери!',
        '🚪 Answer the question at the door!',
      );

  static String get sudokuTitle => _t('Mini-Sudoku', 'Мини-судоку', 'Mini Sudoku');
  static String get sudokuRule => _t(
        'Har qator, ustun va diagonal = 15',
        'Каждая строка, столбец и диагональ = 15',
        'Every row, column and diagonal = 15',
      );
  static String get sudokuPickCell =>
      _t("Bo'sh katakni tanla", 'Выбери пустую клетку', 'Pick an empty cell');

  static String get crosswordTitle => _t('Mini-krossvord', 'Мини-кроссворд', 'Mini crossword');
  static String wordsCount(int n) => _t("$n ta so'z", '$n слов', '$n words');
  static String get crosswordHint => _t(
        "Rasmni bos, so'ng harflarni tanla",
        'Нажми на картинку, потом выбери буквы',
        'Tap a picture, then pick the letters',
      );

  static String get arithmeticTitle => _t('Arifmetika', 'Арифметика', 'Arithmetic');
  static const levelAddSub = '+  −';
  static const levelMulDiv = '×  ÷';
  static const levelMixed = '+ − × ÷';

  static String get translateTitle => _t('Tarjimon', 'Переводчик', 'Translator');
  static String get translateHint => _t('Tarjimasini top:', 'Найди перевод:', 'Find the translation:');
  static String get translateReverseHint =>
      _t("O'zbekchasini top:", 'Найди по-узбекски:', 'Find it in Uzbek:');
  static String get levelReverse => _t('Teskari', 'Наоборот', 'Reverse');
  static String optionsCount(int n) => _t('$n ta variant', '$n варианта', '$n options');

  static String get wordLevelShort => _t('3–4 harf', '3–4 буквы', '3–4 letters');
  static String get wordLevelMedium => _t('5 harf', '5 букв', '5 letters');
  static String get wordLevelLong => _t('6+ harf', '6+ букв', '6+ letters');

  static String mazeSize(int n) => '$n×$n';

  static String get clockTitle => _t('Soat', 'Часы', 'Clock');
  static String get whatTime => _t('Soat necha?', 'Который час?', 'What time is it?');
  static String get clockHours => _t('Butun soat', 'Ровные часы', "O'clock");
  static String get clockHalves => _t('Yarim soat', 'Полчаса', 'Half past');
  static String get clockFives => _t('5 daqiqa', '5 минут', '5 minutes');

  static String get shopTitle => _t("Do'kon", 'Магазин', 'Shop');
  static String get shopTotal =>
      _t('Hammasi necha pul?', 'Сколько стоит всё вместе?', 'How much is it all?');
  static String get shopChange => _t('Qaytim qancha?', 'Какая сдача?', 'How much change?');
  static String get shopLevelTwo => _t('2 ta narsa', '2 товара', '2 items');
  static String get shopLevelThree => _t('3 ta narsa', '3 товара', '3 items');
  static String get shopLevelChange => _t('Qaytim', 'Сдача', 'Change');
  static String som(int thousands) =>
      _t("$thousands 000 so'm", '$thousands 000 сум', '$thousands 000 soum');
  static String shopPaid(int thousands) => _t(
        "💵 Berildi: $thousands 000 so'm",
        '💵 Дали: $thousands 000 сум',
        '💵 Paid: $thousands 000 soum',
      );

  static String get fractionsTitle => _t('Kasrlar', 'Дроби', 'Fractions');
  static String get whichFraction =>
      _t('Qancha qismi rangli?', 'Какая часть закрашена?', 'How much is colored?');
  static String get whichBigger => _t('Qaysi biri katta?', 'Что больше?', 'Which is bigger?');
  static const fracBasic = '½  ⅓  ¼';
  static const fracMore = '⅕ … ⅛';
  static String get fracCompare => _t('Solishtir', 'Сравни', 'Compare');

  // ---------- Modul C ----------
  static String get equationsTitle => _t('Tenglamalar', 'Уравнения', 'Equations');
  static String get findX => _t('x nechaga teng?', 'Чему равен x?', 'What is x?');
  static const levelEqAdd = 'x + a = b';
  static const levelEqMul = 'a · x = b';
  static const levelEqTwo = 'a · x + b = c';

  static String get sequenceTitle => _t('Ketma-ketlik', 'Последовательность', 'Sequences');
  static String get nextNumber =>
      _t('Keyingi son qaysi?', 'Какое число следующее?', 'What number comes next?');
  static const levelSeqPlus = '+  −';
  static const levelSeqTimes = '×2  ×3';
  static String get levelSeqTricky => _t('Qiyin naqsh', 'Хитрый узор', 'Tricky pattern');

  static String get geometryTitle => _t('Geometriya', 'Геометрия', 'Geometry');
  static String get perimeterQuestion =>
      _t('Perimetri nechaga teng?', 'Чему равен периметр?', 'What is the perimeter?');
  static String get areaQuestion =>
      _t('Yuzi nechaga teng?', 'Чему равна площадь?', 'What is the area?');
  static String missingSideQuestion(int area) => _t(
        'Yuzi $area sm². "?" nechaga teng?',
        'Площадь $area см². Чему равен «?»?',
        'The area is $area cm². What is "?"?',
      );
  static String get levelPerimeter => _t('Perimetr', 'Периметр', 'Perimeter');
  static String get levelArea => _t('Yuz', 'Площадь', 'Area');
  static String get levelGeoMix => _t('Uchburchak', 'Треугольник', 'Triangle');
  static String cm(int n) => _t('$n sm', '$n см', '$n cm');
  static String cm2(int n) => _t('$n sm²', '$n см²', '$n cm²');

  static String get percentTitle => _t('Foizlar', 'Проценты', 'Percentages');
  static String percentOf(int n, int p) => _t('$n ning $p% i', '$p% от $n', '$p% of $n');
  static String discount(int p) => _t('🏷️ −$p% chegirma', '🏷️ Скидка −$p%', '🏷️ −$p% off');
  static String get newPrice => _t('Yangi narx qancha?', 'Какая новая цена?', "What's the new price?");
  static const levelPercentEasy = '50%  25%  10%';
  static const levelPercentMore = '5% … 75%';
  static String get levelDiscount => _t('Chegirma', 'Скидка', 'Discount');

  static String get geoTitle => _t('Geografiya', 'География', 'Geography');
  static String get levelUzbekistan => _t('Oʻzbekiston', 'Узбекистан', 'Uzbekistan');
  static String get levelAsia => _t('Osiyo', 'Азия', 'Asia');
  static String get levelWorld => _t('Dunyo', 'Мир', 'World');
  static String capitalOf(String country) =>
      _t('$country poytaxti qaysi?', 'Столица: $country?', 'Capital of $country?');

  static String get natureTitle => _t('Tabiat', 'Природа', 'Nature');
  static String get levelAnimals => _t('Hayvonlar', 'Животные', 'Animals');
  static String get levelPlants => _t('Oʻsimliklar', 'Растения', 'Plants');
  static String get levelEarthSky => _t('Yer va osmon', 'Земля и небо', 'Earth and sky');

  static String get anagramTitle => _t('Anagramma', 'Анаграмма', 'Anagram');
  static String get anagramHint =>
      _t("Harflardan so'z tuz", 'Составь слово из букв', 'Make a word from the letters');
  static String get anagramRemove => _t(
        'Harfni qaytarish uchun ustiga bos',
        'Нажми на букву, чтобы вернуть её',
        'Tap a letter to take it back',
      );
  static String get anagram5 => _t('5 harf', '5 букв', '5 letters');
  static String get anagram67 => _t('6–7 harf', '6–7 букв', '6–7 letters');
  static String get anagram8 => _t('8+ harf', '8+ букв', '8+ letters');
  static String get catAnimal => _t('🐾 Hayvon', '🐾 Животное', '🐾 Animal');
  static String get catFood => _t('🍎 Taom va meva', '🍎 Еда и фрукты', '🍎 Food and fruit');
  static String get catNature => _t('🌍 Tabiat', '🌍 Природа', '🌍 Nature');
  static String get catSchool => _t('🎒 Maktab', '🎒 Школа', '🎒 School');
  static String get catHome => _t('🏠 Uy', '🏠 Дом', '🏠 Home');
  static String get catTransport => _t('🚗 Transport', '🚗 Транспорт', '🚗 Transport');
  static String get catJob => _t('👷 Kasb', '👷 Профессия', '👷 Job');

  static String get translatePlusTitle => _t('Tarjimon+', 'Переводчик+', 'Translator+');
  static String get levelWords => _t("So'zlar", 'Слова', 'Words');
  static String get levelPhrases => _t('Birikmalar', 'Словосочетания', 'Phrases');
  static String get levelSentences => _t('Gaplar', 'Предложения', 'Sentences');

  static String get speedMathTitle => _t('Tez hisob', 'Быстрый счёт', 'Speed math');
  static String get speedHint => _t(
        "60 soniyada iloji boricha ko'p yech!",
        'Реши как можно больше за 60 секунд!',
        'Solve as many as you can in 60 seconds!',
      );
  static String secondsLeft(int s) => '⏱ $s';
  static String correctCount(int n) => '✅ $n';

  static String get sudokuBigTitle => _t('Sudoku', 'Судоку', 'Sudoku');
  static String get sudokuBigRule => _t(
        'Qator, ustun va qutida raqam takrorlanmasin',
        'Цифры не повторяются в строке, столбце и квадрате',
        'No repeats in any row, column or box',
      );
  static String get level4Easy => _t('4×4 oson', '4×4 легко', '4×4 easy');
  static String get level4Hard => _t('4×4 qiyin', '4×4 сложно', '4×4 hard');
  static const level6 = '6×6';

  static String get codingTitle => _t('Robot dasturchi', 'Робот-программист', 'Robot coder');
  static String get codingHint => _t(
        '🤖 Robotni 🔋 gacha olib bor!',
        '🤖 Доведи робота до 🔋!',
        '🤖 Get the robot to the 🔋!',
      );
  static String get codingLoopHint => _t(
        '🤖 Bloklar kam — 🔁 dan foydalan!',
        '🤖 Блоков мало — используй 🔁!',
        '🤖 Few blocks — use 🔁!',
      );
  static String get codingForward => _t('Oldinga', 'Вперёд', 'Forward');
  static String get codingLeft => _t('Chapga', 'Налево', 'Left');
  static String get codingRight => _t("O'ngga", 'Направо', 'Right');
  static String get codingLoop => _t('Takrorla', 'Повтори', 'Repeat');
  static String get codingProgram => _t('📜 Dastur', '📜 Программа', '📜 Program');
  static String get codingLoopBody =>
      _t('🔁 Nimani takrorlaymiz', '🔁 Что повторяем', '🔁 What to repeat');
  static String get codingRun => _t('Ishga tushir', 'Запустить', 'Run');
  static String get codingUndo => _t("O'chir", 'Стереть', 'Undo');
  static String get codingClear => _t('Tozala', 'Очистить', 'Clear');
  static String codingBlocks(int used, int max) =>
      _t('Bloklar: $used / $max', 'Блоки: $used / $max', 'Blocks: $used / $max');
  static String codingLoopTimes(int count) =>
      _t('$count marta takrorla', 'Повторить $count раз', 'Repeat $count times');
  static String get codingCrash => _t(
        "💥 To'siq! Dasturni tuzatib ko'r",
        '💥 Препятствие! Исправь программу',
        '💥 Obstacle! Fix your program',
      );
  static String get codingNotReached => _t(
        "🔋 gacha yetmadi. Dasturni to'ldir!",
        'Робот не дошёл до 🔋. Дополни программу!',
        "Didn't reach the 🔋. Add to your program!",
      );

  static String round(int current, int total) => '$current / $total';
  static String get tryAgain =>
      _t("Yana urinib ko'r! 💪", 'Попробуй ещё раз! 💪', 'Try again! 💪');
  static String get wellDone => _t('Barakalla! 🎉', 'Молодец! 🎉', 'Well done! 🎉');

  // ---------- Ekran o'quvchi (TalkBack / VoiceOver) uchun yozuvlar ----------
  static String starsLabel(int stars) =>
      _t('3 dan $stars yulduz', 'Звёзд: $stars из 3', '$stars of 3 stars');
  static String get homeButtonLabel => _t('Bosh menyu', 'Главное меню', 'Main menu');
  static String get switchProfileLabel =>
      _t('Profilni almashtirish', 'Сменить профиль', 'Switch profile');
  static String cellLabel(int row, int col, String? value) => _t(
        "$row-qator, $col-ustun, ${value ?? "bo'sh"}",
        'Строка $row, столбец $col, ${value ?? 'пусто'}',
        'Row $row, column $col, ${value ?? 'empty'}',
      );
  static String get hiddenCardLabel => _t('Yopiq karta', 'Закрытая карточка', 'Hidden card');
  static String colorLabel(int n) => _t('$n-rang', 'Цвет $n', 'Color $n');
  static String get coloringPictureLabel =>
      _t("Bo'yash rasmi", 'Картинка для раскрашивания', 'Coloring picture');
  static String get listenLabel => _t('Ovozni eshitish', 'Послушать', 'Listen');
  static String get listenAgainLabel =>
      _t("So'zni qayta eshitish", 'Прослушать слово ещё раз', 'Listen to the word again');

  // ---------- Kutilmagan xato (bolani qo'rqitmaydigan ekran) ----------
  static String get errorTitle =>
      _t('Voy, nimadir chalkashdi! 🙈', 'Ой, что-то запуталось! 🙈', 'Oops, something got mixed up! 🙈');
  static String get errorHint => _t(
        'Xavotir olma, qaytadan boshlaymiz!',
        'Не волнуйся, начнём сначала!',
        "Don't worry, let's start again!",
      );
  static String get errorHomeButton => _t('🏠 Bosh menyuga', '🏠 В главное меню', '🏠 Main menu');
  static String get errorRetryButton => _t('🔄 Qayta urinish', '🔄 Попробовать снова', '🔄 Try again');

  // ---------- Natija ----------
  static String get result3 => _t('Ajoyib! 🎉', 'Великолепно! 🎉', 'Amazing! 🎉');
  static String get result2 => _t("Zo'r! 👏", 'Здорово! 👏', 'Great! 👏');
  static String get result1 => _t(
        "Yaxshi! Yana o'ynaymizmi? 💪",
        'Хорошо! Сыграем ещё? 💪',
        'Good! Play again? 💪',
      );
  static String get playAgain => _t("Yana o'ynash", 'Играть ещё', 'Play again');
  static String get toHome => _t('Bosh menyu', 'Главное меню', 'Main menu');

  static String duration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return _t('⏱ $seconds soniya', '⏱ $seconds сек', '⏱ $seconds sec');
    return _t(
      '⏱ $minutes daqiqa $seconds soniya',
      '⏱ $minutes мин $seconds сек',
      '⏱ $minutes min $seconds sec',
    );
  }

  // ---------- Ota-ona paneli (FR-6, FR-7) ----------
  static String get parentPanelTitle =>
      _t('Ota-ona paneli', 'Панель для родителей', 'Parent panel');
  static String get parentEntry => _t('Ota-ona uchun 🔒', 'Для родителей 🔒', 'For parents 🔒');

  static String get pinEnter => _t('PIN kodni kiriting', 'Введите PIN-код', 'Enter PIN');
  static String get pinCreate =>
      _t("Yangi PIN kod o'ylab toping", 'Придумайте новый PIN-код', 'Create a new PIN');
  static String get pinConfirm =>
      _t('PIN kodni yana bir marta kiriting', 'Введите PIN-код ещё раз', 'Enter the PIN again');
  static String get pinWrong => _t(
        "PIN noto'g'ri. Qayta urinib ko'ring",
        'Неверный PIN. Попробуйте ещё раз',
        'Wrong PIN. Please try again',
      );
  static String get pinMismatch => _t(
        'PIN kodlar mos kelmadi. Boshidan kiriting',
        'PIN-коды не совпали. Введите заново',
        "PINs don't match. Start over",
      );
  static String get pinForgot => _t('PIN ni unutdim', 'Забыл PIN', 'Forgot PIN');
  static String get pinChange => _t("PIN ni o'zgartirish", 'Сменить PIN', 'Change PIN');
  static String get pinChanged => _t("PIN o'zgartirildi ✅", 'PIN изменён ✅', 'PIN changed ✅');
  static String get pinDelete => _t("O'chirish", 'Стереть', 'Delete');
  static String adultQuestion(int a, int b) => _t(
        'Kattalar uchun savol: $a × $b = ?',
        'Вопрос для взрослых: $a × $b = ?',
        'Question for adults: $a × $b = ?',
      );
  static String get parentGateTitle =>
      _t("Bu bo'lim kattalar uchun", 'Этот раздел для взрослых', 'This section is for grown-ups');
  static String get parentGateHint => _t(
        'Davom etish uchun kattalar savoliga javob bering',
        'Чтобы продолжить, ответьте на вопрос для взрослых',
        'To continue, answer a question for adults',
      );
  static String get parentGateButton => _t('Men kattaman ➡️', 'Я взрослый ➡️', "I'm a grown-up ➡️");
  static String get adultAnswerHint => _t('Javob', 'Ответ', 'Answer');
  static String get adultWrong => _t("Javob noto'g'ri", 'Неверный ответ', 'Wrong answer');
  static String get cancel => _t('Bekor qilish', 'Отмена', 'Cancel');
  static String get confirm => _t('Tasdiqlash', 'Подтвердить', 'Confirm');

  static String get dailyLimitTitle =>
      _t("Kunlik o'yin vaqti", 'Время игры в день', 'Daily play time');
  static String get dailyLimitHint => _t(
        "Vaqt tugaganda ilova bolaga muloyim eslatma ko'rsatadi",
        'Когда время закончится, ребёнок увидит мягкое напоминание',
        'When time is up, your child sees a gentle reminder',
      );
  static String get limitOff => _t("O'chiq", 'Выкл.', 'Off');
  static String minutesShort(int m) => _t('$m daq', '$m мин', '$m min');

  static String get soundSettingsTitle => _t('Ovoz', 'Звук', 'Sound');
  static String get soundEffects => _t("🔔 O'yin ovozlari", '🔔 Звуки игры', '🔔 Game sounds');
  static String get soundEffectsHint => _t(
        "To'g'ri javob va g'alaba ovozlari",
        'Звуки правильного ответа и победы',
        'Right-answer and victory sounds',
      );
  static String get ttsReading => _t("🗣️ Ovozli o'qish", '🗣️ Озвучка', '🗣️ Read aloud');
  static String get ttsReadingHint => _t(
        "So'z va savollarni ovoz chiqarib o'qiydi",
        'Читает слова и вопросы вслух',
        'Reads words and questions out loud',
      );

  static String get reportTitle => _t('Hisobot', 'Отчёт', 'Report');
  static String get reportEmpty => _t("Hali profil yo'q", 'Профилей пока нет', 'No profiles yet');
  static String todayTime(int minutes) =>
      _t('Bugun: $minutes daqiqa', 'Сегодня: $minutes мин', 'Today: $minutes min');
  static String totalPlays(int n) => _t("O'yinlar: $n marta", 'Игр: $n', 'Games played: $n');
  static String totalStars(int n) => _t('Yulduzlar: $n ⭐', 'Звёзды: $n ⭐', 'Stars: $n ⭐');
  static String totalTime(int minutes) => _t(
        "Jami o'yin vaqti: $minutes daqiqa",
        'Всего времени в игре: $minutes мин',
        'Total play time: $minutes min',
      );
  static String get favoriteGames =>
      _t("Eng ko'p o'ynagani:", 'Любимые игры:', 'Favorite games:');

  // Haftalik grafik va fanlar
  static List<String> get weekdaysShort => _l(
        const ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'],
        const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
        const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
      );
  static String weekTotal(int minutes) => _t(
        'Oxirgi 7 kun: $minutes daqiqa',
        'Последние 7 дней: $minutes мин',
        'Last 7 days: $minutes min',
      );
  static String dayMinutes(String day, int minutes) =>
      _t('$day: $minutes daqiqa', '$day: $minutes мин', '$day: $minutes min');
  static String get subjectsTitle => _t(
        "Fanlar bo'yicha (o'rtacha ⭐):",
        'По предметам (в среднем ⭐):',
        'By subject (average ⭐):',
      );
  static String get subjectsEmpty =>
      _t("Hali o'ynalmagan", 'Ещё не играл(а)', 'Not played yet');
  static String subjectStars(String subject, String stars) => '$subject — $stars ⭐';
  static String strongSubject(String subject) => _t(
        '💪 Kuchli tomoni: $subject',
        '💪 Сильная сторона: $subject',
        '💪 Strongest: $subject',
      );
  static String practiceSubject(String subject) => _t(
        "🌱 Ko'proq mashq kerak: $subject",
        '🌱 Нужно больше практики: $subject',
        '🌱 Needs more practice: $subject',
      );
  static String get subjectMath => _t('Matematika', 'Математика', 'Math');
  static String get subjectLanguage => _t("Til va o'qish", 'Язык и чтение', 'Language & reading');
  static String get subjectLogic => _t('Mantiq va xotira', 'Логика и память', 'Logic & memory');
  static String get subjectCreative =>
      _t('Shakllar va ijod', 'Фигуры и творчество', 'Shapes & creativity');
  static String get subjectWorld => _t('Atrof-olam', 'Окружающий мир', 'The world around us');

  static String get timeUpTitle =>
      _t("Bugun yaxshi o'ynading!", 'Ты сегодня отлично поиграл!', 'You played great today!');
  static String get timeUpBody => _t(
        "Endi dam olamiz. Ertaga ko'rishamiz! 🌙",
        'Теперь отдыхаем. До завтра! 🌙',
        "Now it's time to rest. See you tomorrow! 🌙",
      );

  // ---------- Sovg'alar do'koni (tangalar) ----------
  static String get rewardsTitle => _t("Sovg'alar do'koni", 'Магазин подарков', 'Gift shop');
  static String coins(int n) => '🪙 $n';
  static String coinsEarned(int n) => '+$n 🪙';
  static String price(int n) => '🪙 $n';
  static String get rewardsAvatars => _t("Yangi do'stlar", 'Новые друзья', 'New buddies');
  static String get rewardsBackgrounds =>
      _t('Bosh ekran foni', 'Фон главного экрана', 'Home background');
  static String get rewardsSelect => _t('Tanlash', 'Выбрать', 'Select');
  static String get rewardsSelected => _t('Tanlangan ✅', 'Выбрано ✅', 'Selected ✅');
  static String get rewardsBought => _t("Yangi sovg'a! 🎉", 'Новый подарок! 🎉', 'New gift! 🎉');
  static String get rewardsNotEnough => _t(
        "Yana o'ynab tanga yig'! 💪",
        'Играй ещё и собирай монетки! 💪',
        'Keep playing to collect coins! 💪',
      );

  static String get bgDefault => _t('Oddiy', 'Обычный', 'Classic');
  static String get bgSky => _t('Osmon', 'Небо', 'Sky');
  static String get bgMeadow => _t("O'tloq", 'Луг', 'Meadow');
  static String get bgCandy => _t('Shirinlik', 'Конфетки', 'Candy');
  static String get bgSunset => _t('Shafaq', 'Закат', 'Sunset');
  static String get bgSpace => _t('Koinot', 'Космос', 'Space');

  // ---------- Yutuqlar javoni (medallar) ----------
  static String get achievementsTitle =>
      _t('Yutuqlar javoni', 'Полка наград', 'Trophy shelf');
  static String medalsCount(int unlocked, int total) => '🏆 $unlocked/$total';
  static String get newMedal => _t('Yangi medal! 🏅', 'Новая медаль! 🏅', 'New medal! 🏅');
  static String get medalUnlocked => _t('Ochildi ✅', 'Получено ✅', 'Unlocked ✅');

  static String get medalFirstWin => _t("Birinchi g'alaba", 'Первая победа', 'First win');
  static String get medalFirstWinHint =>
      _t("1 ta o'yinni tugat", 'Закончи 1 игру', 'Finish 1 game');
  static String get medalPlayer => _t("O'yinchi", 'Игрок', 'Player');
  static String get medalPlayerHint =>
      _t("10 ta o'yin tugat", 'Закончи 10 игр', 'Finish 10 games');
  static String get medalChampion => _t('Chempion', 'Чемпион', 'Champion');
  static String get medalChampionHint =>
      _t("50 ta o'yin tugat", 'Закончи 50 игр', 'Finish 50 games');
  static String get medalMaster => _t('Ustoz', 'Мастер', 'Master');
  static String get medalMasterHint => _t(
        "Biror o'yinda 3 yulduz ol",
        'Получи 3 звезды в любой игре',
        'Get 3 stars in any game',
      );
  static String get medalStar5 => _t('Yulduzcha', 'Звёздочка', 'Little star');
  static String get medalStar5Hint => _t(
        "5 xil o'yinda 3 yulduz ol",
        'Получи 3 звезды в 5 разных играх',
        'Get 3 stars in 5 different games',
      );
  static String get medalExplorer => _t('Kashfiyotchi', 'Исследователь', 'Explorer');
  static String get medalExplorerHint =>
      _t("5 xil o'yin o'yna", 'Сыграй в 5 разных игр', 'Play 5 different games');
  static String get medalTraveler => _t('Sayohatchi', 'Путешественник', 'Traveler');
  static String get medalTravelerHint => _t(
        "O'z guruhingdagi hamma o'yinni o'yna",
        'Сыграй во все игры своей группы',
        'Play every game in your group',
      );
  static String get medalCollector =>
      _t('Yulduzlar kolleksiyasi', 'Коллекция звёзд', 'Star collector');
  static String get medalCollectorHint =>
      _t("Jami 25 yulduz yig'", 'Собери 25 звёзд', 'Collect 25 stars');
  static String get medalStreak3 => _t('3 quvnoq kun', '3 весёлых дня', '3 happy days');
  static String get medalStreak3Hint =>
      _t("3 xil kunda o'yna", 'Поиграй в 3 разных дня', 'Play on 3 different days');
  static String get medalStreak7 => _t('7 quvnoq kun', '7 весёлых дней', '7 happy days');
  static String get medalStreak7Hint =>
      _t("7 xil kunda o'yna", 'Поиграй в 7 разных дней', 'Play on 7 different days');

  // ---------- Yordamchi qahramon (Donish 🦉) ----------
  static String get mascotName =>
      _t("Donish — yordamchi boyo'g'li", 'Дониш — сова-помощник', 'Donish — your owl helper');
  static List<String> mascotGreetings(String name) => _l(
        [
          "Bugun nima o'ynaymiz, $name? 🎈",
          "$name, seni ko'rganimdan xursandman! 😊",
          'Qani, $name, yangi sarguzasht boshlaymizmi? 🚀',
          "Bugun ham bilimdon bo'lamiz, $name! 📚",
        ],
        [
          'Во что сегодня поиграем, $name? 🎈',
          '$name, я рад тебя видеть! 😊',
          'Ну что, $name, начнём новое приключение? 🚀',
          'Сегодня тоже станем умнее, $name! 📚',
        ],
        [
          'What shall we play today, $name? 🎈',
          "$name, I'm so happy to see you! 😊",
          'Ready for a new adventure, $name? 🚀',
          "Let's get smarter today, $name! 📚",
        ],
      );
  static List<String> get mascotPraise3 => _l(
        const [
          "Zo'r! Sen haqiqiy bilimdonsan! 🌟",
          'Voy-boy! Hammasini topding! 🏆',
          'Men sen bilan faxrlanaman! 🦉💛',
        ],
        const [
          'Супер! Ты настоящий знаток! 🌟',
          'Ого! Ты всё отгадал! 🏆',
          'Я горжусь тобой! 🦉💛',
        ],
        const [
          "Awesome! You're a real whiz! 🌟",
          'Wow! You got them all! 🏆',
          "I'm so proud of you! 🦉💛",
        ],
      );
  static List<String> get mascotPraise2 => _l(
        const [
          'Juda yaxshi! Yana bir oz — va 3 yulduz! ⭐',
          "Barakalla! Sen tez o'rganyapsan! 👍",
        ],
        const [
          'Очень хорошо! Ещё чуть-чуть — и 3 звезды! ⭐',
          'Молодец! Ты быстро учишься! 👍',
        ],
        const [
          'Very good! Just a bit more for 3 stars! ⭐',
          "Well done! You're learning fast! 👍",
        ],
      );
  static List<String> get mascotPraise1 => _l(
        const [
          "Yaxshi boshlanish! Birga yana urinib ko'ramiz! 💪",
          "Har safar yaxshiroq bo'lyapsan! 🌱",
        ],
        const [
          'Хорошее начало! Попробуем ещё раз вместе! 💪',
          'С каждым разом у тебя получается лучше! 🌱',
        ],
        const [
          "Good start! Let's try again together! 💪",
          "You're getting better every time! 🌱",
        ],
      );
  static List<String> get mascotTimeUp => _l(
        const ["Ko'zlaring dam olsin, ertaga ko'rishamiz! 🌙"],
        const ['Пусть глазки отдохнут, увидимся завтра! 🌙'],
        const ['Let your eyes rest, see you tomorrow! 🌙'],
      );

  // ---------- Sertifikat ----------
  static String get certificateButton => _t('📜 Sertifikat', '📜 Сертификат', '📜 Certificate');
  static String certificateLocked(int left) => _t(
        "📜 Sertifikatgacha yana $left ta o'yin qoldi",
        '📜 До сертификата осталось игр: $left',
        '📜 $left more games until your certificate',
      );
  static String get certificateLockedHint => _t(
        "Guruhingdagi har bir o'yinda kamida 1 ⭐ ol",
        'Получи хотя бы 1 ⭐ в каждой игре своей группы',
        'Get at least 1 ⭐ in every game of your group',
      );
  static String get certificateTitle => _t('SERTIFIKAT', 'СЕРТИФИКАТ', 'CERTIFICATE');
  static String get certificateGiven =>
      _t('Ushbu sertifikat', 'Этот сертификат вручается', 'This certificate is awarded to');
  static String certificateFor(String module) => _t(
        "«$module» bo'limidagi barcha o'yinlarni muvaffaqiyatli o'tgani uchun beriladi",
        'за успешное прохождение всех игр раздела «$module»',
        'for successfully completing every game in "$module"',
      );
  static String certificateStars(int stars) =>
      _t('⭐ $stars yulduz', '⭐ Звёзд: $stars', '⭐ $stars stars');
  static String certificateMedals(int medals) =>
      _t('🏅 $medals medal', '🏅 Медалей: $medals', '🏅 $medals medals');
  static String certificateDate(String date) => _t('Sana: $date', 'Дата: $date', 'Date: $date');
  static List<String> get certificatePraise => _l(
        const ["Tabriklayman! Sen haqiqiy Aqlli Do'stsan! 🎓"],
        const ['Поздравляю! Ты настоящий Умный Друг! 🎓'],
        const ["Congratulations! You're a true Smart Friend! 🎓"],
      );
  static String get certificateSaveHint => _t(
        '📸 Saqlash uchun ekranni skrinshot qiling',
        '📸 Чтобы сохранить, сделайте скриншот экрана',
        '📸 Take a screenshot to save it',
      );

  // ---------- Birinchi ochilish ko'rsatmasi ----------
  static String get onboarding1 => _t(
        "Salom! Men Donish. Birga o'ynab o'rganamiz! 🎮",
        'Привет! Я Дониш. Будем учиться, играя вместе! 🎮',
        "Hi! I'm Donish. Let's play and learn together! 🎮",
      );
  static String get onboarding2 => _t(
        "O'yin o'ynab ⭐ yulduz va 🪙 tanga yig'. Tangalarga sovg'a ol! 🎁",
        'Играй и собирай ⭐ звёзды и 🪙 монетки. Меняй монетки на подарки! 🎁',
        'Play to collect ⭐ stars and 🪙 coins. Trade coins for gifts! 🎁',
      );
  static String get onboarding3 => _t(
        "Ota-onalar uchun: 🔒 tugmasi — vaqt chegarasi va hisobot. Ilova internetsiz ishlaydi, reklama yo'q.",
        'Для родителей: кнопка 🔒 — лимит времени и отчёт. Приложение работает без интернета, рекламы нет.',
        'For parents: the 🔒 button opens time limits and reports. Works offline, no ads.',
      );
  static String get onboardingNext => _t('Keyingi ➡️', 'Далее ➡️', 'Next ➡️');
  static String get onboardingStart => _t('Boshlash 🚀', 'Начать 🚀', 'Start 🚀');
  static String get onboardingSkip => _t("O'tkazib yuborish", 'Пропустить', 'Skip');

  // ---------- O'ynagan kunlar (manipulyatsiyasiz kunlik bonus) ----------
  static String streakDays(int n) => '📅 $n';
  // [days] ataylab ko'rsatilmaydi: "ketma-ket" bosimi yo'q, faqat bugungi quvonch.
  static String streakBonus(int days, int coins) => _t(
        "📅 Bugungi birinchi o'yin! +$coins 🪙",
        '📅 Первая игра сегодня! +$coins 🪙',
        '📅 First game today! +$coins 🪙',
      );

  // ---------- Maxfiylik siyosati va ilova haqida (Apple 5.1.1) ----------
  static String get privacyButton =>
      _t('🔐 Maxfiylik siyosati', '🔐 Политика конфиденциальности', '🔐 Privacy policy');
  static String get aboutButton => _t('ℹ️ Ilova haqida', 'ℹ️ О приложении', 'ℹ️ About the app');
  static String get privacyTitle =>
      _t('Maxfiylik siyosati', 'Политика конфиденциальности', 'Privacy policy');
  static String get aboutTitle => _t('Ilova haqida', 'О приложении', 'About the app');
  static String privacyEffective(String date) =>
      _t('Kuchga kirgan sana: $date', 'Дата вступления в силу: $date', 'Effective date: $date');

  static List<(String, String)> privacySections(String author, String email) => switch (current) {
        AppLanguage.uz => [
            (
              'Qisqacha',
              "\"Aqlli Do'stlar\" hech qanday shaxsiy ma'lumot yig'maydi, hech kimga yubormaydi va "
                  "internetdan foydalanmaydi. Barcha ma'lumotlar faqat sizning qurilmangizda saqlanadi.",
            ),
            (
              '1. Ilova haqida',
              "\"Aqlli Do'stlar\" — 5–12 yoshli bolalar uchun ta'limiy o'yin. Ilova to'liq oflayn "
                  "ishlaydi va internetga ulanish ruxsatini so'ramaydi.",
            ),
            (
              "2. Qurilmada saqlanadigan ma'lumotlar",
              "O'yin ishlashi uchun faqat qurilmaning o'zida saqlanadi:\n"
                  "• Bola profili: ism (yoki laqab), yosh va avatar;\n"
                  "• O'yin natijalari: yulduzlar, o'ynalganlar soni, o'yin vaqti;\n"
                  '• Kunlik ekran vaqti hisobi;\n'
                  '• Ota-ona sozlamalari: PIN kod, kunlik vaqt chegarasi, til.\n'
                  "Bu ma'lumotlar biz yoki boshqa birov tomonidan ko'rilmaydi, serverga "
                  'yuborilmaydi va uchinchi tomonlarga berilmaydi.',
            ),
            (
              '3. Biz nimalarni qilmaymiz',
              "• Reklama ko'rsatmaymiz;\n"
                  "• Ilova ichida xarid yo'q;\n"
                  '• Analitika, kuzatuv (tracking) yoki reklama identifikatorlari yo\'q;\n'
                  "• Joylashuv, kamera, mikrofon, kontaktlar yoki fayllarga kirish so'ramaymiz;\n"
                  "• Ijtimoiy tarmoqlar yoki tashqi havolalar yo'q.",
            ),
            (
              "4. Ovozli o'qish",
              "Ba'zi o'yinlarda so'zlarni ovoz chiqarib aytish uchun qurilmaga o'rnatilgan nutq "
                  "sintezi (Text-to-Speech) ishlatiladi. Ilova unga faqat aytiladigan so'zni beradi "
                  "va hech qanday ma'lumotni internetga yubormaydi.",
            ),
            (
              '5. Bolalar maxfiyligi',
              "Ilova bolalardan shaxsiy ma'lumot yig'maydi. Bu COPPA, GDPR-K va Google Play "
                  '"Families" siyosati tamoyillariga mos. Ota-ona paneli PIN kod bilan himoyalangan.',
            ),
            (
              "6. Ma'lumotlarni o'chirish",
              "Barcha ma'lumotlarni o'chirish uchun ilovani qurilmadan o'chiring yoki qurilma "
                  "sozlamalarida ilova ma'lumotlarini tozalang. Bizda hech qanday nusxa saqlanmaydi.",
            ),
            (
              "7. O'zgarishlar",
              "Siyosat o'zgarsa, yangi versiya yangi sana bilan e'lon qilinadi.",
            ),
            ('8. Aloqa', "Savollar bo'lsa: $author — $email"),
          ],
        AppLanguage.ru => [
            (
              'Кратко',
              '«Aqlli Do\'stlar» не собирает никаких личных данных, никуда их не передаёт и не '
                  'использует интернет. Все данные хранятся только на вашем устройстве.',
            ),
            (
              '1. О приложении',
              '«Aqlli Do\'stlar» — обучающая игра для детей 5–12 лет. Приложение работает полностью '
                  'офлайн и не запрашивает доступ к интернету.',
            ),
            (
              '2. Данные на устройстве',
              'Для работы игры только на самом устройстве хранятся:\n'
                  '• Профиль ребёнка: имя (или прозвище), возраст и аватар;\n'
                  '• Результаты игр: звёзды, число игр, время игры;\n'
                  '• Счётчик ежедневного экранного времени;\n'
                  '• Настройки родителей: PIN-код, дневной лимит, язык.\n'
                  'Эти данные никто не видит, они не отправляются на сервер и не передаются '
                  'третьим лицам.',
            ),
            (
              '3. Чего мы не делаем',
              '• Нет рекламы;\n'
                  '• Нет встроенных покупок;\n'
                  '• Нет аналитики, отслеживания и рекламных идентификаторов;\n'
                  '• Нет доступа к геолокации, камере, микрофону, контактам и файлам;\n'
                  '• Нет социальных функций и внешних ссылок.',
            ),
            (
              '4. Озвучивание',
              'В некоторых играх слова читаются вслух встроенным в устройство синтезатором речи '
                  '(Text-to-Speech). Приложение передаёт ему только произносимое слово и ничего не '
                  'отправляет в интернет.',
            ),
            (
              '5. Конфиденциальность детей',
              'Приложение не собирает личные данные детей — в соответствии с COPPA, GDPR-K и '
                  'политикой Google Play «Families». Панель для родителей защищена PIN-кодом.',
            ),
            (
              '6. Удаление данных',
              'Чтобы удалить все данные, удалите приложение или очистите его данные в настройках '
                  'устройства. Мы не храним никаких копий.',
            ),
            (
              '7. Изменения',
              'При изменении политики новая версия будет опубликована с новой датой.',
            ),
            ('8. Контакты', 'Вопросы: $author — $email'),
          ],
        AppLanguage.en => [
            (
              'Summary',
              '"Aqlli Do\'stlar" does not collect, share or transmit any personal data and does not '
                  'use the internet. All data stays on your device.',
            ),
            (
              '1. About the app',
              '"Aqlli Do\'stlar" ("Smart Friends") is an educational game for children aged 5–12. '
                  'It works fully offline and does not request internet access.',
            ),
            (
              '2. Data stored on the device',
              'To make the game work, the following is stored only on the device:\n'
                  '• Child profile: name (or nickname), age and avatar;\n'
                  '• Game results: stars, number of plays, play time;\n'
                  '• Daily screen-time counter;\n'
                  '• Parental settings: PIN, daily time limit, language.\n'
                  'This data is never seen by us or anyone else, never sent to a server and never '
                  'shared with third parties.',
            ),
            (
              '3. What we do not do',
              '• No advertising;\n'
                  '• No in-app purchases;\n'
                  '• No analytics, tracking or advertising identifiers;\n'
                  '• No access to location, camera, microphone, contacts or files;\n'
                  '• No social features or external links.',
            ),
            (
              '4. Text-to-speech',
              "Some games read words aloud using the device's built-in text-to-speech engine. "
                  'The app only passes the word to be spoken and sends no data over the internet.',
            ),
            (
              "5. Children's privacy",
              'The app collects no personal information from children, in line with COPPA, GDPR-K '
                  'and the Google Play Families Policy. The parent panel is protected by a PIN.',
            ),
            (
              '6. Deleting data',
              "To delete all data, uninstall the app or clear its data in the device settings. "
                  'We keep no copy.',
            ),
            (
              '7. Changes',
              'If this policy changes, the new version will be published with a new date.',
            ),
            ('8. Contact', 'Questions: $author — $email'),
          ],
      };

  static String aboutVersion(String version) =>
      _t('Versiya $version', 'Версия $version', 'Version $version');
  static String get aboutDescription => _t(
        "5–12 yoshli bolalar uchun ta'limiy o'yinlar: matematika, til, mantiq va ijod.",
        'Обучающие игры для детей 5–12 лет: математика, язык, логика и творчество.',
        'Educational games for children aged 5–12: maths, language, logic and creativity.',
      );
  static List<String> get aboutBadges => _l(
        ["🚫 Reklama yo'q", "🌐 Internet kerak emas", "🔒 Ma'lumot yig'ilmaydi", "🛒 Xarid yo'q"],
        ['🚫 Без рекламы', '🌐 Без интернета', '🔒 Данные не собираются', '🛒 Без покупок'],
        ['🚫 No ads', '🌐 No internet needed', '🔒 No data collected', '🛒 No purchases'],
      );
  static String aboutAuthor(String author) =>
      _t('Muallif: $author', 'Автор: $author', 'Developer: $author');
  static String get aboutContact => _t('Aloqa:', 'Контакты:', 'Contact:');
  static String get copy => _t('Nusxa olish', 'Копировать', 'Copy');
  static String get copied =>_t('Nusxa olindi ✅', 'Скопировано ✅', 'Copied ✅');
}

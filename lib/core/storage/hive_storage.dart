import 'package:hive_flutter/hive_flutter.dart';

/// Lokal baza (FR-5, FR-9). Ma'lumotlar faqat qurilmada saqlanadi,
/// hech qayerga yuborilmaydi (TZ 4.4).
///
/// Hive oddiy Map ko'rinishida ishlatiladi — kod generatsiyasi kerak emas.
abstract final class HiveStorage {
  static const _profilesBox = 'profiles';
  static const _progressBox = 'progress';
  static const _settingsBox = 'settings';

  static Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<Map>(_profilesBox),
      Hive.openBox<Map>(_progressBox),
      Hive.openBox<dynamic>(_settingsBox),
    ]);
  }

  /// Kalit: profil id → profil ma'lumotlari.
  static Box<Map> get profiles => Hive.box<Map>(_profilesBox);

  /// Kalit: "profilId|oyinId" → o'yin progressi.
  static Box<Map> get progress => Hive.box<Map>(_progressBox);

  /// Umumiy sozlamalar (faol profil va h.k.).
  static Box<dynamic> get settings => Hive.box<dynamic>(_settingsBox);
}

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_storage.dart';
import 'app_strings.dart';

/// Ilova interfeysi tillari. Nomlar har doim o'z tilida yoziladi —
/// boshqa tilni bilmagan odam ham o'z tilini topa olsin.
enum AppLanguage {
  uz('uz', "Oʻzbekcha", '🇺🇿'),
  ru('ru', 'Русский', '🇷🇺'),
  en('en', 'English', '🇬🇧');

  const AppLanguage(this.code, this.nativeName, this.flag);

  final String code;
  final String nativeName;
  final String flag;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      values.firstWhere((l) => l.code == code, orElse: () => uz);
}

/// Tanlangan til. Hive settings qutisida "language" kaliti bilan saqlanadi.
/// [AppStrings.current] ham shu yerda yangilanadi — matnlar shundan o'qiladi.
class AppLanguageNotifier extends Notifier<AppLanguage> {
  static const _key = 'language';

  @override
  AppLanguage build() {
    final language = AppLanguage.fromCode(HiveStorage.settings.get(_key) as String?);
    AppStrings.current = language;
    return language;
  }

  void set(AppLanguage language) {
    HiveStorage.settings.put(_key, language.code);
    AppStrings.current = language;
    state = language;
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(AppLanguageNotifier.new);

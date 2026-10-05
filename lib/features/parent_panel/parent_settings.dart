import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';

/// Kunlik chegara variantlari (daqiqa). 0 — chegara o'chiq (FR-7).
const kDailyLimitOptions = [0, 15, 30, 45, 60];

/// PIN uzunligi (FR-6).
const kPinLength = 4;

/// Ota-ona sozlamalari. Faqat qurilmada saqlanadi (TZ 4.4).
class ParentSettings {
  const ParentSettings({this.pin, this.dailyLimitMinutes = 0});

  /// null — PIN hali o'rnatilmagan.
  final String? pin;

  /// 0 — chegara yo'q.
  final int dailyLimitMinutes;

  bool get hasPin => pin != null;
  bool get hasLimit => dailyLimitMinutes > 0;
}

class ParentSettingsNotifier extends Notifier<ParentSettings> {
  static const _pinKey = 'parentPin';
  static const _limitKey = 'dailyLimitMinutes';

  @override
  ParentSettings build() {
    final box = HiveStorage.settings;
    return ParentSettings(
      pin: box.get(_pinKey) as String?,
      dailyLimitMinutes: box.get(_limitKey) as int? ?? 0,
    );
  }

  bool checkPin(String input) => state.pin == input;

  void setPin(String pin) {
    HiveStorage.settings.put(_pinKey, pin);
    state = ParentSettings(pin: pin, dailyLimitMinutes: state.dailyLimitMinutes);
  }

  /// "PIN ni unutdim" — kattalar savoliga to'g'ri javob berilgandan keyin.
  void resetPin() {
    HiveStorage.settings.delete(_pinKey);
    state = ParentSettings(dailyLimitMinutes: state.dailyLimitMinutes);
  }

  void setDailyLimit(int minutes) {
    HiveStorage.settings.put(_limitKey, minutes);
    state = ParentSettings(pin: state.pin, dailyLimitMinutes: minutes);
  }
}

final parentSettingsProvider =
    NotifierProvider<ParentSettingsNotifier, ParentSettings>(ParentSettingsNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage.dart';

/// Kunlik chegara variantlari (daqiqa). 0 — chegara o'chiq (FR-7).
const kDailyLimitOptions = [0, 15, 30, 45, 60];

/// PIN uzunligi (FR-6).
const kPinLength = 4;

/// Ota-ona sozlamalari. Faqat qurilmada saqlanadi (TZ 4.4).
class ParentSettings {
  const ParentSettings({
    this.pin,
    this.dailyLimitMinutes = 0,
    this.soundEnabled = true,
    this.ttsEnabled = true,
  });

  /// null — PIN hali o'rnatilmagan.
  final String? pin;

  /// 0 — chegara yo'q.
  final int dailyLimitMinutes;

  /// O'yin ovoz effektlari (to'g'ri / qayta urin / g'alaba).
  final bool soundEnabled;

  /// So'z va savollarni ovozli o'qish (TTS).
  final bool ttsEnabled;

  bool get hasPin => pin != null;
  bool get hasLimit => dailyLimitMinutes > 0;

  ParentSettings copyWith({
    int? dailyLimitMinutes,
    bool? soundEnabled,
    bool? ttsEnabled,
  }) =>
      ParentSettings(
        pin: pin,
        dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      );
}

class ParentSettingsNotifier extends Notifier<ParentSettings> {
  static const _pinKey = 'parentPin';
  static const _limitKey = 'dailyLimitMinutes';
  static const _soundKey = 'soundEnabled';
  static const _ttsKey = 'ttsEnabled';

  @override
  ParentSettings build() {
    final box = HiveStorage.settings;
    return ParentSettings(
      pin: box.get(_pinKey) as String?,
      dailyLimitMinutes: box.get(_limitKey) as int? ?? 0,
      soundEnabled: box.get(_soundKey) as bool? ?? true,
      ttsEnabled: box.get(_ttsKey) as bool? ?? true,
    );
  }

  bool checkPin(String input) => state.pin == input;

  void setPin(String pin) {
    HiveStorage.settings.put(_pinKey, pin);
    state = ParentSettings(
      pin: pin,
      dailyLimitMinutes: state.dailyLimitMinutes,
      soundEnabled: state.soundEnabled,
      ttsEnabled: state.ttsEnabled,
    );
  }

  /// "PIN ni unutdim" — kattalar savoliga to'g'ri javob berilgandan keyin.
  void resetPin() {
    HiveStorage.settings.delete(_pinKey);
    state = ParentSettings(
      dailyLimitMinutes: state.dailyLimitMinutes,
      soundEnabled: state.soundEnabled,
      ttsEnabled: state.ttsEnabled,
    );
  }

  void setDailyLimit(int minutes) {
    HiveStorage.settings.put(_limitKey, minutes);
    state = state.copyWith(dailyLimitMinutes: minutes);
  }

  void setSoundEnabled(bool enabled) {
    HiveStorage.settings.put(_soundKey, enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  void setTtsEnabled(bool enabled) {
    HiveStorage.settings.put(_ttsKey, enabled);
    state = state.copyWith(ttsEnabled: enabled);
  }
}

final parentSettingsProvider =
    NotifierProvider<ParentSettingsNotifier, ParentSettings>(ParentSettingsNotifier.new);

/// Panel PIN bilan ochilganmi. Faqat xotirada: ilova qayta ochilsa yana PIN so'raladi.
class ParentUnlockNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
  void lock() => state = false;
}

final parentUnlockedProvider =
    NotifierProvider<ParentUnlockNotifier, bool>(ParentUnlockNotifier.new);

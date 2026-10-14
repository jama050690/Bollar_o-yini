import 'package:flutter/services.dart';

/// Odam ovozida yozib olingan o'zbekcha so'zlar (assets/sounds/uz/words/).
///
/// Telefonda o'zbek tili ovoz dvigateli ko'pincha yo'q. Shu so'z uchun
/// yozilgan fayl bo'lsa — u chalinadi, bo'lmasa ovoz dvigateli ishlatiladi.
/// Yozib olish ro'yxati: assets/sounds/README.md
class VoiceAssets {
  VoiceAssets({Future<Set<String>> Function()? loadAssets})
      : _loadAssets = loadAssets ?? _loadFromManifest;

  static const folder = 'assets/sounds/uz/words/';

  final Future<Set<String>> Function() _loadAssets;
  Future<Set<String>>? _assets;

  /// Matnni fayl nomiga aylantiradi: "toʻrt" → "to_rt", "oʻn bir" → "o_n_bir".
  static String fileName(String text) {
    final slug = text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp("[ʻʼ'‘’`]"), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return '$slug.mp3';
  }

  /// Yozilgan fayl bo'lsa, audioplayers uchun yo'lni ("sounds/uz/words/...") qaytaradi.
  Future<String?> pathFor(String text) async {
    try {
      final assets = await (_assets ??= _loadAssets());
      final asset = '$folder${fileName(text)}';
      return assets.contains(asset) ? asset.substring('assets/'.length) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<Set<String>> _loadFromManifest() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return {
      for (final asset in manifest.listAssets())
        if (asset.startsWith(folder)) asset,
    };
  }
}

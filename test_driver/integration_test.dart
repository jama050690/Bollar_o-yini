import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Skrinshotlarni `store/screenshots/SHOTS_DIR/` papkasiga yozadi (standart: ipad).
/// Masalan iPhone uchun: `SHOTS_DIR=iphone flutter drive ...`
Future<void> main() {
  final dir = Platform.environment['SHOTS_DIR'] ?? 'ipad';
  return integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('store/screenshots/$dir/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}

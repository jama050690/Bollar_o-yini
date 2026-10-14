import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Skrinshotlarni store/screenshots/ipad/ papkasiga yozadi.
Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final file = File('store/screenshots/ipad/$name.png');
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return true;
      },
    );

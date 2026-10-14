import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/storage/hive_storage.dart';
import 'shared/widgets/error_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers();
  await _start();
}

Future<void> _start() async {
  try {
    // Lokal baza (FR-5, FR-9): barcha ma'lumotlar faqat qurilmada saqlanadi.
    await Hive.initFlutter();
    await HiveStorage.openBoxes();
  } catch (error, stack) {
    // Baza ochilmasa oq ekranda qotib qolmaydi — "Qayta urinish" taklif qilinadi.
    debugPrint('Baza ochilmadi: $error\n$stack');
    runApp(const StartupErrorApp(onRetry: _retry));
    return;
  }

  runApp(const ProviderScope(child: AqlliDostlarApp()));
}

void _retry() => _start();

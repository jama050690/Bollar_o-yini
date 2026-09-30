import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lokal baza (FR-5, FR-9): barcha ma'lumotlar faqat qurilmada saqlanadi.
  await Hive.initFlutter();

  runApp(const ProviderScope(child: AqlliDostlarApp()));
}

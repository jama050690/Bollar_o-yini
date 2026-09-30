import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqlli_dostlar/app.dart';

void main() {
  testWidgets('Ilova ishga tushadi va bosh ekranni ko\'rsatadi', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AqlliDostlarApp()));
    await tester.pumpAndSettle();

    expect(find.text("Aqlli Do'stlar"), findsOneWidget);
    expect(find.text('Xush kelibsiz!'), findsOneWidget);
  });
}

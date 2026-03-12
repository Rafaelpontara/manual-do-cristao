import 'package:flutter_test/flutter_test.dart';
import 'package:palavra_viva/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PalavraVivaApp(isFirstTime: false));
    expect(find.byType(PalavraVivaApp), findsOneWidget);
  });
}
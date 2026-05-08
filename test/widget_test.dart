import 'package:flutter_test/flutter_test.dart';
import 'package:talento_app/main.dart';

void main() {
  testWidgets('Talento app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TalentoApp());
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/main.dart';

void main() {
  testWidgets('Talento app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TalentoApp());
  });
}
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rustic_fit/main.dart';

void main() {
  testWidgets('RusticFit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RusticFitApp());

    // First verify splash screen is visible
    expect(find.text('RusticFit'), findsOneWidget);
    expect(find.text('by Kim'), findsOneWidget);

    // Wait for splash screen to complete
    await tester.pump(const Duration(seconds: 4));

    // Verify that we can find the home screen content
    expect(find.text('Welcome to RusticFit'), findsOneWidget);
  });
}

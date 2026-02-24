import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_ai/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreamAIApp());

    // Verify that the splash screen is shown
    expect(find.text('Stream AI'), findsOneWidget);
    expect(find.text('Votre assistant IA intelligent'), findsOneWidget);
  });
}

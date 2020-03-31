// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('English Buoy simple test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(Ebuoy());

    // Verify that title is correct.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    //expect(find.text('1'), findsNothing);

    // Tap the 'settings' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    // Verify that show Autoplay config.
    expect(find.text('Autoplay'), findsOneWidget);
    expect(find.text('Scroll with playing'), findsOneWidget);
    expect(find.text('Hide 100%'), findsOneWidget);
    //expect(find.text('1'), findsOneWidget);
  });
}

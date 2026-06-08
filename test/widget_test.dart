// This is a basic Flutter widget test.
//
// It verifies that the app can be built and shows the expected splash screen
// content on first launch.

import 'package:flutter_test/flutter_test.dart';

import 'package:mindcare/main.dart';

void main() {
  testWidgets('shows MindCare splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MindCareApp());

    expect(find.text('MindCare'), findsOneWidget);
    expect(find.text('Kesehatan Mental untuk Semua'), findsOneWidget);
  });
}

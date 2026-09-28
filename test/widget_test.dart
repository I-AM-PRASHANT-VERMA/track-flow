import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_flow/main.dart';

void main() {
  testWidgets('TrackFlow App smoke test and view switcher verification', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TrackFlowApp());
    await tester.pumpAndSettle();

    // Verify Brand title
    expect(find.text('TrackFlow'), findsOneWidget);
    expect(find.text("Today's Flow"), findsOneWidget);

    // Verify starter habits are displayed in Today's Flow
    expect(find.text('Hydration Goal'), findsOneWidget);
    expect(find.text('Morning 5K / Cardio'), findsOneWidget);

    // Switch to 7-Day Matrix Tab
    final matrixTab = find.text('7-Day Matrix');
    expect(matrixTab, findsOneWidget);
    await tester.tap(matrixTab);
    await tester.pumpAndSettle();

    // Verify matrix table appears
    expect(find.text('HABIT / RITUAL'), findsOneWidget);

    // Switch to 365-Day Canvas Tab
    final canvasTab = find.text('365-Day Canvas');
    expect(canvasTab, findsOneWidget);
    await tester.tap(canvasTab);
    await tester.pumpAndSettle();

    // Verify canvas container appears
    expect(find.text('365-DAY CONTRIBUTION CANVAS'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}

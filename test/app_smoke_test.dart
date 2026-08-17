import 'package:fitx/core/providers/app_providers.dart';
import 'package:fitx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  // Give the auth screen enough vertical room (it's taller than 600px).
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FitXApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo sign-in reaches home dashboard', (tester) async {
    await pumpApp(tester);

    // Auth screen is visible
    expect(find.text('FitX'), findsOneWidget);
    expect(find.text('Try Demo Account'), findsOneWidget);

    // Sign in with the demo account
    await tester.tap(find.text('Try Demo Account'));
    await tester.pumpAndSettle();

    // Home dashboard is visible
    expect(find.text('Start Workout'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Recent Workouts'), findsOneWidget);
  });

  testWidgets('sign-up validation blocks invalid email', (tester) async {
    await pumpApp(tester);

    // Switch to sign-up mode
    await tester.tap(find.text('Create Account').first);
    await tester.pumpAndSettle();

    // Enter invalid email and submit
    await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.tap(find.text('Create Account').last);
    await tester.pumpAndSettle();

    // Still on auth screen with validation error
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Start Workout'), findsNothing);
  });
}

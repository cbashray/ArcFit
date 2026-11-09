import 'package:arcfit/core/providers/app_providers.dart';
import 'package:arcfit/features/auth/data/repos/local_auth_repository.dart';
import 'package:arcfit/features/progress/presentation/screens/progress_screen.dart';
import 'package:arcfit/features/workouts/data/repos/local_workout_repository.dart';
import 'package:arcfit/main.dart';
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
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(LocalAuthRepository(prefs)),
        workoutRepositoryProvider.overrideWithValue(LocalWorkoutRepository(prefs)),
      ],
      child: const ArcFitApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo sign-in reaches home dashboard', (tester) async {
    await pumpApp(tester);

    // Auth screen is visible
    expect(find.text('ArcFit'), findsOneWidget);
    expect(find.text('Try Demo Account'), findsOneWidget);

    // Sign in with the demo account
    await tester.tap(find.text('Try Demo Account'));
    await tester.pumpAndSettle();

    // Dashboard is visible (replaced the old Home screen as Tab 0)
    expect(find.text("Today's Progress"), findsOneWidget);
    expect(find.text('Weekly Activity'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
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

  testWidgets('full navigation across tabs and workout flow without errors', (tester) async {
    await pumpApp(tester);

    // Sign in demo
    await tester.tap(find.text('Try Demo Account'));
    await tester.pumpAndSettle();

    // 1. Leaderboard tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Leaderboard'));
    await tester.pumpAndSettle();
    expect(find.text('Leaderboard'), findsAtLeastNWidgets(1));

    // 2. Nutrition tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Nutrition'));
    await tester.pumpAndSettle();
    expect(find.text('Nutrition'), findsAtLeastNWidgets(1));

    // 3. AI Coach tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'AI Coach'));
    await tester.pumpAndSettle();
    expect(find.text('AI Coach'), findsAtLeastNWidgets(1));

    // 4. Workout tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout Hub 🏋️'), findsOneWidget);
    expect(find.text('AI Workout'), findsOneWidget);
  });

  testWidgets('ProgressScreen renders with 0 workouts without FlGridData assertion errors', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(LocalAuthRepository(prefs)),
          workoutRepositoryProvider.overrideWithValue(LocalWorkoutRepository(prefs)),
        ],
        child: const MaterialApp(
          home: ProgressScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('0 kg'), findsOneWidget);
    expect(find.text('Volume Trend'), findsOneWidget);
  });
}
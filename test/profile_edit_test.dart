import 'package:fitx/core/providers/app_providers.dart';
import 'package:fitx/features/auth/data/repos/local_auth_repository.dart';
import 'package:fitx/features/auth/domain/entities/user_entity.dart';
import 'package:fitx/features/settings/presentation/screens/settings_screen.dart';
import 'package:fitx/features/settings/presentation/widgets/edit_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('UserEntity supports profile fields and copyWith / serialization', () {
    final user = UserEntity(
      id: 'test_123',
      email: 'alex@fitx.app',
      name: 'Alex Rivera',
      age: 26,
      gender: 'Male',
      height: 178.5,
      weight: 75.0,
      avatarEmoji: '🦁',
      createdAt: DateTime(2025, 1, 1),
    );

    expect(user.name, 'Alex Rivera');
    expect(user.age, 26);
    expect(user.gender, 'Male');
    expect(user.height, 178.5);
    expect(user.weight, 75.0);
    expect(user.avatarEmoji, '🦁');

    final map = user.toMap();
    final restored = UserEntity.fromMap(map);
    expect(restored, equals(user));
  });

  test('LocalAuthRepository updates profile correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalAuthRepository(prefs);

    final user = await repo.signUp(
      email: 'test@fitx.app',
      password: 'pass',
      name: 'Initial Name',
    );

    expect(user.name, 'Initial Name');
    expect(user.age, isNull);

    final updated = await repo.updateProfile(
      name: 'Updated Athlete',
      age: 28,
      gender: 'Female',
      height: 165.0,
      weight: 58.0,
      avatarEmoji: '🔥',
    );

    expect(updated.name, 'Updated Athlete');
    expect(updated.age, 28);
    expect(updated.gender, 'Female');
    expect(updated.height, 165.0);
    expect(updated.weight, 58.0);
    expect(updated.avatarEmoji, '🔥');

    final current = await repo.getCurrentUser();
    expect(current?.name, 'Updated Athlete');
    expect(current?.avatarEmoji, '🔥');
  });

  testWidgets('Settings page renders profile card and opens EditProfileSheet',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localAuth = LocalAuthRepository(prefs);

    await localAuth.signUp(
      email: 'athlete@fitx.app',
      password: 'password123',
      name: 'Jordan Pro',
    );
    await localAuth.updateProfile(
      name: 'Jordan Pro',
      age: 25,
      gender: 'Male',
      height: 180,
      weight: 78,
      avatarEmoji: '🏋️',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(localAuth),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Profile section and stats chip
    expect(find.text('Jordan Pro'), findsOneWidget);
    expect(find.text('athlete@fitx.app'), findsOneWidget);
    expect(find.text('25 yrs'), findsOneWidget);
    expect(find.text('180 cm'), findsOneWidget);
    expect(find.text('78 kg'), findsOneWidget);
    expect(find.text('🏋️'), findsOneWidget);

    // Tap on Edit Profile button
    await tester.tap(find.byTooltip('Edit Profile'));
    await tester.pumpAndSettle();

    // Verify EditProfileSheet is open
    expect(find.byType(EditProfileSheet), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Choose Avatar Icon'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
  });
}

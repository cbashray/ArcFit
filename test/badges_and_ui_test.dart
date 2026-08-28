import 'package:fitx/core/providers/app_providers.dart';
import 'package:fitx/features/shared/gamification/gamification.dart';
import 'package:fitx/features/workouts/domain/entities/workout_entity.dart';
import 'package:fitx/features/workouts/presentation/providers/workout_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gamification and Badges Tests', () {
    late SharedPreferences prefs;
    late GamificationRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = GamificationRepository(prefs);
    });

    test('All badge definitions exist and start locked', () {
      final badges = repo.getAllBadges();
      expect(badges.length, greaterThanOrEqualTo(14));
      expect(badges.every((b) => !b.isUnlocked), isTrue);
    });

    test('evaluateAndUnlock unlocks first_workout, streak, sets, variety and early bird', () async {
      final now = DateTime(2026, 8, 28, 6, 30); // 6:30 AM
      final testWorkouts = [
        WorkoutEntity(
          id: 'w1',
          userId: 'user_test',
          title: 'Morning Push',
          exercises: [
            for (var i = 0; i < 10; i++)
              WorkoutExerciseEntity(
                id: 'e$i',
                exerciseId: 'ex_$i',
                exerciseName: 'Exercise $i',
                exerciseVideoUrl: '',
                sets: 10,
                reps: 10,
                weight: 50,
                performedAt: now,
              ),
          ],
          date: now,
          durationMinutes: 45,
          totalSets: 100,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final newlyUnlocked = await repo.evaluateAndUnlock(
        workouts: testWorkouts,
        currentStreak: 3,
        totalPRs: 1,
      );

      final unlockedIds = newlyUnlocked.map((b) => b.id).toSet();
      expect(unlockedIds.contains('first_workout'), isTrue);
      expect(unlockedIds.contains('streak_3'), isTrue);
      expect(unlockedIds.contains('sets_100'), isTrue);
      expect(unlockedIds.contains('pr_first'), isTrue);
      expect(unlockedIds.contains('variety'), isTrue);
      expect(unlockedIds.contains('early_bird'), isTrue);

      final allBadges = repo.getAllBadges();
      final firstWorkoutBadge = allBadges.firstWhere((b) => b.id == 'first_workout');
      expect(firstWorkoutBadge.isUnlocked, isTrue);
      expect(firstWorkoutBadge.unlockedAt, isNotNull);
    });

    test('Active workout finish logs workout and reflects in workoutsProvider', () async {
      final element = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Start active workout
      final activeNotifier = element.read(activeWorkoutProvider.notifier);
      activeNotifier.start(title: 'Leg Day Blast');
      activeNotifier.addDraftExercise(DraftExercise(
        exerciseId: 'ex_squat',
        name: 'Barbell Squat',
        muscleGroup: 'Legs',
        sets: 4,
        reps: 8,
        weight: 100,
      ));

      // Finish workout
      final result = await activeNotifier.finish();
      expect(result.workout, isNotNull);
      expect(result.workout!.title, equals('Leg Day Blast'));

      // Check workoutsProvider
      final recentWorkouts = await element.read(workoutsProvider.future);
      expect(recentWorkouts.length, equals(1));
      expect(recentWorkouts.first.title, equals('Leg Day Blast'));
      expect(recentWorkouts.first.exercises.length, equals(1));
      expect(recentWorkouts.first.exercises.first.exerciseName, equals('Barbell Squat'));
    });
  });
}

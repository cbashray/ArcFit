// Riverpod providers for FitX
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/ai/adaptive_workout/data/repos/local_adaptive_workout_repository.dart';
import '../../features/ai/adaptive_workout/domain/repos/adaptive_workout_repository.dart';
import '../../features/auth/data/repos/local_auth_repository.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/exercise_library/data/repos/local_exercise_repository.dart';
import '../../features/exercise_library/domain/repos/exercise_repository.dart';
import '../../features/workouts/data/repos/local_personal_record_repository.dart';
import '../../features/workouts/data/repos/local_workout_repository.dart';
import '../../core/services/notification_service.dart';
import '../../features/habits/data/repos/local_habit_repository.dart';
import '../../features/habits/domain/repos/habit_repository.dart';
import '../../features/workouts/domain/repos/personal_record_repository.dart';
import '../../features/workouts/domain/repos/workout_repository.dart';

/// Shared preferences (initialized in main before runApp)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialized via override in main()');
});

/// Notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(sharedPreferencesProvider));
});

/// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository(ref.watch(sharedPreferencesProvider));
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return LocalExerciseRepository();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return LocalWorkoutRepository(ref.watch(sharedPreferencesProvider));
});

final adaptiveWorkoutRepositoryProvider =
    Provider<AdaptiveWorkoutRepository>((ref) {
  return LocalAdaptiveWorkoutRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(exerciseRepositoryProvider),
  );
});

final personalRecordRepositoryProvider =
    Provider<PersonalRecordRepository>((ref) {
  return LocalPersonalRecordRepository(ref.watch(sharedPreferencesProvider));
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return LocalHabitRepository(ref.watch(sharedPreferencesProvider));
});

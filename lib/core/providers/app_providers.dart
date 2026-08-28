// Riverpod providers for FitX
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../../features/ai/adaptive_workout/data/repos/local_adaptive_workout_repository.dart';
import '../../features/ai/adaptive_workout/domain/repos/adaptive_workout_repository.dart';
import '../../features/auth/data/repos/local_auth_repository.dart';
import '../../features/auth/data/repos/supabase_auth_repository.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/exercise_library/data/repos/local_exercise_repository.dart';
import '../../features/exercise_library/domain/repos/exercise_repository.dart';
import '../../features/workouts/data/repos/local_personal_record_repository.dart';
import '../../features/workouts/data/repos/local_workout_repository.dart';
import '../../features/workouts/data/repos/supabase_personal_record_repository.dart';
import '../../features/workouts/data/repos/supabase_workout_repository.dart';
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

SupabaseClient? _getSafeSupabaseClient() {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

/// Repositories (Switches between Supabase & Local with fallback)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = LocalAuthRepository(prefs);
  final client = _getSafeSupabaseClient();
  if (client != null) {
    return SupabaseAuthRepository(client, fallback: local);
  }
  return local;
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return LocalExerciseRepository();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = LocalWorkoutRepository(prefs);
  final client = _getSafeSupabaseClient();
  if (client != null) {
    return SupabaseWorkoutRepository(client, fallback: local);
  }
  return local;
});

final adaptiveWorkoutRepositoryProvider =
    Provider<AdaptiveWorkoutRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  return LocalAdaptiveWorkoutRepository(prefs, exerciseRepo);
});

final personalRecordRepositoryProvider =
    Provider<PersonalRecordRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = LocalPersonalRecordRepository(prefs);
  final client = _getSafeSupabaseClient();
  if (client != null) {
    return SupabasePersonalRecordRepository(client, fallback: local);
  }
  return local;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return LocalHabitRepository(ref.watch(sharedPreferencesProvider));
});

// App Router for FitX Navigation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/adaptive_workout/presentation/screens/adaptive_workout_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/exercise_library/domain/entities/exercise_entity.dart';
import '../../features/exercise_library/presentation/screens/exercise_browse_screen.dart';
import '../../features/exercise_library/presentation/screens/exercise_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/workouts/presentation/screens/workout_logging_screen.dart';

/// Route paths for consistent navigation
class AppRoutes {
  static const String auth = '/';
  static const String home = '/home';
  static const String workoutLogging = '/workout';
  static const String generateWorkout = '/generate-workout';
  static const String exerciseLibrary = '/exercise-library';
  static const String exerciseDetail = '/exercise-library/detail';
}

/// Router with auth-aware redirect.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<AsyncValue<AuthState>>(
    const AsyncValue.loading(),
  );

  ref.listen(authNotifierProvider, (_, next) => authState.value = next);
  // Seed with the current value so the first redirect decision is correct.
  authState.value = ref.read(authNotifierProvider);

  ref.onDispose(authState.dispose);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    debugLogDiagnostics: false,
    refreshListenable: authState,
    redirect: (context, state) {
      final auth = authState.value;
      final isLoading = auth.isLoading;
      final signedIn = auth.valueOrNull?.isSignedIn ?? false;
      final onAuthScreen = state.matchedLocation == AppRoutes.auth;

      // While we don't know yet, stay put (initial location is auth).
      if (isLoading) return null;

      if (!signedIn && !onAuthScreen) return AppRoutes.auth;
      if (signedIn && onAuthScreen) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutLogging,
        name: 'workoutLogging',
        builder: (context, state) => const WorkoutLoggingScreen(),
      ),
      GoRoute(
        path: AppRoutes.generateWorkout,
        name: 'generateWorkout',
        builder: (context, state) => const AdaptiveWorkoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.exerciseLibrary,
        name: 'exerciseLibrary',
        builder: (context, state) => const ExerciseBrowseScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'exerciseDetail',
            builder: (context, state) {
              final exercise = state.extra! as ExerciseEntity;
              return ExerciseDetailScreen(exercise: exercise);
            },
          ),
        ],
      ),
    ],
  );
});

// App Router for FitX Navigation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/adaptive_workout/presentation/screens/adaptive_workout_screen.dart';
import '../../features/ai/fitness_coach/presentation/screens/fitness_coach_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/exercise_library/domain/entities/exercise_entity.dart';
import '../../features/exercise_library/presentation/screens/exercise_browse_screen.dart';
import '../../features/exercise_library/presentation/screens/exercise_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/nutrition/presentation/screens/food_search_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../../features/progress/presentation/screens/body_metrics_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/progress/presentation/screens/summary_report_screen.dart';
import '../../features/settings/presentation/screens/export_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shared/presentation/screens/badges_screen.dart';
import '../../features/shared/presentation/screens/challenges_screen.dart';
import '../../features/shared/presentation/screens/leaderboard_screen.dart';
import '../../features/shared/presentation/widgets/main_navigation_scaffold.dart';
import '../../features/workouts/presentation/screens/personal_records_screen.dart';
import '../../features/workouts/presentation/screens/workout_logging_screen.dart';
import '../../features/workouts/presentation/screens/workout_templates_screen.dart';

/// Route paths for consistent navigation
class AppRoutes {
  static const String auth = '/';
  static const String home = '/home';
  static const String workoutLogging = '/workout';
  static const String generateWorkout = '/generate-workout';
  static const String exerciseLibrary = '/exercise-library';
  static const String exerciseDetail = '/exercise-library/detail';
  static const String progress = '/progress';
  static const String bodyMetrics = '/body-metrics';
  static const String nutrition = '/nutrition';
  static const String addFood = '/nutrition/add';
  static const String fitnessCoach = '/coach';
  static const String badges = '/badges';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String workoutTemplates = '/templates';
  static const String summaryReport = '/summary-report';
  static const String personalRecords = '/personal-records';
  static const String settings = '/settings';
  static const String export = '/export';
}

/// Global navigator key
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router with auth-aware redirect and persistent 5-tab bottom navigation shell.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<AsyncValue<AuthState>>(
    const AsyncValue.loading(),
  );

  ref.listen(authNotifierProvider, (_, next) => authState.value = next);
  // Seed with the current value so the first redirect decision is correct.
  authState.value = ref.read(authNotifierProvider);

  ref.onDispose(authState.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
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
      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // ── Persistent 5-Tab Navigation Shell ─────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Leaderboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.leaderboard,
                name: 'leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),

          // Tab 2: Workout / Templates
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workoutTemplates,
                name: 'workoutTemplates',
                builder: (context, state) => const WorkoutTemplatesScreen(),
              ),
            ],
          ),

          // Tab 3: Nutrition / Food Tracker
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                name: 'nutrition',
                builder: (context, state) => const NutritionScreen(),
              ),
            ],
          ),

          // Tab 4: AI Coach
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.fitnessCoach,
                name: 'fitnessCoach',
                builder: (context, state) => const FitnessCoachScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Modal & Secondary Screens (Presented on top of shell) ──────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.workoutLogging,
        name: 'workoutLogging',
        builder: (context, state) => const WorkoutLoggingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.generateWorkout,
        name: 'generateWorkout',
        builder: (context, state) => const AdaptiveWorkoutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.exerciseLibrary,
        name: 'exerciseLibrary',
        builder: (context, state) => const ExerciseBrowseScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'detail',
            name: 'exerciseDetail',
            builder: (context, state) {
              final exercise = state.extra! as ExerciseEntity;
              return ExerciseDetailScreen(exercise: exercise);
            },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.progress,
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.bodyMetrics,
        name: 'bodyMetrics',
        builder: (context, state) => const BodyMetricsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addFood,
        name: 'addFood',
        builder: (context, state) {
          final meal = state.uri.queryParameters['meal'];
          return FoodSearchScreen(preselectedMeal: meal);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.badges,
        name: 'badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.challenges,
        name: 'challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.summaryReport,
        name: 'summaryReport',
        builder: (context, state) => const SummaryReportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.personalRecords,
        name: 'personalRecords',
        builder: (context, state) => const PersonalRecordsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.export,
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );
});

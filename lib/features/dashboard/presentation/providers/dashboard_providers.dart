// Dashboard providers: computed views over existing workout, nutrition & habit data.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';

// ─── Today's Workout Summary ─────────────────────────────────────────────────

class TodayWorkoutSummary {
  final int workoutCount;
  final double totalDurationMinutes;
  final double totalCaloriesBurned;

  const TodayWorkoutSummary({
    this.workoutCount = 0,
    this.totalDurationMinutes = 0,
    this.totalCaloriesBurned = 0,
  });
}

final todayWorkoutSummaryProvider =
    FutureProvider<TodayWorkoutSummary>((ref) async {
  final workouts = await ref.watch(workoutsProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayWorkouts = workouts.where((w) {
    final d = DateTime(w.date.year, w.date.month, w.date.day);
    return d == today;
  }).toList();

  return TodayWorkoutSummary(
    workoutCount: todayWorkouts.length,
    totalDurationMinutes:
        todayWorkouts.fold(0.0, (sum, w) => sum + w.durationMinutes),
    totalCaloriesBurned:
        todayWorkouts.fold(0.0, (sum, w) => sum + w.totalCaloriesBurned),
  );
});

// ─── Today's Overall Progress ────────────────────────────────────────────────

/// A 0.0–1.0 progress value computed from multiple signals:
/// - Did the user work out today? (0 or 1) → weight 40%
/// - Nutrition: calories consumed / goal → weight 30%
/// - Habits: completed / total → weight 30%
final todayProgressProvider = FutureProvider<double>((ref) async {
  // Workout component
  final workoutSummary = await ref.watch(todayWorkoutSummaryProvider.future);
  final workoutDone = workoutSummary.workoutCount > 0 ? 1.0 : 0.0;

  // Nutrition component
  double nutritionProgress = 0.0;
  try {
    final nutrition = await ref.watch(dailyNutritionProvider.future);
    if (nutrition.goal.dailyCalories > 0) {
      nutritionProgress =
          (nutrition.totalCalories / nutrition.goal.dailyCalories).clamp(0.0, 1.0);
    }
  } catch (_) {}

  // Habits component
  double habitsProgress = 0.0;
  try {
    final habitSummary = await ref.watch(habitSummaryProvider.future);
    habitsProgress = habitSummary.progress;
  } catch (_) {}

  // Weighted average
  return (workoutDone * 0.4) + (nutritionProgress * 0.3) + (habitsProgress * 0.3);
});

// ─── Weekly Activity (last 7 days) ───────────────────────────────────────────

class DailyActivity {
  final String dayLabel; // e.g. "M", "T", "W"
  final DateTime date;
  final double durationMinutes;
  final int workoutCount;

  const DailyActivity({
    required this.dayLabel,
    required this.date,
    this.durationMinutes = 0,
    this.workoutCount = 0,
  });
}

final weeklyActivityProvider =
    FutureProvider<List<DailyActivity>>((ref) async {
  final workouts = await ref.watch(workoutsProvider.future);
  final now = DateTime.now();

  const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final result = <DailyActivity>[];
  for (var i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final dayWorkouts = workouts.where((w) {
      final d = DateTime(w.date.year, w.date.month, w.date.day);
      return d == date;
    }).toList();

    final duration =
        dayWorkouts.fold<double>(0.0, (sum, w) => sum + w.durationMinutes);

    result.add(DailyActivity(
      dayLabel: dayLabels[date.weekday - 1],
      date: date,
      durationMinutes: duration,
      workoutCount: dayWorkouts.length,
    ));
  }
  return result;
});

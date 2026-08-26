import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/repos/local_habit_repository.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repos/habit_repository.dart';

/// Repository provider for Habit operations
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalHabitRepository(prefs);
});

/// Currently selected date in the Habit Tracker (normalized to midnight)
final selectedHabitDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Notifier managing active habits list with CRUD
class HabitsNotifier extends AsyncNotifier<List<HabitEntity>> {
  @override
  Future<List<HabitEntity>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabits();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(habitRepositoryProvider).getHabits();
    });
  }

  Future<HabitEntity> createHabit({
    required String name,
    String description = '',
    required int iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    required int colorValue,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    final habit = await repo.createHabit(
      name: name,
      description: description,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage,
      colorValue: colorValue,
    );
    await refresh();
    ref.invalidate(habitStreaksProvider);
    ref.invalidate(habitSummaryProvider);
    return habit;
  }

  Future<void> updateHabit(HabitEntity habit) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.updateHabit(habit);
    await refresh();
  }

  Future<void> deleteHabit(String habitId) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(habitId);
    await refresh();
    ref.invalidate(habitStreaksProvider);
    ref.invalidate(habitSummaryProvider);
  }
}

final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, List<HabitEntity>>(
  HabitsNotifier.new,
);

/// Notifier managing completed habit IDs for the selected date
class DailyCompletionsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final date = ref.watch(selectedHabitDateProvider);
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getCompletedHabitIdsForDate(date);
  }

  Future<void> toggle(String habitId) async {
    final date = ref.read(selectedHabitDateProvider);
    final repo = ref.read(habitRepositoryProvider);
    await repo.toggleCompletion(habitId, date);

    // Optimistically or explicitly refresh
    ref.invalidateSelf();
    ref.invalidate(habitStreaksProvider);
    ref.invalidate(habitSummaryProvider);
  }
}

final dailyCompletionsProvider =
    AsyncNotifierProvider<DailyCompletionsNotifier, Set<String>>(
  DailyCompletionsNotifier.new,
);

/// Streak data for all active habits
final habitStreaksProvider =
    FutureProvider<Map<String, HabitStreakEntity>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  // Reload whenever habits change or completions update
  ref.watch(habitsProvider);
  return repo.getAllHabitStreaks();
});

/// Quick stats summary for today
class HabitSummary {
  final int total;
  final int completed;
  final double progress;

  const HabitSummary({
    required this.total,
    required this.completed,
    required this.progress,
  });
}

final habitSummaryProvider = FutureProvider<HabitSummary>((ref) async {
  final habitsAsync = ref.watch(habitsProvider);
  final completionsAsync = ref.watch(dailyCompletionsProvider);

  final habits = habitsAsync.valueOrNull ?? [];
  final completions = completionsAsync.valueOrNull ?? {};

  final total = habits.length;
  final completed = habits.where((h) => completions.contains(h.id)).length;
  final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

  return HabitSummary(
    total: total,
    completed: completed,
    progress: progress,
  );
});

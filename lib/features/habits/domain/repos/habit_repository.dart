import '../entities/habit_entity.dart';

/// Abstract contract for habit data operations.
abstract class HabitRepository {
  /// Fetches all active (non-archived) habits.
  Future<List<HabitEntity>> getHabits({bool includeArchived = false});

  /// Fetches a single habit by its ID.
  Future<HabitEntity?> getHabitById(String id);

  /// Creates and saves a new habit.
  Future<HabitEntity> createHabit({
    required String name,
    String description = '',
    required int iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    required int colorValue,
  });

  /// Updates an existing habit.
  Future<void> updateHabit(HabitEntity habit);

  /// Deletes or archives a habit by ID.
  Future<void> deleteHabit(String id, {bool softDelete = true});

  /// Toggles habit completion for a specific calendar date.
  /// Returns `true` if marked completed, `false` if unmarked.
  Future<bool> toggleCompletion(String habitId, DateTime date);

  /// Checks if a habit was completed on a specific date.
  Future<bool> isHabitCompleted(String habitId, DateTime date);

  /// Gets all completed habit IDs for a specific date.
  Future<Set<String>> getCompletedHabitIdsForDate(DateTime date);

  /// Gets completion statistics and streaks for a specific habit.
  Future<HabitStreakEntity> getHabitStreak(String habitId);

  /// Gets streak information for all active habits mapped by habit ID.
  Future<Map<String, HabitStreakEntity>> getAllHabitStreaks();
}

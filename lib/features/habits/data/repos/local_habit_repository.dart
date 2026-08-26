import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/habit_entity.dart';
import '../../domain/repos/habit_repository.dart';

class LocalHabitRepository implements HabitRepository {
  static const String _habitsKey = 'fitx_habits';
  static const String _completionsKey = 'fitx_habit_completions';

  final SharedPreferences _prefs;

  LocalHabitRepository(this._prefs);

  String _formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  DateTime _parseDateKey(String dateKey) => DateFormat('yyyy-MM-dd').parse(dateKey);

  List<HabitEntity> _readHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null) {
      return _seedDefaultHabits();
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => HabitEntity.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return _seedDefaultHabits();
    }
  }

  Future<void> _writeHabits(List<HabitEntity> habits) async {
    final data = jsonEncode(habits.map((h) => h.toMap()).toList());
    await _prefs.setString(_habitsKey, data);
  }

  List<HabitCompletionEntity> _readCompletions() {
    final raw = _prefs.getString(_completionsKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) =>
              HabitCompletionEntity.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeCompletions(List<HabitCompletionEntity> completions) async {
    final data = jsonEncode(completions.map((c) => c.toMap()).toList());
    await _prefs.setString(_completionsKey, data);
  }

  List<HabitEntity> _seedDefaultHabits() {
    final now = DateTime.now();
    final defaults = [
      HabitEntity(
        id: 'habit_water',
        name: 'Hydration Goal (3L)',
        description: 'Drink at least 3 liters of water throughout the day',
        iconCodePoint: Icons.water_drop_rounded.codePoint,
        iconFontFamily: Icons.water_drop_rounded.fontFamily,
        iconFontPackage: Icons.water_drop_rounded.fontPackage,
        colorValue: 0xFF0066FF, // secondaryBlue
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      HabitEntity(
        id: 'habit_stretch',
        name: 'Daily Mobility & Stretch',
        description: '10 minutes of full-body stretching and mobility work',
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
        iconFontFamily: Icons.self_improvement_rounded.fontFamily,
        iconFontPackage: Icons.self_improvement_rounded.fontPackage,
        colorValue: 0xFF00A859, // primaryGreen
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      HabitEntity(
        id: 'habit_sleep',
        name: '7+ Hours Sleep',
        description: 'Quality sleep for optimal recovery and energy',
        iconCodePoint: Icons.bedtime_rounded.codePoint,
        iconFontFamily: Icons.bedtime_rounded.fontFamily,
        iconFontPackage: Icons.bedtime_rounded.fontPackage,
        colorValue: 0xFF9C27B0, // Purple
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      HabitEntity(
        id: 'habit_protein',
        name: 'Hit Protein Target',
        description: 'Consume sufficient protein for muscle recovery',
        iconCodePoint: Icons.restaurant_rounded.codePoint,
        iconFontFamily: Icons.restaurant_rounded.fontFamily,
        iconFontPackage: Icons.restaurant_rounded.fontPackage,
        colorValue: 0xFFFF9500, // accentOrange
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
    _writeHabits(defaults);
    return defaults;
  }

  @override
  Future<List<HabitEntity>> getHabits({bool includeArchived = false}) async {
    final all = _readHabits();
    if (includeArchived) return all;
    return all.where((h) => !h.isArchived).toList();
  }

  @override
  Future<HabitEntity?> getHabitById(String id) async {
    final all = _readHabits();
    for (final habit in all) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  @override
  Future<HabitEntity> createHabit({
    required String name,
    String description = '',
    required int iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    required int colorValue,
  }) async {
    final now = DateTime.now();
    final newHabit = HabitEntity(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description.trim(),
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage,
      colorValue: colorValue,
      createdAt: now,
      isArchived: false,
    );

    final all = _readHabits()..add(newHabit);
    await _writeHabits(all);
    return newHabit;
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    final all = _readHabits();
    final index = all.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      all[index] = habit;
      await _writeHabits(all);
    }
  }

  @override
  Future<void> deleteHabit(String id, {bool softDelete = true}) async {
    final all = _readHabits();
    if (softDelete) {
      final index = all.indexWhere((h) => h.id == id);
      if (index != -1) {
        all[index] = all[index].copyWith(isArchived: true);
        await _writeHabits(all);
      }
    } else {
      all.removeWhere((h) => h.id == id);
      await _writeHabits(all);
      // Also cleanup completions
      final completions = _readCompletions()..removeWhere((c) => c.habitId == id);
      await _writeCompletions(completions);
    }
  }

  @override
  Future<bool> toggleCompletion(String habitId, DateTime date) async {
    final dateKey = _formatDateKey(date);
    final completions = _readCompletions();
    final existingIndex = completions.indexWhere(
      (c) => c.habitId == habitId && c.dateKey == dateKey,
    );

    if (existingIndex != -1) {
      completions.removeAt(existingIndex);
      await _writeCompletions(completions);
      return false;
    } else {
      final newCompletion = HabitCompletionEntity(
        id: const Uuid().v4(),
        habitId: habitId,
        dateKey: dateKey,
        completedAt: DateTime.now(),
      );
      completions.add(newCompletion);
      await _writeCompletions(completions);
      return true;
    }
  }

  @override
  Future<bool> isHabitCompleted(String habitId, DateTime date) async {
    final dateKey = _formatDateKey(date);
    final completions = _readCompletions();
    return completions.any((c) => c.habitId == habitId && c.dateKey == dateKey);
  }

  @override
  Future<Set<String>> getCompletedHabitIdsForDate(DateTime date) async {
    final dateKey = _formatDateKey(date);
    final completions = _readCompletions();
    return completions
        .where((c) => c.dateKey == dateKey)
        .map((c) => c.habitId)
        .toSet();
  }

  @override
  Future<HabitStreakEntity> getHabitStreak(String habitId) async {
    final completions = _readCompletions()
        .where((c) => c.habitId == habitId)
        .toList();

    if (completions.isEmpty) {
      return HabitStreakEntity.empty(habitId);
    }

    final dateSet = completions.map((c) => c.dateKey).toSet();
    final now = DateTime.now();
    final todayKey = _formatDateKey(now);
    final yesterdayKey = _formatDateKey(now.subtract(const Duration(days: 1)));

    final isCompletedToday = dateSet.contains(todayKey);

    // Calculate current streak
    var currentStreak = 0;
    var checkDate = isCompletedToday
        ? now
        : (dateSet.contains(yesterdayKey)
            ? now.subtract(const Duration(days: 1))
            : null);

    if (checkDate != null) {
      while (true) {
        final key = _formatDateKey(checkDate!);
        if (dateSet.contains(key)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // Calculate longest streak across history
    final sortedDates = dateSet.map((k) => _parseDateKey(k)).toList()..sort();
    var longestStreak = 0;
    var tempStreak = 0;
    DateTime? prevDate;

    for (final d in sortedDates) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diffDays = d.difference(prevDate).inDays;
        if (diffDays == 1) {
          tempStreak++;
        } else if (diffDays > 1) {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
      prevDate = d;
    }

    return HabitStreakEntity(
      habitId: habitId,
      currentStreak: currentStreak,
      longestStreak: longestStreak > currentStreak ? longestStreak : currentStreak,
      totalCompletions: completions.length,
      isCompletedToday: isCompletedToday,
    );
  }

  @override
  Future<Map<String, HabitStreakEntity>> getAllHabitStreaks() async {
    final habits = await getHabits(includeArchived: false);
    final map = <String, HabitStreakEntity>{};
    for (final h in habits) {
      map[h.id] = await getHabitStreak(h.id);
    }
    return map;
  }
}

// Local workout repository backed by SharedPreferences.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/repos/workout_repository.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  static const _workoutsKey = 'fitx_workouts';

  final SharedPreferences _prefs;

  LocalWorkoutRepository(this._prefs);

  List<WorkoutEntity> _readAll() {
    final raw = _prefs.getString(_workoutsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => WorkoutEntity.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writeAll(List<WorkoutEntity> workouts) =>
      _prefs.setString(_workoutsKey, jsonEncode(workouts.map((w) => w.toMap()).toList()));

  @override
  Future<List<WorkoutEntity>> getRecentWorkouts({int limit = 10}) async {
    final all = _readAll()
      ..sort((a, b) => b.date.compareTo(a.date));
    return all.take(limit).toList();
  }

  @override
  Future<WorkoutEntity?> getWorkoutById(String workoutId) async {
    for (final workout in _readAll()) {
      if (workout.id == workoutId) return workout;
    }
    return null;
  }

  @override
  Future<WorkoutEntity> createWorkout({
    required String title,
    required List<WorkoutExerciseEntity> exercises,
    DateTime? date,
    double durationMinutes = 0,
    String? notes,
  }) async {
    final now = DateTime.now();
    final workoutDate = date ?? now;

    final workout = WorkoutEntity(
      id: 'workout_${now.millisecondsSinceEpoch}',
      userId: 'local',
      date: workoutDate,
      title: title.trim().isEmpty ? 'Workout' : title.trim(),
      notes: notes,
      exercises: exercises,
      totalSets: exercises.fold(0, (sum, ex) => sum + ex.sets),
      totalReps: exercises.fold(0, (sum, ex) => sum + ex.reps),
      totalCaloriesBurned: _estimateCalories(exercises, durationMinutes),
      durationMinutes: durationMinutes,
      createdAt: now,
      updatedAt: now,
    );

    final all = _readAll()..add(workout);
    await _writeAll(all);
    return workout;
  }

  @override
  Future<void> deleteWorkout({required String workoutId}) async {
    final all = _readAll()..removeWhere((w) => w.id == workoutId);
    await _writeAll(all);
  }

  @override
  Future<int> getWorkoutCount() async => _readAll().length;

  @override
  Future<int> getTotalExercisesLogged() async =>
      _readAll().fold<int>(0, (sum, w) => sum + w.exercises.length);

  @override
  Future<List<WorkoutEntity>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _readAll()
        .where((w) =>
            !w.date.isBefore(startDate) && !w.date.isAfter(endDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Rough calorie estimate: ~5 kcal/min of moderate lifting, scaled by
  /// the number of working sets.
  double _estimateCalories(
      List<WorkoutExerciseEntity> exercises, double durationMinutes) {
    final totalSets = exercises.fold(0, (sum, ex) => sum + ex.sets);
    final base = durationMinutes > 0 ? durationMinutes * 5 : totalSets * 8.0;
    return (base).roundToDouble();
  }
}

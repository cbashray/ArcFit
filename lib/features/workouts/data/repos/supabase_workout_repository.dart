import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/repos/workout_repository.dart';
import 'local_workout_repository.dart';

/// Supabase implementation of [WorkoutRepository] with local fallback.
class SupabaseWorkoutRepository implements WorkoutRepository {
  final sb.SupabaseClient _client;
  final LocalWorkoutRepository? _fallback;
  static const _uuid = Uuid();

  SupabaseWorkoutRepository(this._client, {LocalWorkoutRepository? fallback})
      : _fallback = fallback;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<WorkoutEntity>> getRecentWorkouts({int limit = 10}) async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getRecentWorkouts(limit: limit) ?? [];
    }

    try {
      final response = await _client
          .from('workouts')
          .select('''
            id,
            user_id,
            title,
            duration_minutes,
            notes,
            started_at,
            completed_at,
            created_at,
            workout_exercises (
              id,
              exercise_id,
              exercise_name,
              order,
              workout_sets (
                id,
                set_number,
                weight_kg,
                reps,
                rpe,
                is_completed
              )
            )
          ''')
          .eq('user_id', uid)
          .order('started_at', ascending: false)
          .limit(limit);

      final list = (response as List<dynamic>)
          .map((row) => _mapToEntity(row as Map<String, dynamic>))
          .toList();

      if (list.isEmpty && _fallback != null) {
        return await _fallback.getRecentWorkouts(limit: limit);
      }
      return list;
    } catch (_) {
      return await _fallback?.getRecentWorkouts(limit: limit) ?? [];
    }
  }

  @override
  Future<WorkoutEntity?> getWorkoutById(String workoutId) async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getWorkoutById(workoutId);
    }

    try {
      final response = await _client
          .from('workouts')
          .select('''
            id,
            user_id,
            title,
            duration_minutes,
            notes,
            started_at,
            completed_at,
            created_at,
            workout_exercises (
              id,
              exercise_id,
              exercise_name,
              order,
              workout_sets (
                id,
                set_number,
                weight_kg,
                reps,
                rpe,
                is_completed
              )
            )
          ''')
          .eq('id', workoutId)
          .maybeSingle();

      if (response == null) {
        return await _fallback?.getWorkoutById(workoutId);
      }
      return _mapToEntity(response);
    } catch (_) {
      return await _fallback?.getWorkoutById(workoutId);
    }
  }

  @override
  Future<WorkoutEntity> createWorkout({
    required String title,
    required List<WorkoutExerciseEntity> exercises,
    DateTime? date,
    double durationMinutes = 0,
    String? notes,
  }) async {
    WorkoutEntity? localEntity;
    if (_fallback != null) {
      localEntity = await _fallback.createWorkout(
        title: title,
        exercises: exercises,
        date: date,
        durationMinutes: durationMinutes,
        notes: notes,
      );
    }

    final uid = _userId;
    if (uid == null) {
      if (localEntity != null) return localEntity;
      throw Exception('User not authenticated');
    }

    try {
      final workoutDate = date ?? DateTime.now();
      final workoutId = _uuid.v4();

      // 1. Insert Workout
      await _client.from('workouts').insert({
        'id': workoutId,
        'user_id': uid,
        'title': title,
        'duration_minutes': durationMinutes.toInt(),
        'notes': notes,
        'started_at': workoutDate.toIso8601String(),
        'completed_at': DateTime.now().toIso8601String(),
      });

      // 2. Insert exercises & sets
      for (int i = 0; i < exercises.length; i++) {
        final ex = exercises[i];
        final workoutExerciseId = _uuid.v4();

        await _client.from('workout_exercises').insert({
          'id': workoutExerciseId,
          'workout_id': workoutId,
          'exercise_id': ex.exerciseId,
          'exercise_name': ex.exerciseName,
          'order': i,
        });

        final setsToInsert = List.generate(ex.sets, (index) => {
          'id': _uuid.v4(),
          'workout_exercise_id': workoutExerciseId,
          'set_number': index + 1,
          'weight_kg': ex.weight ?? 0.0,
          'reps': ex.reps,
          'rpe': ex.rpe,
          'is_completed': true,
        });

        if (setsToInsert.isNotEmpty) {
          await _client.from('workout_sets').insert(setsToInsert);
        }
      }

      final entity = await getWorkoutById(workoutId);
      return entity ?? localEntity!;
    } catch (_) {
      if (localEntity != null) return localEntity;
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkout({required String workoutId}) async {
    await _fallback?.deleteWorkout(workoutId: workoutId);
    final uid = _userId;
    if (uid != null) {
      try {
        await _client.from('workouts').delete().eq('id', workoutId);
      } catch (_) {}
    }
  }

  @override
  Future<int> getWorkoutCount() async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getWorkoutCount() ?? 0;
    }

    try {
      final response = await _client
          .from('workouts')
          .select('id')
          .eq('user_id', uid);
      return (response as List<dynamic>).length;
    } catch (_) {
      return await _fallback?.getWorkoutCount() ?? 0;
    }
  }

  @override
  Future<int> getTotalExercisesLogged() async {
    final workouts = await getRecentWorkouts(limit: 100);
    return workouts.fold<int>(0, (sum, w) => sum + w.exercises.length);
  }

  @override
  Future<List<WorkoutEntity>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uid = _userId;
    if (uid == null) {
      return await _fallback?.getWorkoutsByDateRange(startDate: startDate, endDate: endDate) ?? [];
    }

    try {
      final response = await _client
          .from('workouts')
          .select('''
            id,
            user_id,
            title,
            duration_minutes,
            notes,
            started_at,
            completed_at,
            created_at,
            workout_exercises (
              id,
              exercise_id,
              exercise_name,
              order,
              workout_sets (
                id,
                set_number,
                weight_kg,
                reps,
                rpe,
                is_completed
              )
            )
          ''')
          .eq('user_id', uid)
          .gte('started_at', startDate.toIso8601String())
          .lte('started_at', endDate.toIso8601String())
          .order('started_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((row) => _mapToEntity(row as Map<String, dynamic>))
          .toList();

      if (list.isEmpty && _fallback != null) {
        return await _fallback.getWorkoutsByDateRange(startDate: startDate, endDate: endDate);
      }
      return list;
    } catch (_) {
      return await _fallback?.getWorkoutsByDateRange(startDate: startDate, endDate: endDate) ?? [];
    }
  }

  WorkoutEntity _mapToEntity(Map<String, dynamic> row) {
    final rawExercises = (row['workout_exercises'] as List<dynamic>?) ?? [];
    
    // Sort exercises by order
    rawExercises.sort((a, b) => ((a['order'] as int?) ?? 0).compareTo((b['order'] as int?) ?? 0));

    final exerciseEntities = <WorkoutExerciseEntity>[];
    int totalSets = 0;
    int totalReps = 0;

    for (final ex in rawExercises) {
      final sets = (ex['workout_sets'] as List<dynamic>?) ?? [];
      final setCount = sets.length;
      final avgWeight = sets.isNotEmpty
          ? (sets.first['weight_kg'] as num?)?.toDouble()
          : null;
      final firstReps = sets.isNotEmpty ? (sets.first['reps'] as int? ?? 10) : 10;
      final avgRpe = sets.isNotEmpty ? (sets.first['rpe'] as num?)?.toDouble() : null;

      totalSets += setCount;
      totalReps += sets.fold<int>(0, (sum, s) => sum + ((s['reps'] as int?) ?? 0));

      exerciseEntities.add(
        WorkoutExerciseEntity(
          id: ex['id'] as String,
          exerciseId: ex['exercise_id'] as String,
          exerciseName: ex['exercise_name'] as String,
          exerciseVideoUrl: '',
          sets: setCount > 0 ? setCount : 1,
          reps: firstReps,
          weight: avgWeight,
          rpe: avgRpe,
          performedAt: DateTime.tryParse(row['started_at'] as String? ?? '') ?? DateTime.now(),
        ),
      );
    }

    final startedAt = DateTime.tryParse(row['started_at'] as String? ?? '') ?? DateTime.now();
    final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '') ?? startedAt;

    return WorkoutEntity(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      date: startedAt,
      title: row['title'] as String? ?? 'Workout',
      notes: row['notes'] as String?,
      exercises: exerciseEntities,
      totalSets: totalSets,
      totalReps: totalReps,
      durationMinutes: ((row['duration_minutes'] as num?) ?? 0).toDouble(),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}

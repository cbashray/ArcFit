// Local exercise repository backed by in-memory seed data.
import 'dart:math';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/repos/exercise_repository.dart';
import '../seed/exercise_seed_data.dart';

class LocalExerciseRepository implements ExerciseRepository {
  final List<ExerciseEntity> _exercises;

  LocalExerciseRepository({List<ExerciseEntity>? exercises})
      : _exercises = exercises ?? ExerciseSeedData.exercises;

  @override
  Future<List<ExerciseEntity>> getAllExercises() async =>
      List.unmodifiable(_exercises);

  @override
  Future<List<ExerciseEntity>> getExercisesByMuscleGroup(
          String muscleGroup) async =>
      _exercises
          .where((e) =>
              e.muscleGroup.toLowerCase() == muscleGroup.toLowerCase())
          .toList();

  @override
  Future<List<ExerciseEntity>> getExercisesByEquipment(
          String equipment) async =>
      _exercises
          .where(
              (e) => e.equipment.toLowerCase() == equipment.toLowerCase())
          .toList();

  @override
  Future<ExerciseEntity?> getExerciseById(String exerciseId) async {
    for (final exercise in _exercises) {
      if (exercise.id == exerciseId) return exercise;
    }
    return null;
  }

  @override
  Future<List<ExerciseEntity>> searchExercises(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllExercises();
    return _exercises
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.muscleGroup.toLowerCase().contains(q) ||
            e.equipment.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ExerciseEntity>> getRandomExercises({
    int count = 5,
    String? excludeEquipment,
  }) async {
    final pool = _exercises
        .where((e) =>
            excludeEquipment == null || e.equipment != excludeEquipment)
        .toList()
      ..shuffle(Random());
    return pool.take(min(count, pool.length)).toList();
  }

  @override
  Future<bool> exerciseExists(String exerciseId) async =>
      _exercises.any((e) => e.id == exerciseId);
}

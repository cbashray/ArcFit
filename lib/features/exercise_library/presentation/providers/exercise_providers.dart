// Exercise providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/exercise_entity.dart';

/// All exercises from the repository.
final exercisesProvider = FutureProvider<List<ExerciseEntity>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllExercises();
});

/// Distinct muscle groups, for filter chips.
final muscleGroupsProvider = Provider<List<String>>((ref) {
  final exercises = ref.watch(exercisesProvider).valueOrNull ?? [];
  return exercises.map((e) => e.muscleGroup).toSet().toList()..sort();
});

/// Exercises filtered by search query and muscle group.
final filteredExercisesProvider =
    FutureProvider.family<List<ExerciseEntity>, ExerciseFilter>(
  (ref, filter) async {
    final all = await ref.watch(exercisesProvider.future);
    final query = filter.query.trim().toLowerCase();

    return all.where((exercise) {
      final matchesMuscle = filter.muscleGroup == 'All' ||
          exercise.muscleGroup.toLowerCase() ==
              filter.muscleGroup.toLowerCase();
      final matchesQuery = query.isEmpty ||
          exercise.name.toLowerCase().contains(query) ||
          exercise.muscleGroup.toLowerCase().contains(query) ||
          exercise.equipment.toLowerCase().contains(query);
      return matchesMuscle && matchesQuery;
    }).toList();
  },
);

/// Filter parameters for [filteredExercisesProvider].
class ExerciseFilter {
  final String query;
  final String muscleGroup;

  const ExerciseFilter({required this.query, required this.muscleGroup});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFilter &&
          query == other.query &&
          muscleGroup == other.muscleGroup;

  @override
  int get hashCode => Object.hash(query, muscleGroup);
}

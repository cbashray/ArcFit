// Workout providers: history + active workout draft
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../ai/adaptive_workout/domain/entities/workout_plan_entity.dart';
import '../../../exercise_library/domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_entity.dart';

/// Saved workout history (refreshed after each save/delete).
final workoutsProvider =
    AsyncNotifierProvider<WorkoutsNotifier, List<WorkoutEntity>>(
        WorkoutsNotifier.new);

class WorkoutsNotifier extends AsyncNotifier<List<WorkoutEntity>> {
  @override
  Future<List<WorkoutEntity>> build() {
    return ref.watch(workoutRepositoryProvider).getRecentWorkouts(limit: 20);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).getRecentWorkouts(limit: 20),
    );
  }

  Future<void> delete(String workoutId) async {
    await ref.read(workoutRepositoryProvider).deleteWorkout(workoutId: workoutId);
    await refresh();
  }
}

/// A single exercise entry being edited in the active workout.
class DraftExercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  int sets;
  int reps;
  double weight;

  DraftExercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    this.sets = 3,
    this.reps = 10,
    this.weight = 0,
  });

  factory DraftExercise.fromExercise(ExerciseEntity exercise) {
    return DraftExercise(
      exerciseId: exercise.id,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: exercise.defaultSets,
      reps: exercise.defaultReps,
      weight: exercise.defaultWeight,
    );
  }
}

/// The workout currently being built/logged.
class ActiveWorkout {
  final String title;
  final List<DraftExercise> exercises;
  final DateTime startedAt;

  const ActiveWorkout({
    this.title = '',
    this.exercises = const [],
    required this.startedAt,
  });

  ActiveWorkout copyWith({
    String? title,
    List<DraftExercise>? exercises,
  }) {
    return ActiveWorkout(
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      startedAt: startedAt,
    );
  }
}

/// Holds the in-progress workout. Null when no workout is active.
final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>(
        ActiveWorkoutNotifier.new);

class ActiveWorkoutNotifier extends Notifier<ActiveWorkout?> {
  @override
  ActiveWorkout? build() => null;

  void start({String title = ''}) {
    state = ActiveWorkout(title: title, startedAt: DateTime.now());
  }

  void setTitle(String title) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(title: title);
  }

  void addExercise(ExerciseEntity exercise) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      exercises: [...current.exercises, DraftExercise.fromExercise(exercise)],
    );
  }

  /// Add an exercise from a generated AI plan.
  void addExerciseFromPlan(WorkoutPlanExerciseEntity planExercise) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      exercises: [
        ...current.exercises,
        DraftExercise(
          exerciseId: planExercise.exerciseId,
          name: planExercise.exerciseName,
          muscleGroup: planExercise.muscleGroup,
          sets: planExercise.sets,
          reps: planExercise.reps,
          weight: planExercise.weight,
        ),
      ],
    );
  }

  void removeExercise(int index) {
    final current = state;
    if (current == null || index < 0 || index >= current.exercises.length) {
      return;
    }
    final exercises = [...current.exercises]..removeAt(index);
    state = current.copyWith(exercises: exercises);
  }

  void updateExercise(int index, DraftExercise updated) {
    final current = state;
    if (current == null || index < 0 || index >= current.exercises.length) {
      return;
    }
    final exercises = [...current.exercises]..[index] = updated;
    state = current.copyWith(exercises: exercises);
  }

  void discard() {
    state = null;
  }

  /// Persist the active workout and clear the draft.
  /// Returns the saved workout, or null if there was nothing to save.
  Future<WorkoutEntity?> finish() async {
    final current = state;
    if (current == null) return null;

    final now = DateTime.now();
    final durationMinutes =
        now.difference(current.startedAt).inSeconds / 60.0;

    final exerciseEntities = <WorkoutExerciseEntity>[
      for (var i = 0; i < current.exercises.length; i++)
        WorkoutExerciseEntity(
          id: 'log_${now.millisecondsSinceEpoch}_$i',
          exerciseId: current.exercises[i].exerciseId,
          exerciseName: current.exercises[i].name,
          exerciseVideoUrl: '',
          sets: current.exercises[i].sets,
          reps: current.exercises[i].reps,
          weight: current.exercises[i].weight,
          performedAt: now,
        ),
    ];

    final saved = await ref.read(workoutRepositoryProvider).createWorkout(
          title: current.title,
          exercises: exerciseEntities,
          date: current.startedAt,
          durationMinutes: durationMinutes,
        );

    state = null;
    await ref.read(workoutsProvider.notifier).refresh();
    return saved;
  }
}

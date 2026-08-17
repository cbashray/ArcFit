// Workout Repository Interface for FitX
import '../entities/workout_entity.dart';

abstract class WorkoutRepository {
  /// Get recent workouts, newest first
  Future<List<WorkoutEntity>> getRecentWorkouts({int limit = 10});

  /// Get a specific workout by ID
  Future<WorkoutEntity?> getWorkoutById(String workoutId);

  /// Create a new workout
  Future<WorkoutEntity> createWorkout({
    required String title,
    required List<WorkoutExerciseEntity> exercises,
    DateTime? date,
    double durationMinutes = 0,
    String? notes,
  });

  /// Delete a workout
  Future<void> deleteWorkout({required String workoutId});

  /// Get total workout count
  Future<int> getWorkoutCount();

  /// Get total exercises logged
  Future<int> getTotalExercisesLogged();

  /// Get workouts within a date range
  Future<List<WorkoutEntity>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}

// Exercise Repository Interface for FitX
import '../entities/exercise_entity.dart';

abstract class ExerciseRepository {
  /// Get all exercises
  Future<List<ExerciseEntity>> getAllExercises();

  /// Get exercises by muscle group
  Future<List<ExerciseEntity>> getExercisesByMuscleGroup(String muscleGroup);

  /// Get exercises by equipment
  Future<List<ExerciseEntity>> getExercisesByEquipment(String equipment);

  /// Get exercise by ID
  Future<ExerciseEntity?> getExerciseById(String exerciseId);

  /// Search exercises by name
  Future<List<ExerciseEntity>> searchExercises(String query);

  /// Get random exercises for a workout
  Future<List<ExerciseEntity>> getRandomExercises({
    int count = 5,
    String? excludeEquipment,
  });

  /// Check if exercise exists
  Future<bool> exerciseExists(String exerciseId);
}

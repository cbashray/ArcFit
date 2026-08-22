import '../entities/personal_record_entity.dart';

/// Abstract repository for managing personal records.
abstract class PersonalRecordRepository {
  /// All personal records for the current user.
  Future<List<PersonalRecordEntity>> getAll();

  /// Personal record for a specific exercise, or null if none exists.
  Future<PersonalRecordEntity?> getForExercise(String exerciseId);

  /// Upsert: saves if it's a new PR (higher 1RM), returns whether it was a new PR.
  Future<bool> upsert(PersonalRecordEntity pr);

  /// Delete a personal record for an exercise.
  Future<void> delete(String exerciseId);

  /// Remove all personal records (e.g., on sign-out).
  Future<void> clear();
}

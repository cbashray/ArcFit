// Adaptive Workout Repository Interface for FitX
import '../entities/workout_plan_entity.dart';

abstract class AdaptiveWorkoutRepository {
  /// Generate a workout plan from the user's goals, equipment and focus.
  Future<WorkoutPlanEntity> generateWorkoutPlan({
    required String goals,
    required String restrictions,
    required List<String> availableEquipment,
    required String targetMuscleFocus,
    required int estimatedDuration,
  });

  /// Get recently generated plans, newest first.
  Future<List<WorkoutPlanEntity>> getRecentPlans({int limit = 10});

  /// Delete a generated plan.
  Future<void> deletePlan({required String planId});
}

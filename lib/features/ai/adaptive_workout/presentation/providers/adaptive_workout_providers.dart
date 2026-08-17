// AI workout generator providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/app_providers.dart';
import '../../domain/entities/workout_plan_entity.dart';

/// The most recently generated plan.
final generatedPlanProvider = StateNotifierProvider<GeneratedPlanNotifier,
    AsyncValue<WorkoutPlanEntity?>>(GeneratedPlanNotifier.new);

class GeneratedPlanNotifier
    extends StateNotifier<AsyncValue<WorkoutPlanEntity?>> {
  final Ref _ref;

  GeneratedPlanNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> generate({
    required String goal,
    required String restrictions,
    required List<String> equipment,
    required String muscleFocus,
    required int duration,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Small delay so the generation feels intentional in the UI.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final plan = await _ref
          .read(adaptiveWorkoutRepositoryProvider)
          .generateWorkoutPlan(
            goals: goal,
            restrictions: restrictions,
            availableEquipment: equipment,
            targetMuscleFocus: muscleFocus,
            estimatedDuration: duration,
          );
      state = AsyncValue.data(plan);
      // Keep history in sync.
      await _ref.read(planHistoryProvider.notifier).refresh();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Previously generated plans.
final planHistoryProvider =
    AsyncNotifierProvider<PlanHistoryNotifier, List<WorkoutPlanEntity>>(
        PlanHistoryNotifier.new);

class PlanHistoryNotifier extends AsyncNotifier<List<WorkoutPlanEntity>> {
  @override
  Future<List<WorkoutPlanEntity>> build() {
    return ref.watch(adaptiveWorkoutRepositoryProvider).getRecentPlans();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(adaptiveWorkoutRepositoryProvider).getRecentPlans(),
    );
  }

  Future<void> delete(String planId) async {
    await ref
        .read(adaptiveWorkoutRepositoryProvider)
        .deletePlan(planId: planId);
    await refresh();
  }
}

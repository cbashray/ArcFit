import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/repos/local_nutrition_repository.dart';
import '../../domain/entities/nutrition_entities.dart';

final nutritionRepositoryProvider = Provider<LocalNutritionRepository>((ref) {
  return LocalNutritionRepository(ref.watch(sharedPreferencesProvider));
});

// ─── Daily entries ────────────────────────────────────────────────────────────

class DailyNutritionState {
  final List<FoodEntryEntity> entries;
  final NutritionGoalEntity goal;

  const DailyNutritionState({
    required this.entries,
    required this.goal,
  });

  double get totalCalories =>
      entries.fold(0.0, (sum, e) => sum + e.calories);
  double get totalProtein =>
      entries.fold(0.0, (sum, e) => sum + e.proteinG);
  double get totalCarbs => entries.fold(0.0, (sum, e) => sum + e.carbsG);
  double get totalFat => entries.fold(0.0, (sum, e) => sum + e.fatG);

  List<FoodEntryEntity> entriesForMeal(MealType meal) =>
      entries.where((e) => e.mealType == meal).toList();
}

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final dailyNutritionProvider =
    AsyncNotifierProvider<DailyNutritionNotifier, DailyNutritionState>(
        DailyNutritionNotifier.new);

class DailyNutritionNotifier extends AsyncNotifier<DailyNutritionState> {
  @override
  Future<DailyNutritionState> build() async {
    final repo = ref.watch(nutritionRepositoryProvider);
    final date = ref.watch(selectedDateProvider);
    final entries = await repo.getEntriesForDate(date);
    final goal = repo.getGoal();
    return DailyNutritionState(entries: entries, goal: goal);
  }

  Future<void> addEntry(FoodEntryEntity entry) async {
    await ref.read(nutritionRepositoryProvider).addEntry(entry);
    await _refresh();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(nutritionRepositoryProvider).deleteEntry(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = const AsyncValue.loading();
    final repo = ref.read(nutritionRepositoryProvider);
    final date = ref.read(selectedDateProvider);
    state = await AsyncValue.guard(() async {
      final entries = await repo.getEntriesForDate(date);
      final goal = repo.getGoal();
      return DailyNutritionState(entries: entries, goal: goal);
    });
  }
}

// ─── Food search ──────────────────────────────────────────────────────────────

final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  final repo = ref.watch(nutritionRepositoryProvider);
  return repo.searchFood(query);
});

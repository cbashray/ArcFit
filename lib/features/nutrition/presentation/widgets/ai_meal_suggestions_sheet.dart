import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';

enum DietPreference {
  highProtein,
  vegetarian,
  indianCuisine,
  lowCarb,
  quickSnack,
}

class AiMealSuggestionsSheet extends ConsumerStatefulWidget {
  const AiMealSuggestionsSheet({super.key});

  @override
  ConsumerState<AiMealSuggestionsSheet> createState() =>
      _AiMealSuggestionsSheetState();
}

class _AiMealSuggestionsSheetState
    extends ConsumerState<AiMealSuggestionsSheet> {
  DietPreference _selectedDiet = DietPreference.highProtein;

  List<_MealSuggestion> _getSuggestions(
    DailyNutritionState current,
    DietPreference diet,
  ) {
    switch (diet) {
      case DietPreference.highProtein:
        return [
          const _MealSuggestion(
            name: 'Grilled Chicken & Quinoa Bowl',
            mealType: MealType.dinner,
            calories: 450,
            protein: 48,
            carbs: 35,
            fat: 10,
            description: 'Lean chicken breast, fluffy quinoa, steamed broccoli with olive oil drizzle.',
            tag: '⚡ 48g Protein',
          ),
          const _MealSuggestion(
            name: 'Egg White & Whey Protein Pancake',
            mealType: MealType.breakfast,
            calories: 320,
            protein: 38,
            carbs: 28,
            fat: 4,
            description: '4 egg whites, 1 scoop vanilla whey, rolled oats blended and pan-toasted.',
            tag: '🥞 Power Breakfast',
          ),
          const _MealSuggestion(
            name: 'Tuna & Greek Yogurt Salad',
            mealType: MealType.lunch,
            calories: 280,
            protein: 42,
            carbs: 8,
            fat: 6,
            description: 'Canned tuna in spring water mixed with non-fat Greek yogurt, celery, and lime.',
            tag: '🥗 Low Calorie',
          ),
        ];

      case DietPreference.vegetarian:
        return [
          const _MealSuggestion(
            name: 'Paneer & Soya Chunks Stir-Fry',
            mealType: MealType.dinner,
            calories: 380,
            protein: 36,
            carbs: 18,
            fat: 16,
            description: 'Low-fat paneer (100g) + soya chunks (40g) tossed with bell peppers and cumin.',
            tag: '🌱 36g Veg Protein',
          ),
          const _MealSuggestion(
            name: 'Greek Yogurt Berry Parfait',
            mealType: MealType.snack,
            calories: 220,
            protein: 22,
            carbs: 24,
            fat: 3,
            description: '200g Greek yogurt, handful of blueberries, 1 tbsp chia seeds.',
            tag: '🫐 Antioxidant Rich',
          ),
          const _MealSuggestion(
            name: 'Tofu & Edamame Brown Rice Bowl',
            mealType: MealType.lunch,
            calories: 420,
            protein: 30,
            carbs: 48,
            fat: 12,
            description: 'Pan-seared firm tofu, steamed edamame, baby spinach over brown rice.',
            tag: '🌿 Plant Powered',
          ),
        ];

      case DietPreference.indianCuisine:
        return [
          const _MealSuggestion(
            name: 'Dal Tadka with 2 Multigrain Rotis',
            mealType: MealType.lunch,
            calories: 360,
            protein: 18,
            carbs: 58,
            fat: 8,
            description: 'Yellow moong dal with garlic-cumin tadka and 2 fiber-rich whole wheat rotis.',
            tag: '🇮🇳 Classic Indian',
          ),
          const _MealSuggestion(
            name: 'Palak Paneer with Brown Rice',
            mealType: MealType.dinner,
            calories: 410,
            protein: 26,
            carbs: 42,
            fat: 14,
            description: 'Pureed spiced spinach gravy with grilled low-fat paneer cubes.',
            tag: '🥬 Iron & Protein',
          ),
          const _MealSuggestion(
            name: 'Roasted Chana & Sprouts Chaat',
            mealType: MealType.snack,
            calories: 180,
            protein: 14,
            carbs: 26,
            fat: 2,
            description: 'Moong bean sprouts, chopped tomatoes, onions, chaat masala, lemon juice.',
            tag: '🍋 Healthy Chaat',
          ),
        ];

      case DietPreference.lowCarb:
        return [
          const _MealSuggestion(
            name: 'Salmon Fillet & Asparagus',
            mealType: MealType.dinner,
            calories: 420,
            protein: 40,
            carbs: 4,
            fat: 26,
            description: 'Wild salmon pan-seared in grass-fed butter with grilled garlic asparagus.',
            tag: '🐟 Omega-3 Rich',
          ),
          const _MealSuggestion(
            name: 'Avocado & Whole Egg Scramble',
            mealType: MealType.breakfast,
            calories: 340,
            protein: 20,
            carbs: 6,
            fat: 26,
            description: '3 whole eggs scrambled with baby spinach and half sliced avocado.',
            tag: '🥑 Keto Friendly',
          ),
        ];

      case DietPreference.quickSnack:
        return [
          const _MealSuggestion(
            name: 'Whey Isolate Shake & Banana',
            mealType: MealType.snack,
            calories: 240,
            protein: 27,
            carbs: 28,
            fat: 2,
            description: '1 scoop whey protein isolate mixed with chilled water + 1 medium ripe banana.',
            tag: '⚡ 2 Min Prep',
          ),
          const _MealSuggestion(
            name: 'Peanut Butter on Rice Cakes',
            mealType: MealType.snack,
            calories: 210,
            protein: 8,
            carbs: 22,
            fat: 10,
            description: '2 whole grain brown rice cakes with 1.5 tbsp natural unsweetened peanut butter.',
            tag: '🥜 Pre-Workout Energy',
          ),
        ];
    }
  }

  void _addSuggestionToLog(_MealSuggestion meal) {
    final foodEntry = FoodEntryEntity(
      id: const Uuid().v4(),
      userId: 'default_user',
      date: DateTime.now(),
      mealType: meal.mealType,
      foodName: meal.name,
      servingGrams: 100,
      calories: meal.calories.toDouble(),
      proteinG: meal.protein.toDouble(),
      carbsG: meal.carbs.toDouble(),
      fatG: meal.fat.toDouble(),
      isIndianFood: _selectedDiet == DietPreference.indianCuisine,
    );

    ref.read(dailyNutritionProvider.notifier).addEntry(foodEntry);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${meal.name}" to ${meal.mealType.name.toUpperCase()} 🥗'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nutritionAsync = ref.watch(dailyNutritionProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: nutritionAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        error: (e, _) => Text('Error: $e'),
        data: (nutrition) {
          final suggestions = _getSuggestions(nutrition, _selectedDiet);
          final remCal =
              (nutrition.goal.dailyCalories - nutrition.totalCalories)
                  .clamp(0.0, 3000.0)
                  .toInt();
          final remProtein =
              (nutrition.goal.proteinG - nutrition.totalProtein)
                  .clamp(0.0, 200.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, AppTheme.accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('✨', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Meal & Snack Suggestions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$remCal kcal · ${remProtein.toStringAsFixed(0)}g protein remaining today',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Diet Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'High Protein 💪',
                      selected: _selectedDiet == DietPreference.highProtein,
                      onTap: () => setState(
                          () => _selectedDiet = DietPreference.highProtein),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Vegetarian 🌱',
                      selected: _selectedDiet == DietPreference.vegetarian,
                      onTap: () => setState(
                          () => _selectedDiet = DietPreference.vegetarian),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Indian 🇮🇳',
                      selected: _selectedDiet == DietPreference.indianCuisine,
                      onTap: () => setState(
                          () => _selectedDiet = DietPreference.indianCuisine),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Low Carb 🥑',
                      selected: _selectedDiet == DietPreference.lowCarb,
                      onTap: () => setState(
                          () => _selectedDiet = DietPreference.lowCarb),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Quick Snack ⚡',
                      selected: _selectedDiet == DietPreference.quickSnack,
                      onTap: () => setState(
                          () => _selectedDiet = DietPreference.quickSnack),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Suggestions list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final meal = suggestions[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF252525)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333333)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  meal.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meal.tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🔥 ${meal.calories} kcal · 🥩 ${meal.protein}g P · 🍚 ${meal.carbs}g C · 🥑 ${meal.fat}g F',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _addSuggestionToLog(meal),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 11),
                                ),
                                child: const Text('+ Add to Log'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _MealSuggestion {
  final String name;
  final MealType mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String description;
  final String tag;

  const _MealSuggestion({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.description,
    required this.tag,
  });
}

/// Helper function to open AI Meal Suggestions Sheet
void showAiMealSuggestionsModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AiMealSuggestionsSheet(),
  );
}

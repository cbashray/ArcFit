import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/ai_meal_suggestions_sheet.dart';
import '../widgets/water_intake_widget.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(dailyNutritionProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition 🥗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Food',
            onPressed: () => context.pushNamed('addFood'),
          ),
        ],
      ),
      body: nutritionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (nutrition) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date selector
              _DateRow(
                date: selectedDate,
                onPrev: () => ref
                    .read(selectedDateProvider.notifier)
                    .state = selectedDate
                    .subtract(const Duration(days: 1)),
                onNext: () {
                  final next =
                      selectedDate.add(const Duration(days: 1));
                  if (!next.isAfter(DateTime.now())) {
                    ref.read(selectedDateProvider.notifier).state = next;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Macro ring chart
              _MacroRingCard(nutrition: nutrition),
              const SizedBox(height: 16),

              // Calorie progress bar
              _CalorieProgressCard(nutrition: nutrition),
              const SizedBox(height: 16),

              // AI Meal Suggestions Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, AppTheme.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Meal Suggestions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Get customized recipes to hit your remaining macros.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => showAiMealSuggestionsModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Suggest'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Water Intake Widget
              const WaterIntakeWidget(),
              const SizedBox(height: 16),

              // Meal sections
              for (final meal in MealType.values) ...[
                _MealSection(
                  meal: meal,
                  entries: nutrition.entriesForMeal(meal),
                  onDelete: (id) =>
                      ref.read(dailyNutritionProvider.notifier).deleteEntry(id),
                  onAddFood: () => context.pushNamed(
                    'addFood',
                    queryParameters: {'meal': meal.name},
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateRow(
      {required this.date, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPrev,
        ),
        Text(
          isToday ? 'Today' : DateFormat('EEE, MMM d').format(date),
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: isToday ? null : onNext,
        ),
      ],
    );
  }
}

class _MacroRingCard extends StatelessWidget {
  final DailyNutritionState nutrition;

  const _MacroRingCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCals = nutrition.totalCalories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 120,
            height: 120,
            child: totalCals == 0
                ? Center(
                    child: Text('No food\nlogged',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: [
                        PieChartSectionData(
                          value: nutrition.totalProtein * 4,
                          color: AppTheme.primaryGreen,
                          radius: 24,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: nutrition.totalCarbs * 4,
                          color: AppTheme.secondaryBlue,
                          radius: 24,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: nutrition.totalFat * 9,
                          color: AppTheme.accentOrange,
                          radius: 24,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 20),

          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroLegendRow(
                  label: 'Protein',
                  value: '${nutrition.totalProtein.round()}g',
                  goal: '${nutrition.goal.proteinG.round()}g',
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 8),
                _MacroLegendRow(
                  label: 'Carbs',
                  value: '${nutrition.totalCarbs.round()}g',
                  goal: '${nutrition.goal.carbsG.round()}g',
                  color: AppTheme.secondaryBlue,
                ),
                const SizedBox(height: 8),
                _MacroLegendRow(
                  label: 'Fat',
                  value: '${nutrition.totalFat.round()}g',
                  goal: '${nutrition.goal.fatG.round()}g',
                  color: AppTheme.accentOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroLegendRow extends StatelessWidget {
  final String label;
  final String value;
  final String goal;
  final Color color;

  const _MacroLegendRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(' / $goal',
            style: TextStyle(
                fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}

class _CalorieProgressCard extends StatelessWidget {
  final DailyNutritionState nutrition;

  const _CalorieProgressCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (nutrition.totalCalories / nutrition.goal.dailyCalories)
        .clamp(0.0, 1.0);
    final remaining =
        nutrition.goal.dailyCalories - nutrition.totalCalories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Calories',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${nutrition.totalCalories.round()} / ${nutrition.goal.dailyCalories.round()} kcal',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                pct >= 1.0 ? AppTheme.errorRed : AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remaining > 0
                ? '${remaining.round()} kcal remaining'
                : '${(-remaining).round()} kcal over goal',
            style: TextStyle(
              fontSize: 12,
              color: remaining > 0
                  ? Colors.grey.shade600
                  : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final MealType meal;
  final List<FoodEntryEntity> entries;
  final ValueChanged<String> onDelete;
  final VoidCallback onAddFood;

  const _MealSection({
    required this.meal,
    required this.entries,
    required this.onDelete,
    required this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    final mealCalories =
        entries.fold(0.0, (sum, e) => sum + e.calories);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Text(meal.emoji,
                style: const TextStyle(fontSize: 22)),
            title: Text(meal.displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            trailing: Text(
              '${mealCalories.round()} kcal',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          if (entries.isNotEmpty) ...[
            const Divider(height: 1),
            ...entries.map(
              (entry) => ListTile(
                dense: true,
                title: Text(entry.foodName,
                    style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  '${entry.servingGrams.round()}g • ${entry.proteinG.round()}p / '
                  '${entry.carbsG.round()}c / ${entry.fatG.round()}f',
                  style:
                      const TextStyle(fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.calories.round()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 16, color: Colors.grey.shade400),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onDelete(entry.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddFood,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add food'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: BorderSide(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

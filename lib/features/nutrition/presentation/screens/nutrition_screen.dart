import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../domain/entities/nutrition_entities.dart'
    show MealType, FoodEntryEntity;
import '../providers/nutrition_providers.dart'
    show dailyNutritionProvider, selectedDateProvider, DailyNutritionState;
import '../widgets/ai_meal_suggestions_sheet.dart'
    show showAiMealSuggestionsModal;
import '../widgets/water_intake_widget.dart'
    show WaterIntakeWidget;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(dailyNutritionProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, size: 22, color: theme.colorScheme.onSurfaceVariant),
            tooltip: 'Add Food',
            onPressed: () => context.pushNamed('addFood'),
          ),
        ],
      ),
      body: nutritionAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.error)),
        ),
        data: (nutrition) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, 96),
            children: [
              // Date selector
              _DateRow(
                date: selectedDate,
                onPrev: () => ref
                    .read(selectedDateProvider.notifier)
                    .state = selectedDate.subtract(const Duration(days: 1)),
                onNext: () {
                  final next = selectedDate.add(const Duration(days: 1));
                  if (!next.isAfter(DateTime.now())) {
                    ref.read(selectedDateProvider.notifier).state = next;
                  }
                },
              ),
              const SizedBox(height: AppTheme.space4),

              // Macro Rings
              _MacroRingsCard(nutrition: nutrition),
              const SizedBox(height: AppTheme.space4),

              // Calorie progress bar
              _CalorieProgressCard(nutrition: nutrition),
              const SizedBox(height: AppTheme.space4),

              // AI Meal Suggestions Banner
              _AiMealSuggestionsBanner(),
              const SizedBox(height: AppTheme.space4),

              // Water Intake Widget
              const WaterIntakeWidget(),
              const SizedBox(height: AppTheme.space4),

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
                const SizedBox(height: AppTheme.space3),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// DATE ROW - Compact date selector
// ══════════════════════════════════════════════════════════════════════════════════════

class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateRow({required this.date, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 22, color: theme.colorScheme.onSurface),
          onPressed: onPrev,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              isToday ? 'Today' : DateFormat('EEE, MMM d').format(date),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, size: 22, color: isToday ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface),
          onPressed: isToday ? null : onNext,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// MACRO RINGS CARD - 3 macro rings (protein, carbs, fat)
// ═══════════════════════════════════════════════════════════════════════════════════════

class _MacroRingsCard extends StatelessWidget {
  final DailyNutritionState nutrition;

  const _MacroRingsCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final proteinPct = nutrition.goal.proteinG > 0
        ? (nutrition.totalProtein / nutrition.goal.proteinG).clamp(0.0, 1.0)
        : 0.0;
    final carbsPct = nutrition.goal.carbsG > 0
        ? (nutrition.totalCarbs / nutrition.goal.carbsG).clamp(0.0, 1.0)
        : 0.0;
    final fatPct = nutrition.goal.fatG > 0
        ? (nutrition.totalFat / nutrition.goal.fatG).clamp(0.0, 1.0)
        : 0.0;

    return DataCard(
      child: Column(
        children: [
          Row(
            children: [
              // Protein Ring
              Expanded(
                child: _MacroRing(
                  progress: proteinPct,
                  value: '${nutrition.totalProtein.round()}g',
                  goal: '${nutrition.goal.proteinG.round()}g',
                  label: 'Protein',
                  color: theme.colorScheme.primary,
                  size: 110,
                  strokeWidth: 10,
                ),
              ),
              // Carbs Ring
              Expanded(
                child: _MacroRing(
                  progress: carbsPct,
                  value: '${nutrition.totalCarbs.round()}g',
                  goal: '${nutrition.goal.carbsG.round()}g',
                  label: 'Carbs',
                  color: theme.colorScheme.secondary,
                  size: 110,
                  strokeWidth: 10,
                ),
              ),
              // Fat Ring
              Expanded(
                child: _MacroRing(
                  progress: fatPct,
                  value: '${nutrition.totalFat.round()}g',
                  goal: '${nutrition.goal.fatG.round()}g',
                  label: 'Fat',
                  color: theme.colorScheme.tertiary,
                  size: 110,
                  strokeWidth: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final double progress;
  final String value;
  final String goal;
  final String label;
  final Color color;
  final double size;
  final double strokeWidth;

  const _MacroRing({
    required this.progress,
    required this.value,
    required this.goal,
    required this.label,
    required this.color,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: strokeWidth,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.15)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: size * 0.16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'of $goal',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// CALORIE PROGRESS CARD - Full-width calorie bar
// ═══════════════════════════════════════════════════════════════════════════════════════

class _CalorieProgressCard extends StatelessWidget {
  final DailyNutritionState nutrition;

  const _CalorieProgressCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (nutrition.totalCalories / nutrition.goal.dailyCalories).clamp(0.0, 1.0);
    final remaining = nutrition.goal.dailyCalories - nutrition.totalCalories;

    return DataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Calories',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${nutrition.totalCalories.round()} / ${nutrition.goal.dailyCalories.round()} kcal',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                pct >= 1.0 ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            children: [
              Expanded(
                child: Text(
                  remaining > 0
                      ? '${remaining.round()} kcal remaining'
                      : '${(-remaining).round()} kcal over goal',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: remaining > 0
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.error,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (pct >= 1.0 ? theme.colorScheme.error : theme.colorScheme.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${(pct * 100).round()}%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: pct >= 1.0 ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// AI MEAL SUGGESTIONS BANNER
// ═══════════════════════════════════════════════════════════════════════════════════════

class _AiMealSuggestionsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Meal Suggestions',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get customized recipes to hit your remaining macros.',
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => showAiMealSuggestionsModal(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            child: const Text('Suggest'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// MEAL SECTION - Collapsible meal with entries
// ═══════════════════════════════════════════════════════════════════════════════════════

class _MealSection extends StatefulWidget {
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
  State<_MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<_MealSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealCalories = widget.entries.fold(0.0, (sum, e) => sum + e.calories);

    return DataCard(
      child: Column(
        children: [
          // Meal header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
              child: Row(
                children: [
                  Text(widget.meal.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meal.displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${widget.entries.length} items',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${mealCalories.round()} kcal',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space2),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // Meal entries
          if (_isExpanded)
            _buildMealEntries(theme, widget.entries, widget.onDelete, widget.onAddFood),
        ],
      ),
    );
  }
}

Widget _buildMealEntries(ThemeData theme, List<FoodEntryEntity> entries, Function(String) onDelete, VoidCallback onAddFood) {
  return Column(
    children: [
      if (entries.isNotEmpty) ...[
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        ...entries.map(
          (entry) => _FoodEntryTile(
            entry: entry,
            onDelete: () => onDelete(entry.id),
          ),
        ),
      ] else
        Padding(
          padding: const EdgeInsets.all(AppTheme.space4),
          child: Center(
            child: Text(
              'No foods logged',
              style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      // Add food button
      Padding(
        padding: const EdgeInsets.all(AppTheme.space3),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddFood,
            icon: Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.primary),
            label: const Text('Add food'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
          ),
        ),
      ),
    ],
  );
}

class _FoodEntryTile extends StatelessWidget {
  final FoodEntryEntity entry;
  final VoidCallback onDelete;

  const _FoodEntryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Could open edit sheet
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space2, horizontal: AppTheme.space1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.foodName,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.servingGrams.round()}g · ${entry.proteinG.round()}P / ${entry.carbsG.round()}C / ${entry.fatG.round()}F',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Text(
                '${entry.calories.round()}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
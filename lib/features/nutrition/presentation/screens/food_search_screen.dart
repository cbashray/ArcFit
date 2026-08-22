import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  final String? preselectedMeal;

  const FoodSearchScreen({super.key, this.preselectedMeal});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _servingCtrl = TextEditingController(text: '100');
  FoodItem? _selected;
  late MealType _selectedMeal;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.preselectedMeal != null
        ? MealType.values.byName(widget.preselectedMeal!)
        : MealType.lunch;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _servingCtrl.dispose();
    super.dispose();
  }

  double get _servingGrams =>
      double.tryParse(_servingCtrl.text) ?? 100;

  double _scale(double per100g) => per100g * _servingGrams / 100;

  Future<void> _addFood() async {
    final item = _selected;
    if (item == null) return;

    final entry = FoodEntryEntity(
      id: const Uuid().v4(),
      userId: 'local',
      date: ref.read(selectedDateProvider),
      mealType: _selectedMeal,
      foodName: item.name,
      servingGrams: _servingGrams,
      calories: _scale(item.caloriesPer100g),
      proteinG: _scale(item.proteinPer100g),
      carbsG: _scale(item.carbsPer100g),
      fatG: _scale(item.fatPer100g),
      isIndianFood: item.isIndianFood,
    );

    await ref.read(dailyNutritionProvider.notifier).addEntry(entry);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to ${_selectedMeal.displayName}'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(foodSearchResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search foods (e.g. roti, paneer, oats)...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (q) {
                    ref.read(foodSearchQueryProvider.notifier).state = q;
                  },
                ),
                const SizedBox(height: 8),

                // Meal type selector
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: MealType.values.map((meal) {
                      final selected = _selectedMeal == meal;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${meal.emoji} ${meal.displayName}'),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedMeal = meal),
                          selectedColor: AppTheme.primaryGreen
                              .withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? AppTheme.primaryGreen
                                : null,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text('No foods found',
                        style:
                            TextStyle(color: Colors.grey.shade600)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final isSelected = _selected?.name == item.name;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Text(
                            item.isIndianFood ? '🇮🇳' : '🍽️',
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(item.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${item.caloriesPer100g.round()} kcal • '
                            '${item.proteinPer100g.round()}p / '
                            '${item.carbsPer100g.round()}c / '
                            '${item.fatPer100g.round()}f (per 100g)',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.primaryGreen)
                              : null,
                          onTap: () =>
                              setState(() => _selected = item),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom sheet when item selected
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Serving size
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _servingCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Serving size (g)',
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_scale(_selected!.caloriesPer100g).round()} kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            Text(
                              '${_scale(_selected!.proteinPer100g).round()}p / '
                              '${_scale(_selected!.carbsPer100g).round()}c / '
                              '${_scale(_selected!.fatPer100g).round()}f',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addFood,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                          'Add to ${_selectedMeal.displayName}'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

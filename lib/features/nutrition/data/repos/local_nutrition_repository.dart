import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/nutrition_entities.dart';

/// SharedPreferences-backed nutrition repository with a seeded Indian food database.
class LocalNutritionRepository {
  static const _entriesKey = 'fitx_food_entries';
  static const _goalKey = 'fitx_nutrition_goal';

  final SharedPreferences _prefs;
  LocalNutritionRepository(this._prefs);

  // ─── Food log ────────────────────────────────────────────────────────────

  List<FoodEntryEntity> _readAll() {
    final raw = _prefs.getString(_entriesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            FoodEntryEntity.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writeAll(List<FoodEntryEntity> entries) async {
    await _prefs.setString(
        _entriesKey, jsonEncode(entries.map((e) => e.toMap()).toList()));
  }

  Future<List<FoodEntryEntity>> getEntriesForDate(DateTime date) async {
    return _readAll()
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  Future<FoodEntryEntity> addEntry(FoodEntryEntity entry) async {
    final withId = FoodEntryEntity(
      id: entry.id.isEmpty ? const Uuid().v4() : entry.id,
      userId: entry.userId,
      date: entry.date,
      mealType: entry.mealType,
      foodName: entry.foodName,
      servingGrams: entry.servingGrams,
      calories: entry.calories,
      proteinG: entry.proteinG,
      carbsG: entry.carbsG,
      fatG: entry.fatG,
      isIndianFood: entry.isIndianFood,
    );
    final all = _readAll()..add(withId);
    await _writeAll(all);
    return withId;
  }

  Future<void> deleteEntry(String id) async {
    final all = _readAll()..removeWhere((e) => e.id == id);
    await _writeAll(all);
  }

  // ─── Goals ───────────────────────────────────────────────────────────────

  NutritionGoalEntity getGoal() {
    final raw = _prefs.getString(_goalKey);
    if (raw == null) return const NutritionGoalEntity();
    return NutritionGoalEntity.fromMap(
        Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> setGoal(NutritionGoalEntity goal) async {
    await _prefs.setString(_goalKey, jsonEncode(goal.toMap()));
  }

  // ─── Food search database ─────────────────────────────────────────────────

  List<FoodItem> searchFood(String query) {
    final q = query.toLowerCase();
    return _database
        .where((f) => f.name.toLowerCase().contains(q))
        .take(20)
        .toList();
  }

  /// Seeded database of common foods (Indian + global).
  static const _database = <FoodItem>[
    // ── Indian staples ────────────────────────────────────────────────────
    FoodItem(name: 'Roti (Chapati)', caloriesPer100g: 297, proteinPer100g: 9.9, carbsPer100g: 52.0, fatPer100g: 6.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Paratha (plain)', caloriesPer100g: 326, proteinPer100g: 8.5, carbsPer100g: 47.0, fatPer100g: 12.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'White Rice (cooked)', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.0, fatPer100g: 0.3, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Brown Rice (cooked)', caloriesPer100g: 112, proteinPer100g: 2.6, carbsPer100g: 23.5, fatPer100g: 0.9, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Dal (cooked, mixed)', caloriesPer100g: 116, proteinPer100g: 8.0, carbsPer100g: 18.0, fatPer100g: 1.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Dal Makhani', caloriesPer100g: 140, proteinPer100g: 7.0, carbsPer100g: 16.0, fatPer100g: 5.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Rajma (cooked)', caloriesPer100g: 132, proteinPer100g: 8.7, carbsPer100g: 23.0, fatPer100g: 0.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Chana Dal (cooked)', caloriesPer100g: 164, proteinPer100g: 10.3, carbsPer100g: 27.0, fatPer100g: 2.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Paneer (raw)', caloriesPer100g: 321, proteinPer100g: 21.4, carbsPer100g: 3.4, fatPer100g: 25.1, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Paneer Tikka', caloriesPer100g: 230, proteinPer100g: 16.0, carbsPer100g: 5.0, fatPer100g: 16.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Palak Paneer', caloriesPer100g: 165, proteinPer100g: 9.0, carbsPer100g: 7.0, fatPer100g: 12.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Idli (1 piece ~40g)', caloriesPer100g: 58, proteinPer100g: 2.0, carbsPer100g: 11.5, fatPer100g: 0.4, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Dosa (plain)', caloriesPer100g: 168, proteinPer100g: 4.5, carbsPer100g: 31.0, fatPer100g: 3.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Masala Dosa', caloriesPer100g: 210, proteinPer100g: 5.0, carbsPer100g: 36.0, fatPer100g: 6.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Upma', caloriesPer100g: 145, proteinPer100g: 3.5, carbsPer100g: 22.0, fatPer100g: 5.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Poha', caloriesPer100g: 135, proteinPer100g: 3.5, carbsPer100g: 26.0, fatPer100g: 3.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Sambar (per 100ml)', caloriesPer100g: 50, proteinPer100g: 2.5, carbsPer100g: 8.0, fatPer100g: 1.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Biryani (chicken)', caloriesPer100g: 195, proteinPer100g: 12.0, carbsPer100g: 24.0, fatPer100g: 5.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Biryani (veg)', caloriesPer100g: 165, proteinPer100g: 4.5, carbsPer100g: 28.0, fatPer100g: 5.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Chicken Tikka Masala', caloriesPer100g: 150, proteinPer100g: 14.0, carbsPer100g: 7.0, fatPer100g: 8.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Tandoori Chicken', caloriesPer100g: 160, proteinPer100g: 25.0, carbsPer100g: 3.0, fatPer100g: 6.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Butter Chicken', caloriesPer100g: 170, proteinPer100g: 13.0, carbsPer100g: 8.0, fatPer100g: 10.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Chole (chickpea curry)', caloriesPer100g: 145, proteinPer100g: 7.5, carbsPer100g: 22.0, fatPer100g: 4.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Aloo Gobi', caloriesPer100g: 110, proteinPer100g: 3.0, carbsPer100g: 16.0, fatPer100g: 4.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Bhindi (Okra sabzi)', caloriesPer100g: 80, proteinPer100g: 2.5, carbsPer100g: 9.0, fatPer100g: 4.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Curd / Dahi (full fat)', caloriesPer100g: 61, proteinPer100g: 3.5, carbsPer100g: 4.7, fatPer100g: 3.3, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Raita', caloriesPer100g: 50, proteinPer100g: 3.0, carbsPer100g: 4.5, fatPer100g: 2.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Lassi (sweet)', caloriesPer100g: 78, proteinPer100g: 3.5, carbsPer100g: 13.0, fatPer100g: 1.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Khichdi', caloriesPer100g: 130, proteinPer100g: 5.0, carbsPer100g: 22.0, fatPer100g: 3.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Pav Bhaji', caloriesPer100g: 220, proteinPer100g: 5.5, carbsPer100g: 32.0, fatPer100g: 8.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Vada Pav', caloriesPer100g: 280, proteinPer100g: 7.0, carbsPer100g: 42.0, fatPer100g: 9.5, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Samosa (1 piece ~60g)', caloriesPer100g: 260, proteinPer100g: 5.0, carbsPer100g: 33.0, fatPer100g: 13.0, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Moong Sprouts (raw)', caloriesPer100g: 30, proteinPer100g: 3.0, carbsPer100g: 5.5, fatPer100g: 0.2, isIndianFood: true, category: 'Indian'),
    FoodItem(name: 'Sattu (roasted gram flour)', caloriesPer100g: 406, proteinPer100g: 22.5, carbsPer100g: 65.0, fatPer100g: 6.0, isIndianFood: true, category: 'Indian'),

    // ── Proteins ──────────────────────────────────────────────────────────
    FoodItem(name: 'Chicken Breast (cooked)', caloriesPer100g: 165, proteinPer100g: 31.0, carbsPer100g: 0, fatPer100g: 3.6, category: 'Protein'),
    FoodItem(name: 'Eggs (whole, raw)', caloriesPer100g: 155, proteinPer100g: 13.0, carbsPer100g: 1.1, fatPer100g: 11.0, category: 'Protein'),
    FoodItem(name: 'Egg Whites', caloriesPer100g: 52, proteinPer100g: 11.0, carbsPer100g: 0.7, fatPer100g: 0.2, category: 'Protein'),
    FoodItem(name: 'Tuna (canned in water)', caloriesPer100g: 116, proteinPer100g: 26.0, carbsPer100g: 0, fatPer100g: 1.0, category: 'Protein'),
    FoodItem(name: 'Salmon (cooked)', caloriesPer100g: 208, proteinPer100g: 20.0, carbsPer100g: 0, fatPer100g: 13.0, category: 'Protein'),
    FoodItem(name: 'Whey Protein (1 scoop 30g)', caloriesPer100g: 380, proteinPer100g: 75.0, carbsPer100g: 10.0, fatPer100g: 5.0, category: 'Protein'),
    FoodItem(name: 'Greek Yogurt (0% fat)', caloriesPer100g: 59, proteinPer100g: 10.0, carbsPer100g: 3.6, fatPer100g: 0.4, category: 'Dairy'),
    FoodItem(name: 'Cottage Cheese', caloriesPer100g: 98, proteinPer100g: 11.1, carbsPer100g: 3.4, fatPer100g: 4.3, category: 'Dairy'),

    // ── Carbs ──────────────────────────────────────────────────────────────
    FoodItem(name: 'Oats (dry)', caloriesPer100g: 389, proteinPer100g: 17.0, carbsPer100g: 66.0, fatPer100g: 7.0, category: 'Carbs'),
    FoodItem(name: 'Whole Wheat Bread (1 slice 30g)', caloriesPer100g: 247, proteinPer100g: 9.4, carbsPer100g: 41.0, fatPer100g: 3.4, category: 'Carbs'),
    FoodItem(name: 'Sweet Potato (cooked)', caloriesPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20.0, fatPer100g: 0.1, category: 'Carbs'),
    FoodItem(name: 'Banana', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23.0, fatPer100g: 0.3, category: 'Fruit'),
    FoodItem(name: 'Apple', caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14.0, fatPer100g: 0.2, category: 'Fruit'),
    FoodItem(name: 'Quinoa (cooked)', caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 22.0, fatPer100g: 1.9, category: 'Carbs'),

    // ── Fats ───────────────────────────────────────────────────────────────
    FoodItem(name: 'Almonds', caloriesPer100g: 579, proteinPer100g: 21.2, carbsPer100g: 22.0, fatPer100g: 49.9, category: 'Nuts'),
    FoodItem(name: 'Peanut Butter', caloriesPer100g: 588, proteinPer100g: 25.0, carbsPer100g: 20.0, fatPer100g: 50.0, category: 'Nuts'),
    FoodItem(name: 'Avocado', caloriesPer100g: 160, proteinPer100g: 2.0, carbsPer100g: 9.0, fatPer100g: 15.0, category: 'Fat'),
    FoodItem(name: 'Ghee', caloriesPer100g: 900, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, isIndianFood: true, category: 'Fat'),

    // ── Vegetables ──────────────────────────────────────────────────────────
    FoodItem(name: 'Broccoli (cooked)', caloriesPer100g: 35, proteinPer100g: 2.4, carbsPer100g: 7.2, fatPer100g: 0.4, category: 'Vegetables'),
    FoodItem(name: 'Spinach (raw)', caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, category: 'Vegetables'),
    FoodItem(name: 'Mixed Vegetables (cooked)', caloriesPer100g: 65, proteinPer100g: 2.5, carbsPer100g: 13.0, fatPer100g: 0.5, category: 'Vegetables'),
  ];
}

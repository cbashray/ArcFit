/// A single food entry log for a user on a given date.
class FoodEntryEntity {
  final String id;
  final String userId;
  final DateTime date;
  final MealType mealType;
  final String foodName;

  /// Serving size in grams.
  final double servingGrams;

  // Macros per serving
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isIndianFood;

  const FoodEntryEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.servingGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.isIndianFood = false,
  });

  factory FoodEntryEntity.fromMap(Map<String, dynamic> map) {
    return FoodEntryEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      mealType: MealType.values.byName(map['meal_type'] as String),
      foodName: map['food_name'] as String,
      servingGrams: (map['serving_grams'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      proteinG: (map['protein_g'] as num).toDouble(),
      carbsG: (map['carbs_g'] as num).toDouble(),
      fatG: (map['fat_g'] as num).toDouble(),
      isIndianFood: map['is_indian_food'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'meal_type': mealType.name,
        'food_name': foodName,
        'serving_grams': servingGrams,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'is_indian_food': isIndianFood,
      };
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  String get emoji => switch (this) {
        MealType.breakfast => '🌅',
        MealType.lunch => '☀️',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };
}

/// Nutrition goals for the user.
class NutritionGoalEntity {
  final double dailyCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const NutritionGoalEntity({
    this.dailyCalories = 2000,
    this.proteinG = 150,
    this.carbsG = 200,
    this.fatG = 65,
  });

  factory NutritionGoalEntity.fromMap(Map<String, dynamic> map) {
    return NutritionGoalEntity(
      dailyCalories: (map['daily_calories'] as num).toDouble(),
      proteinG: (map['protein_g'] as num).toDouble(),
      carbsG: (map['carbs_g'] as num).toDouble(),
      fatG: (map['fat_g'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'daily_calories': dailyCalories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
      };
}

/// A food from the searchable database.
class FoodItem {
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final bool isIndianFood;
  final String category;

  const FoodItem({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.isIndianFood = false,
    this.category = 'General',
  });
}

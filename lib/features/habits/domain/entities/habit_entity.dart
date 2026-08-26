import 'package:equatable/equatable.dart';

/// Represents a habit defined by the user.
class HabitEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final int colorValue;
  final DateTime createdAt;
  final bool isArchived;

  const HabitEntity({
    required this.id,
    required this.name,
    this.description = '',
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.colorValue,
    required this.createdAt,
    this.isArchived = false,
  });

  HabitEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code_point': iconCodePoint,
      'icon_font_family': iconFontFamily,
      'icon_font_package': iconFontPackage,
      'color_value': colorValue,
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived,
    };
  }

  factory HabitEntity.fromMap(Map<String, dynamic> map) {
    return HabitEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      iconCodePoint: (map['icon_code_point'] as num).toInt(),
      iconFontFamily: map['icon_font_family'] as String?,
      iconFontPackage: map['icon_font_package'] as String?,
      colorValue: (map['color_value'] as num).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: map['is_archived'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconCodePoint,
        iconFontFamily,
        iconFontPackage,
        colorValue,
        createdAt,
        isArchived,
      ];
}

/// Represents a single completion entry for a habit on a specific calendar day.
class HabitCompletionEntity extends Equatable {
  final String id;
  final String habitId;
  final String dateKey; // Format: yyyy-MM-dd
  final DateTime completedAt;

  const HabitCompletionEntity({
    required this.id,
    required this.habitId,
    required this.dateKey,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date_key': dateKey,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory HabitCompletionEntity.fromMap(Map<String, dynamic> map) {
    return HabitCompletionEntity(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      dateKey: map['date_key'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, habitId, dateKey, completedAt];
}

/// Streak and aggregate statistics for a habit.
class HabitStreakEntity extends Equatable {
  final String habitId;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final bool isCompletedToday;

  const HabitStreakEntity({
    required this.habitId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.isCompletedToday,
  });

  factory HabitStreakEntity.empty(String habitId) {
    return HabitStreakEntity(
      habitId: habitId,
      currentStreak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      isCompletedToday: false,
    );
  }

  @override
  List<Object?> get props => [
        habitId,
        currentStreak,
        longestStreak,
        totalCompletions,
        isCompletedToday,
      ];
}

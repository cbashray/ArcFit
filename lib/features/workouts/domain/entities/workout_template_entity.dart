import 'package:equatable/equatable.dart';

enum TemplateCategory {
  push,
  pull,
  legs,
  upper,
  lower,
  fullBody,
  custom,
}

class TemplateExerciseEntity extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int defaultSets;
  final int defaultReps;
  final double? targetWeight;

  const TemplateExerciseEntity({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.targetWeight,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
        if (targetWeight != null) 'targetWeight': targetWeight,
      };

  factory TemplateExerciseEntity.fromJson(Map<String, dynamic> json) =>
      TemplateExerciseEntity(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        muscleGroup: json['muscleGroup'] as String? ?? 'General',
        defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
        defaultReps: (json['defaultReps'] as num?)?.toInt() ?? 10,
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [
        exerciseId,
        exerciseName,
        muscleGroup,
        defaultSets,
        defaultReps,
        targetWeight,
      ];
}

class WorkoutTemplateEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TemplateCategory category;
  final List<TemplateExerciseEntity> exercises;
  final bool isCustom;
  final DateTime createdAt;

  const WorkoutTemplateEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.exercises,
    this.isCustom = false,
    required this.createdAt,
  });

  int get totalSets =>
      exercises.fold<int>(0, (sum, ex) => sum + ex.defaultSets);

  WorkoutTemplateEntity copyWith({
    String? id,
    String? title,
    String? description,
    TemplateCategory? category,
    List<TemplateExerciseEntity>? exercises,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return WorkoutTemplateEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isCustom': isCustom,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkoutTemplateEntity.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: TemplateCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => TemplateCategory.custom,
        ),
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) =>
                    TemplateExerciseEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isCustom: json['isCustom'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        exercises,
        isCustom,
        createdAt,
      ];
}

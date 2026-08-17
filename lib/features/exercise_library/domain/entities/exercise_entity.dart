/// Exercise Entity for FitX
class ExerciseEntity {
  final String id;
  final String name;
  final String nameLocalization; // e.g., "Squat" / "स्क्वाट"
  final String muscleGroup;
  final String equipment; // e.g., "dumbbells", "barbell", "bodyweight"
  final String difficultyLevel; // beginner, intermediate, advanced
  final String description;
  final String formCue; // Key form tip
  final double defaultWeight; // in kg
  final int defaultSets;
  final int defaultReps;
  final String videoUrl; // Supabase storage URL for demo video
  final List<String> targetMuscles; // Secondary muscle groups
  final List<String>? alternativeExercises; // Substitutes

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.nameLocalization,
    required this.muscleGroup,
    required this.equipment,
    required this.difficultyLevel,
    required this.description,
    required this.formCue,
    required this.defaultWeight,
    required this.defaultSets,
    required this.defaultReps,
    required this.videoUrl,
    this.targetMuscles = const [],
    this.alternativeExercises,
  });

  factory ExerciseEntity.fromMap(Map<String, dynamic> map) {
    return ExerciseEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      nameLocalization:
          map['name_localization'] as String? ?? (map['name'] as String),
      muscleGroup: map['muscle_group'] as String,
      equipment: map['equipment'] as String,
      difficultyLevel: map['difficulty_level'] as String,
      description: map['description'] as String,
      formCue: map['form_cue'] as String,
      defaultWeight: (map['default_weight'] as num).toDouble(),
      defaultSets: map['default_sets'] as int? ?? 3,
      defaultReps: map['default_reps'] as int? ?? 10,
      videoUrl: map['video_url'] as String,
      targetMuscles: (map['target_muscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      alternativeExercises:
          (map['alternative_exercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_localization': nameLocalization,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'difficulty_level': difficultyLevel,
      'description': description,
      'form_cue': formCue,
      'default_weight': defaultWeight,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
      'video_url': videoUrl,
      'target_muscles': targetMuscles,
      'alternative_exercises': alternativeExercises,
    };
  }

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? nameLocalization,
    String? muscleGroup,
    String? equipment,
    String? difficultyLevel,
    String? description,
    String? formCue,
    double? defaultWeight,
    int? defaultSets,
    int? defaultReps,
    String? videoUrl,
    List<String>? targetMuscles,
    List<String>? alternativeExercises,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameLocalization: nameLocalization ?? this.nameLocalization,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      description: description ?? this.description,
      formCue: formCue ?? this.formCue,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      videoUrl: videoUrl ?? this.videoUrl,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      alternativeExercises: alternativeExercises ?? this.alternativeExercises,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
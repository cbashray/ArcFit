/// Workout Plan Entity for FitX AI Adaptive Workouts
class WorkoutPlanEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime generatedAt;
  final DateTime? validUntil;
  final List<WorkoutPlanExerciseEntity> exercises;
  final String? goals;
  final String? restrictions;
  final String? availableEquipment;
  final int estimatedDuration;
  final int? estimatedCalories;
  final double? targetWeight;
  final String? targetMuscleFocus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutPlanEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.generatedAt,
    this.validUntil,
    required this.exercises,
    this.goals,
    this.restrictions,
    this.availableEquipment,
    this.estimatedDuration = 60,
    this.estimatedCalories,
    this.targetWeight,
    this.targetMuscleFocus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutPlanEntity.fromMap(Map<String, dynamic> map) {
    final List<WorkoutPlanExerciseEntity> exList = [];
    if (map['exercises'] != null) {
      final exMapList = map['exercises'] as List<dynamic>;
      for (final exMap in exMapList) {
        exList.add(WorkoutPlanExerciseEntity.fromMap(exMap as Map<String, dynamic>));
      }
    }

    return WorkoutPlanEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      validUntil: map['valid_until'] != null
          ? DateTime.parse(map['valid_until'] as String)
          : null,
      exercises: exList,
      goals: map['goals'] as String?,
      restrictions: map['restrictions'] as String?,
      availableEquipment: map['available_equipment'] as String?,
      estimatedDuration: (map['estimated_duration'] as num).toInt(),
      estimatedCalories: (map['estimated_calories'] as num?)?.toInt(),
      targetWeight: (map['target_weight'] as num?)?.toDouble(),
      targetMuscleFocus: map['target_muscle_focus'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'generated_at': generatedAt.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'goals': goals,
      'restrictions': restrictions,
      'available_equipment': availableEquipment,
      'estimated_duration': estimatedDuration,
      'estimated_calories': estimatedCalories,
      'target_weight': targetWeight,
      'target_muscle_focus': targetMuscleFocus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkoutPlanEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? generatedAt,
    DateTime? validUntil,
    List<WorkoutPlanExerciseEntity>? exercises,
    String? goals,
    String? restrictions,
    String? availableEquipment,
    int? estimatedDuration,
    int? estimatedCalories,
    double? targetWeight,
    String? targetMuscleFocus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlanEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      generatedAt: generatedAt ?? this.generatedAt,
      validUntil: validUntil ?? this.validUntil,
      exercises: exercises ?? this.exercises,
      goals: goals ?? this.goals,
      restrictions: restrictions ?? this.restrictions,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      targetWeight: targetWeight ?? this.targetWeight,
      targetMuscleFocus: targetMuscleFocus ?? this.targetMuscleFocus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlanEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Individual exercise within a workout plan
class WorkoutPlanExerciseEntity {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String exerciseVideoUrl;
  final String muscleGroup;
  final String equipment;
  final int sets;
  final int reps;
  final double weight;
  final int duration; // in minutes
  final String? notes;
  final int? restTime; // in seconds between sets

  const WorkoutPlanExerciseEntity({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseVideoUrl,
    required this.muscleGroup,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.duration,
    this.notes,
    this.restTime,
  });

  factory WorkoutPlanExerciseEntity.fromMap(Map<String, dynamic> map) {
    return WorkoutPlanExerciseEntity(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      exerciseVideoUrl: map['exercise_video_url'] as String,
      muscleGroup: map['muscle_group'] as String,
      equipment: map['equipment'] as String,
      sets: map['sets'] as int? ?? 3,
      reps: map['reps'] as int? ?? 10,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      duration: map['duration'] as int? ?? 5,
      notes: map['notes'] as String?,
      restTime: map['rest_time'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_video_url': exerciseVideoUrl,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'notes': notes,
      'rest_time': restTime,
    };
  }

  WorkoutPlanExerciseEntity copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? exerciseVideoUrl,
    String? muscleGroup,
    String? equipment,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    String? notes,
    int? restTime,
  }) {
    return WorkoutPlanExerciseEntity(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseVideoUrl: exerciseVideoUrl ?? this.exerciseVideoUrl,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlanExerciseEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
/// Workout Entity for FitX
class WorkoutEntity {
  final String id;
  final String userId;
  final DateTime date;
  final String title;
  final String? notes;
  final List<WorkoutExerciseEntity> exercises;
  final int totalSets;
  final int totalReps;
  final double totalCaloriesBurned;
  final double durationMinutes;
  final String? weightUsed;
  final String? equipmentUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    this.notes,
    required this.exercises,
    this.totalSets = 0,
    this.totalReps = 0,
    this.totalCaloriesBurned = 0,
    this.durationMinutes = 0,
    this.weightUsed,
    this.equipmentUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total tonnage lifted in kg: weight * sets * reps across all exercises
  double get totalVolume => exercises.fold<double>(
        0, (sum, ex) => sum + ((ex.weight ?? 0) * ex.sets * ex.reps));

  factory WorkoutEntity.fromMap(Map<String, dynamic> map) {
    final List<WorkoutExerciseEntity> exList = [];
    if (map['exercises'] != null) {
      final exMapList = map['exercises'] as List<dynamic>;
      for (final exMap in exMapList) {
        exList.add(WorkoutExerciseEntity.fromMap(exMap as Map<String, dynamic>));
      }
    }

    return WorkoutEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      notes: map['notes'] as String?,
      exercises: exList,
      totalSets: (map['total_sets'] as num).toInt(),
      totalReps: (map['total_reps'] as num).toInt(),
      totalCaloriesBurned: (map['total_calories_burned'] as num).toDouble(),
      durationMinutes: (map['duration_minutes'] as num).toDouble(),
      weightUsed: map['weight_used'] as String?,
      equipmentUsed: map['equipment_used'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'title': title,
      'notes': notes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'total_sets': totalSets,
      'total_reps': totalReps,
      'total_calories_burned': totalCaloriesBurned,
      'duration_minutes': durationMinutes,
      'weight_used': weightUsed,
      'equipment_used': equipmentUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkoutEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? title,
    String? notes,
    List<WorkoutExerciseEntity>? exercises,
    int? totalSets,
    int? totalReps,
    double? totalCaloriesBurned,
    double? durationMinutes,
    String? weightUsed,
    String? equipmentUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalCaloriesBurned:
          totalCaloriesBurned ?? this.totalCaloriesBurned,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weightUsed: weightUsed ?? this.weightUsed,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Individual exercise within a workout
class WorkoutExerciseEntity {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String exerciseVideoUrl;
  final int sets;
  final int reps;
  final double? weight;
  final double? duration; // in seconds
  final double? rpe; // Rate of Perceived Exertion 1-10
  final String? notes;
  final DateTime performedAt;

  const WorkoutExerciseEntity({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseVideoUrl,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.rpe,
    this.notes,
    required this.performedAt,
  });

  factory WorkoutExerciseEntity.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseEntity(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      exerciseVideoUrl: map['exercise_video_url'] as String,
      sets: map['sets'] as int? ?? 1,
      reps: map['reps'] as int? ?? 10,
      weight: (map['weight'] as num?)?.toDouble(),
      duration: (map['duration'] as num?)?.toDouble(),
      rpe: (map['rpe'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      performedAt: DateTime.parse(map['performed_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_video_url': exerciseVideoUrl,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'rpe': rpe,
      'notes': notes,
      'performed_at': performedAt.toIso8601String(),
    };
  }

  WorkoutExerciseEntity copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? exerciseVideoUrl,
    int? sets,
    int? reps,
    double? weight,
    double? duration,
    double? rpe,
    String? notes,
    DateTime? performedAt,
  }) {
    return WorkoutExerciseEntity(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseVideoUrl: exerciseVideoUrl ?? this.exerciseVideoUrl,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      performedAt: performedAt ?? this.performedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutExerciseEntity && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
/// Personal Record entity — best performance for a given exercise.
class PersonalRecordEntity {
  final String exerciseId;
  final String exerciseName;

  /// Maximum weight lifted (kg) in a single set, or 0 if body-weight only.
  final double maxWeight;

  /// Reps performed at [maxWeight].
  final int repsAtMaxWeight;

  /// Epley one-rep max estimate: weight × (1 + reps/30).
  final double estimatedOneRepMax;

  final DateTime achievedAt;

  const PersonalRecordEntity({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeight,
    required this.repsAtMaxWeight,
    required this.estimatedOneRepMax,
    required this.achievedAt,
  });

  factory PersonalRecordEntity.fromMap(Map<String, dynamic> map) {
    return PersonalRecordEntity(
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      maxWeight: (map['max_weight'] as num).toDouble(),
      repsAtMaxWeight: (map['reps_at_max_weight'] as num).toInt(),
      estimatedOneRepMax: (map['estimated_one_rep_max'] as num).toDouble(),
      achievedAt: DateTime.parse(map['achieved_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'max_weight': maxWeight,
        'reps_at_max_weight': repsAtMaxWeight,
        'estimated_one_rep_max': estimatedOneRepMax,
        'achieved_at': achievedAt.toIso8601String(),
      };

  /// Epley formula: 1RM = weight × (1 + reps / 30)
  static double calculateOneRepMax(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return weight;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  PersonalRecordEntity copyWith({
    double? maxWeight,
    int? repsAtMaxWeight,
    double? estimatedOneRepMax,
    DateTime? achievedAt,
  }) {
    return PersonalRecordEntity(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      maxWeight: maxWeight ?? this.maxWeight,
      repsAtMaxWeight: repsAtMaxWeight ?? this.repsAtMaxWeight,
      estimatedOneRepMax: estimatedOneRepMax ?? this.estimatedOneRepMax,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordEntity && exerciseId == other.exerciseId;

  @override
  int get hashCode => exerciseId.hashCode;
}

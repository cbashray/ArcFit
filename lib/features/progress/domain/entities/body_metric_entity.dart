/// Body measurement record for a specific date.
class BodyMetricEntity {
  final String id;
  final String userId;
  final DateTime date;

  /// Body weight in kg.
  final double? weightKg;

  /// Body fat percentage (optional).
  final double? bodyFatPct;

  /// Measurements in cm.
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;

  final String? notes;

  const BodyMetricEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.weightKg,
    this.bodyFatPct,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.notes,
  });

  factory BodyMetricEntity.fromMap(Map<String, dynamic> map) {
    return BodyMetricEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      bodyFatPct: (map['body_fat_pct'] as num?)?.toDouble(),
      chestCm: (map['chest_cm'] as num?)?.toDouble(),
      waistCm: (map['waist_cm'] as num?)?.toDouble(),
      hipsCm: (map['hips_cm'] as num?)?.toDouble(),
      armCm: (map['arm_cm'] as num?)?.toDouble(),
      thighCm: (map['thigh_cm'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'weight_kg': weightKg,
        'body_fat_pct': bodyFatPct,
        'chest_cm': chestCm,
        'waist_cm': waistCm,
        'hips_cm': hipsCm,
        'arm_cm': armCm,
        'thigh_cm': thighCm,
        'notes': notes,
      };

  /// BMI from weight (if height was provided externally)
  double? bmi(double heightCm) {
    if (weightKg == null || heightCm <= 0) return null;
    final h = heightCm / 100;
    return weightKg! / (h * h);
  }
}

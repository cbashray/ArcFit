import 'package:equatable/equatable.dart';

class WaterLogEntity extends Equatable {
  final String id;
  final DateTime date;
  final int amountMl;
  final int targetMl;

  const WaterLogEntity({
    required this.id,
    required this.date,
    required this.amountMl,
    this.targetMl = 2500,
  });

  double get progress => (amountMl / targetMl).clamp(0.0, 1.0);
  int get remainingMl => (targetMl - amountMl).clamp(0, targetMl);
  bool get isGoalReached => amountMl >= targetMl;

  WaterLogEntity copyWith({
    String? id,
    DateTime? date,
    int? amountMl,
    int? targetMl,
  }) {
    return WaterLogEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      targetMl: targetMl ?? this.targetMl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amountMl': amountMl,
      'targetMl': targetMl,
    };
  }

  factory WaterLogEntity.fromJson(Map<String, dynamic> json) {
    return WaterLogEntity(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amountMl: (json['amountMl'] as num).toInt(),
      targetMl: (json['targetMl'] as num?)?.toInt() ?? 2500,
    );
  }

  @override
  List<Object?> get props => [id, date, amountMl, targetMl];
}

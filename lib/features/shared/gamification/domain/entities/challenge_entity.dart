import 'package:equatable/equatable.dart';

enum ChallengeType {
  workoutCount,
  volumeTonnage,
  waterIntake,
  streakDays,
  nutritionLogging,
}

class ChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeType type;
  final double targetValue;
  final double currentProgress;
  final String unit;
  final int xpReward;
  final String badgeRewardId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final bool isClaimed;

  const ChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.currentProgress,
    required this.unit,
    required this.xpReward,
    this.badgeRewardId = '',
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressRatio =>
      (currentProgress / targetValue).clamp(0.0, 1.0);

  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, 30);

  ChallengeEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    ChallengeType? type,
    double? targetValue,
    double? currentProgress,
    String? unit,
    int? xpReward,
    String? badgeRewardId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return ChallengeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      unit: unit ?? this.unit,
      xpReward: xpReward ?? this.xpReward,
      badgeRewardId: badgeRewardId ?? this.badgeRewardId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'type': type.name,
        'targetValue': targetValue,
        'currentProgress': currentProgress,
        'unit': unit,
        'xpReward': xpReward,
        'badgeRewardId': badgeRewardId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isCompleted': isCompleted,
        'isClaimed': isClaimed,
      };

  factory ChallengeEntity.fromJson(Map<String, dynamic> json) =>
      ChallengeEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String? ?? '🎯',
        type: ChallengeType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ChallengeType.workoutCount,
        ),
        targetValue: (json['targetValue'] as num).toDouble(),
        currentProgress: (json['currentProgress'] as num).toDouble(),
        unit: json['unit'] as String? ?? '',
        xpReward: (json['xpReward'] as num).toInt(),
        badgeRewardId: json['badgeRewardId'] as String? ?? '',
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        type,
        targetValue,
        currentProgress,
        unit,
        xpReward,
        badgeRewardId,
        startDate,
        endDate,
        isCompleted,
        isClaimed,
      ];
}

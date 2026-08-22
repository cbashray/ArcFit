import 'package:equatable/equatable.dart';

enum LeaderboardFilter {
  thisWeek,
  thisMonth,
  allTime,
}

enum LeaderboardCategory {
  xp,
  volume,
  workouts,
  streak,
}

class LeaderboardUserEntity extends Equatable {
  final String userId;
  final String name;
  final String avatarEmoji;
  final int rank;
  final int xp;
  final double totalVolumeKg;
  final int totalWorkouts;
  final int currentStreak;
  final bool isCurrentUser;

  const LeaderboardUserEntity({
    required this.userId,
    required this.name,
    required this.avatarEmoji,
    required this.rank,
    required this.xp,
    required this.totalVolumeKg,
    required this.totalWorkouts,
    required this.currentStreak,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatarEmoji': avatarEmoji,
        'rank': rank,
        'xp': xp,
        'totalVolumeKg': totalVolumeKg,
        'totalWorkouts': totalWorkouts,
        'currentStreak': currentStreak,
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardUserEntity.fromJson(Map<String, dynamic> json) =>
      LeaderboardUserEntity(
        userId: json['userId'] as String,
        name: json['name'] as String,
        avatarEmoji: json['avatarEmoji'] as String? ?? '👤',
        rank: (json['rank'] as num).toInt(),
        xp: (json['xp'] as num).toInt(),
        totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
        totalWorkouts: (json['totalWorkouts'] as num).toInt(),
        currentStreak: (json['currentStreak'] as num).toInt(),
        isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        userId,
        name,
        avatarEmoji,
        rank,
        xp,
        totalVolumeKg,
        totalWorkouts,
        currentStreak,
        isCurrentUser,
      ];
}

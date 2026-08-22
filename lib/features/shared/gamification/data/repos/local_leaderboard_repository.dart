import '../../domain/entities/leaderboard_entity.dart';

class LocalLeaderboardRepository {
  Future<List<LeaderboardUserEntity>> getLeaderboard({
    LeaderboardFilter filter = LeaderboardFilter.thisWeek,
    LeaderboardCategory category = LeaderboardCategory.xp,
    int userWorkouts = 1,
    double userVolume = 2200.0,
    int userStreak = 1,
    String userName = 'Demo',
  }) async {
    // Generate realistic seeded community entries
    final multiplier = switch (filter) {
      LeaderboardFilter.thisWeek => 1.0,
      LeaderboardFilter.thisMonth => 4.2,
      LeaderboardFilter.allTime => 18.5,
    };

    final userXp = (userWorkouts * 150 * multiplier).toInt() + (userStreak * 50);

    final rawList = <LeaderboardUserEntity>[
      LeaderboardUserEntity(
        userId: 'u_1',
        name: 'Alex Vance',
        avatarEmoji: '⚡',
        rank: 1,
        xp: (1450 * multiplier).toInt(),
        totalVolumeKg: 18500 * multiplier,
        totalWorkouts: (6 * multiplier).toInt(),
        currentStreak: 12,
      ),
      LeaderboardUserEntity(
        userId: 'u_2',
        name: 'Sara Connor',
        avatarEmoji: '🔥',
        rank: 2,
        xp: (1280 * multiplier).toInt(),
        totalVolumeKg: 15200 * multiplier,
        totalWorkouts: (5 * multiplier).toInt(),
        currentStreak: 9,
      ),
      LeaderboardUserEntity(
        userId: 'u_3',
        name: 'Vikram Mehta',
        avatarEmoji: '🦁',
        rank: 3,
        xp: (1120 * multiplier).toInt(),
        totalVolumeKg: 13900 * multiplier,
        totalWorkouts: (5 * multiplier).toInt(),
        currentStreak: 7,
      ),
      LeaderboardUserEntity(
        userId: 'u_current',
        name: '$userName (You)',
        avatarEmoji: '💪',
        rank: 4,
        xp: userXp,
        totalVolumeKg: userVolume * multiplier,
        totalWorkouts: (userWorkouts * multiplier).toInt(),
        currentStreak: userStreak,
        isCurrentUser: true,
      ),
      LeaderboardUserEntity(
        userId: 'u_4',
        name: 'Elena Rostova',
        avatarEmoji: '👑',
        rank: 5,
        xp: (920 * multiplier).toInt(),
        totalVolumeKg: 11400 * multiplier,
        totalWorkouts: (4 * multiplier).toInt(),
        currentStreak: 5,
      ),
      LeaderboardUserEntity(
        userId: 'u_5',
        name: 'Marcus Brody',
        avatarEmoji: '🏋️',
        rank: 6,
        xp: (780 * multiplier).toInt(),
        totalVolumeKg: 9500 * multiplier,
        totalWorkouts: (3 * multiplier).toInt(),
        currentStreak: 3,
      ),
      LeaderboardUserEntity(
        userId: 'u_6',
        name: 'Priya Sharma',
        avatarEmoji: '🌸',
        rank: 7,
        xp: (640 * multiplier).toInt(),
        totalVolumeKg: 7800 * multiplier,
        totalWorkouts: (3 * multiplier).toInt(),
        currentStreak: 2,
      ),
    ];

    // Sort depending on category
    switch (category) {
      case LeaderboardCategory.xp:
        rawList.sort((a, b) => b.xp.compareTo(a.xp));
      case LeaderboardCategory.volume:
        rawList.sort((a, b) => b.totalVolumeKg.compareTo(a.totalVolumeKg));
      case LeaderboardCategory.workouts:
        rawList.sort((a, b) => b.totalWorkouts.compareTo(a.totalWorkouts));
      case LeaderboardCategory.streak:
        rawList.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    }

    // Re-assign ranks 1..N
    return [
      for (int i = 0; i < rawList.length; i++)
        LeaderboardUserEntity(
          userId: rawList[i].userId,
          name: rawList[i].name,
          avatarEmoji: rawList[i].avatarEmoji,
          rank: i + 1,
          xp: rawList[i].xp,
          totalVolumeKg: rawList[i].totalVolumeKg,
          totalWorkouts: rawList[i].totalWorkouts,
          currentStreak: rawList[i].currentStreak,
          isCurrentUser: rawList[i].isCurrentUser,
        ),
    ];
  }
}

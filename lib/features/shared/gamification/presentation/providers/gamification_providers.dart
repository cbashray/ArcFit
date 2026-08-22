import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/app_providers.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../home/presentation/screens/home_screen.dart';
import '../../../../workouts/presentation/providers/workout_providers.dart';
import '../../data/repos/local_challenge_repository.dart';
import '../../data/repos/local_leaderboard_repository.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';

final challengeRepositoryProvider = Provider<LocalChallengeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalChallengeRepository(prefs);
});

final leaderboardRepositoryProvider =
    Provider<LocalLeaderboardRepository>((ref) {
  return LocalLeaderboardRepository();
});

class ChallengesNotifier extends AsyncNotifier<List<ChallengeEntity>> {
  @override
  Future<List<ChallengeEntity>> build() async {
    final repo = ref.watch(challengeRepositoryProvider);
    return repo.getChallenges();
  }

  Future<void> updateProgress(ChallengeType type, double increment) async {
    final repo = ref.read(challengeRepositoryProvider);
    await repo.updateProgress(type, increment);
    ref.invalidateSelf();
  }

  Future<void> claimReward(String challengeId) async {
    final repo = ref.read(challengeRepositoryProvider);
    await repo.claimReward(challengeId);
    ref.invalidateSelf();
  }
}

final challengesProvider =
    AsyncNotifierProvider<ChallengesNotifier, List<ChallengeEntity>>(
  ChallengesNotifier.new,
);

final leaderboardFilterProvider =
    StateProvider<LeaderboardFilter>((ref) => LeaderboardFilter.thisWeek);

final leaderboardCategoryProvider =
    StateProvider<LeaderboardCategory>((ref) => LeaderboardCategory.xp);

final leaderboardProvider =
    FutureProvider<List<LeaderboardUserEntity>>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final filter = ref.watch(leaderboardFilterProvider);
  final category = ref.watch(leaderboardCategoryProvider);
  final workouts = await ref.watch(workoutsProvider.future);
  final streak = await ref.watch(streakProvider.future);
  final user = ref.watch(authNotifierProvider).valueOrNull?.user;

  final totalVol = workouts.fold<double>(0, (sum, w) => sum + w.totalVolume);

  return repo.getLeaderboard(
    filter: filter,
    category: category,
    userWorkouts: workouts.length,
    userVolume: totalVol,
    userStreak: streak,
    userName: user?.name.isNotEmpty == true ? user!.name : 'Demo',
  );
});

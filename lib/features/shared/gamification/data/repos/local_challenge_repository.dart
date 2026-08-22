import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/challenge_entity.dart';

class LocalChallengeRepository {
  final SharedPreferences _prefs;
  static const String _challengesKey = 'fitx_gamification_challenges';

  LocalChallengeRepository(this._prefs);

  Future<List<ChallengeEntity>> getChallenges() async {
    await seedDefaultChallengesIfEmpty();
    final rawList = _prefs.getStringList(_challengesKey) ?? [];
    return rawList
        .map((e) =>
            ChallengeEntity.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateProgress(ChallengeType type, double increment) async {
    final challenges = await getChallenges();
    var changed = false;

    for (int i = 0; i < challenges.length; i++) {
      final ch = challenges[i];
      if (ch.type == type && !ch.isCompleted) {
        final newProg = (ch.currentProgress + increment).clamp(0.0, ch.targetValue);
        final completed = newProg >= ch.targetValue;
        challenges[i] = ch.copyWith(
          currentProgress: newProg,
          isCompleted: completed,
        );
        changed = true;
      }
    }

    if (changed) {
      final rawList = challenges.map((c) => jsonEncode(c.toJson())).toList();
      await _prefs.setStringList(_challengesKey, rawList);
    }
  }

  Future<void> claimReward(String challengeId) async {
    final challenges = await getChallenges();
    final idx = challenges.indexWhere((c) => c.id == challengeId);
    if (idx >= 0 && challenges[idx].isCompleted) {
      challenges[idx] = challenges[idx].copyWith(isClaimed: true);
      final rawList = challenges.map((c) => jsonEncode(c.toJson())).toList();
      await _prefs.setStringList(_challengesKey, rawList);
    }
  }

  Future<void> seedDefaultChallengesIfEmpty() async {
    final rawList = _prefs.getStringList(_challengesKey);
    if (rawList != null && rawList.isNotEmpty) return;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final defaults = <ChallengeEntity>[
      ChallengeEntity(
        id: 'challenge_workout_4',
        title: 'Consistency Crusher',
        description: 'Complete 4 workouts this week to build unstoppable momentum.',
        icon: '🏋️',
        type: ChallengeType.workoutCount,
        targetValue: 4,
        currentProgress: 1,
        unit: 'workouts',
        xpReward: 250,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      ChallengeEntity(
        id: 'challenge_volume_10k',
        title: 'Tonnage Titan',
        description: 'Lift a total of 10,000 kg across all your compound movements.',
        icon: '⚡',
        type: ChallengeType.volumeTonnage,
        targetValue: 10000,
        currentProgress: 2200,
        unit: 'kg',
        xpReward: 350,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      ChallengeEntity(
        id: 'challenge_water_5d',
        title: 'Hydro Champion',
        description: 'Hit your daily water goal (2.5L+) on 5 separate days this week.',
        icon: '💧',
        type: ChallengeType.waterIntake,
        targetValue: 5,
        currentProgress: 2,
        unit: 'days',
        xpReward: 150,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      ChallengeEntity(
        id: 'challenge_nutrition_log',
        title: 'Master of Macros',
        description: 'Log your meals for 5 days to dial in your nutrition.',
        icon: '🥗',
        type: ChallengeType.nutritionLogging,
        targetValue: 5,
        currentProgress: 1,
        unit: 'days',
        xpReward: 200,
        startDate: weekStart,
        endDate: weekEnd,
      ),
    ];

    final raw = defaults.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_challengesKey, raw);
  }
}

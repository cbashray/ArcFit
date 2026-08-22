import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/app_providers.dart';

// ─── Badge Entity ─────────────────────────────────────────────────────────────

class BadgeEntity {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.unlockedAt,
  });

  BadgeEntity unlock() => BadgeEntity(
        id: id,
        name: name,
        description: description,
        emoji: emoji,
        unlockedAt: DateTime.now(),
      );

  factory BadgeEntity.fromMap(Map<String, dynamic> map) {
    return BadgeEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };
}

// ─── All badge definitions ────────────────────────────────────────────────────

final allBadgeDefinitions = [
  const BadgeEntity(id: 'first_workout', name: 'First Step', description: 'Completed your first workout', emoji: '🏃'),
  const BadgeEntity(id: 'streak_3', name: '3-Day Streak', description: 'Worked out 3 days in a row', emoji: '🔥'),
  const BadgeEntity(id: 'streak_7', name: 'Week Warrior', description: 'Worked out 7 days in a row', emoji: '⚡'),
  const BadgeEntity(id: 'streak_30', name: 'Monthly Champion', description: 'Worked out 30 days in a row', emoji: '👑'),
  const BadgeEntity(id: 'workouts_10', name: 'Getting Consistent', description: 'Completed 10 workouts', emoji: '💪'),
  const BadgeEntity(id: 'workouts_50', name: 'Halfway to Legend', description: 'Completed 50 workouts', emoji: '🏋️'),
  const BadgeEntity(id: 'workouts_100', name: 'Legend', description: 'Completed 100 workouts', emoji: '🦁'),
  const BadgeEntity(id: 'sets_100', name: 'Set Slayer', description: 'Logged 100 total sets', emoji: '📊'),
  const BadgeEntity(id: 'sets_1000', name: 'Iron Addict', description: 'Logged 1000 total sets', emoji: '🤖'),
  const BadgeEntity(id: 'pr_first', name: 'PR Breaker', description: 'Set your first personal record', emoji: '🏆'),
  const BadgeEntity(id: 'pr_10', name: 'Record Collector', description: 'Set 10 personal records', emoji: '🥇'),
  const BadgeEntity(id: 'variety', name: 'Variety Is Key', description: 'Used 10 different exercises', emoji: '🎯'),
  const BadgeEntity(id: 'early_bird', name: 'Early Bird', description: 'Logged a workout before 7 AM', emoji: '🌅'),
  const BadgeEntity(id: 'night_owl', name: 'Night Owl', description: 'Logged a workout after 9 PM', emoji: '🦉'),
];

// ─── Repository ───────────────────────────────────────────────────────────────

final gamificationRepositoryProvider =
    Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(sharedPreferencesProvider));
});

class GamificationRepository {
  static const _key = 'fitx_badges';
  final SharedPreferences _prefs;

  GamificationRepository(this._prefs);

  Map<String, BadgeEntity> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (id, value) => MapEntry(
          id, BadgeEntity.fromMap(Map<String, dynamic>.from(value as Map))),
    );
  }

  Future<void> _write(Map<String, BadgeEntity> badges) async {
    await _prefs.setString(
        _key, jsonEncode(badges.map((k, v) => MapEntry(k, v.toMap()))));
  }

  List<BadgeEntity> getAllBadges() {
    final unlocked = _read();
    return allBadgeDefinitions
        .map((b) => unlocked.containsKey(b.id) ? unlocked[b.id]! : b)
        .toList();
  }

  /// Check conditions and unlock any new badges. Returns newly unlocked badges.
  Future<List<BadgeEntity>> checkAndUnlock({
    required int totalWorkouts,
    required int currentStreak,
    required int totalSets,
    required int totalPRs,
    required List<String> exerciseNames,
    required DateTime? latestWorkoutTime,
  }) async {
    final badges = _read();
    final newlyUnlocked = <BadgeEntity>[];

    void tryUnlock(String id, bool condition) {
      if (condition && !badges.containsKey(id)) {
        final badge =
            allBadgeDefinitions.firstWhere((b) => b.id == id);
        badges[id] = badge.unlock();
        newlyUnlocked.add(badges[id]!);
      }
    }

    tryUnlock('first_workout', totalWorkouts >= 1);
    tryUnlock('streak_3', currentStreak >= 3);
    tryUnlock('streak_7', currentStreak >= 7);
    tryUnlock('streak_30', currentStreak >= 30);
    tryUnlock('workouts_10', totalWorkouts >= 10);
    tryUnlock('workouts_50', totalWorkouts >= 50);
    tryUnlock('workouts_100', totalWorkouts >= 100);
    tryUnlock('sets_100', totalSets >= 100);
    tryUnlock('sets_1000', totalSets >= 1000);
    tryUnlock('pr_first', totalPRs >= 1);
    tryUnlock('pr_10', totalPRs >= 10);
    tryUnlock('variety', exerciseNames.toSet().length >= 10);
    if (latestWorkoutTime != null) {
      tryUnlock('early_bird', latestWorkoutTime.hour < 7);
      tryUnlock('night_owl', latestWorkoutTime.hour >= 21);
    }

    if (newlyUnlocked.isNotEmpty) await _write(badges);
    return newlyUnlocked;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final badgesProvider =
    NotifierProvider<BadgesNotifier, List<BadgeEntity>>(BadgesNotifier.new);

class BadgesNotifier extends Notifier<List<BadgeEntity>> {
  @override
  List<BadgeEntity> build() =>
      ref.watch(gamificationRepositoryProvider).getAllBadges();

  void refresh() =>
      state = ref.read(gamificationRepositoryProvider).getAllBadges();
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/app_providers.dart';
import '../../workouts/domain/entities/workout_entity.dart';

// ─── Badge Entity ─────────────────────────────────────────────────────────────

class BadgeEntity {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String category;
  final double targetValue;
  final String unit;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.category = 'General',
    this.targetValue = 1,
    this.unit = '',
    this.unlockedAt,
  });

  BadgeEntity unlock() => BadgeEntity(
        id: id,
        name: name,
        description: description,
        emoji: emoji,
        category: category,
        targetValue: targetValue,
        unit: unit,
        unlockedAt: DateTime.now(),
      );

  factory BadgeEntity.fromMap(Map<String, dynamic> map) {
    return BadgeEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      category: map['category'] as String? ?? 'General',
      targetValue: (map['target_value'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? '',
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
        'category': category,
        'target_value': targetValue,
        'unit': unit,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };
}

// ─── All badge definitions ────────────────────────────────────────────────────

final allBadgeDefinitions = [
  const BadgeEntity(
    id: 'first_workout',
    name: 'First Step',
    description: 'Complete your first workout',
    emoji: '🏃',
    category: 'Workouts',
    targetValue: 1,
    unit: 'workout',
  ),
  const BadgeEntity(
    id: 'streak_3',
    name: '3-Day Streak',
    description: 'Work out 3 days in a row',
    emoji: '🔥',
    category: 'Streaks',
    targetValue: 3,
    unit: 'days',
  ),
  const BadgeEntity(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Work out 7 days in a row',
    emoji: '⚡',
    category: 'Streaks',
    targetValue: 7,
    unit: 'days',
  ),
  const BadgeEntity(
    id: 'streak_30',
    name: 'Monthly Champion',
    description: 'Work out 30 days in a row',
    emoji: '👑',
    category: 'Streaks',
    targetValue: 30,
    unit: 'days',
  ),
  const BadgeEntity(
    id: 'workouts_10',
    name: 'Getting Consistent',
    description: 'Complete 10 workouts',
    emoji: '💪',
    category: 'Workouts',
    targetValue: 10,
    unit: 'workouts',
  ),
  const BadgeEntity(
    id: 'workouts_50',
    name: 'Halfway to Legend',
    description: 'Complete 50 workouts',
    emoji: '🏋️',
    category: 'Workouts',
    targetValue: 50,
    unit: 'workouts',
  ),
  const BadgeEntity(
    id: 'workouts_100',
    name: 'Legend',
    description: 'Complete 100 workouts',
    emoji: '🦁',
    category: 'Workouts',
    targetValue: 100,
    unit: 'workouts',
  ),
  const BadgeEntity(
    id: 'sets_100',
    name: 'Set Slayer',
    description: 'Log 100 total sets',
    emoji: '📊',
    category: 'Volume',
    targetValue: 100,
    unit: 'sets',
  ),
  const BadgeEntity(
    id: 'sets_1000',
    name: 'Iron Addict',
    description: 'Log 1000 total sets',
    emoji: '🤖',
    category: 'Volume',
    targetValue: 1000,
    unit: 'sets',
  ),
  const BadgeEntity(
    id: 'pr_first',
    name: 'PR Breaker',
    description: 'Set your first personal record',
    emoji: '🏆',
    category: 'Records',
    targetValue: 1,
    unit: 'PR',
  ),
  const BadgeEntity(
    id: 'pr_10',
    name: 'Record Collector',
    description: 'Set 10 personal records',
    emoji: '🥇',
    category: 'Records',
    targetValue: 10,
    unit: 'PRs',
  ),
  const BadgeEntity(
    id: 'variety',
    name: 'Variety Is Key',
    description: 'Perform 10 different exercises',
    emoji: '🎯',
    category: 'Variety',
    targetValue: 10,
    unit: 'exercises',
  ),
  const BadgeEntity(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Log a workout before 7:00 AM',
    emoji: '🌅',
    category: 'Special',
    targetValue: 1,
    unit: 'session',
  ),
  const BadgeEntity(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Log a workout after 9:00 PM',
    emoji: '🦉',
    category: 'Special',
    targetValue: 1,
    unit: 'session',
  ),
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
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (id, value) => MapEntry(
            id, BadgeEntity.fromMap(Map<String, dynamic>.from(value as Map))),
      );
    } catch (_) {
      return {};
    }
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

  /// Evaluates workout history and unlocks eligible badges.
  Future<List<BadgeEntity>> evaluateAndUnlock({
    required List<WorkoutEntity> workouts,
    required int currentStreak,
    required int totalPRs,
  }) async {
    final badges = _read();
    final newlyUnlocked = <BadgeEntity>[];

    final totalWorkouts = workouts.length;
    final totalSets = workouts.fold<int>(0, (sum, w) => sum + w.totalSets);
    final uniqueExercises = workouts
        .expand((w) => w.exercises.map((e) => e.exerciseName.trim().toLowerCase()))
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;
    final hasEarlyBird = workouts.any((w) => w.date.hour < 7);
    final hasNightOwl = workouts.any((w) => w.date.hour >= 21);

    void tryUnlock(String id, bool condition) {
      if (condition && !badges.containsKey(id)) {
        final def = allBadgeDefinitions.firstWhere((b) => b.id == id,
            orElse: () => BadgeEntity(
                  id: id,
                  name: id,
                  description: '',
                  emoji: '🏅',
                ));
        final unlocked = def.unlock();
        badges[id] = unlocked;
        newlyUnlocked.add(unlocked);
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
    tryUnlock('variety', uniqueExercises >= 10);
    tryUnlock('early_bird', hasEarlyBird);
    tryUnlock('night_owl', hasNightOwl);

    if (newlyUnlocked.isNotEmpty) {
      await _write(badges);
    }
    return newlyUnlocked;
  }

  /// Manually claim an unlocked badge
  Future<BadgeEntity?> claimBadge(String badgeId) async {
    final badges = _read();
    if (!badges.containsKey(badgeId)) {
      final def = allBadgeDefinitions.firstWhere((b) => b.id == badgeId,
          orElse: () => BadgeEntity(
                id: badgeId,
                name: badgeId,
                description: '',
                emoji: '🏅',
              ));
      final unlocked = def.unlock();
      badges[badgeId] = unlocked;
      await _write(badges);
      return unlocked;
    }
    return badges[badgeId];
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final badgesProvider =
    NotifierProvider<BadgesNotifier, List<BadgeEntity>>(BadgesNotifier.new);

class BadgesNotifier extends Notifier<List<BadgeEntity>> {
  @override
  List<BadgeEntity> build() =>
      ref.watch(gamificationRepositoryProvider).getAllBadges();

  void refresh() {
    state = ref.read(gamificationRepositoryProvider).getAllBadges();
  }

  Future<List<BadgeEntity>> checkAndSync({
    required List<WorkoutEntity> workouts,
    required int streak,
    required int prsCount,
  }) async {
    final repo = ref.read(gamificationRepositoryProvider);
    final newlyUnlocked = await repo.evaluateAndUnlock(
      workouts: workouts,
      currentStreak: streak,
      totalPRs: prsCount,
    );
    state = repo.getAllBadges();
    return newlyUnlocked;
  }

  Future<void> claim(String badgeId) async {
    final repo = ref.read(gamificationRepositoryProvider);
    await repo.claimBadge(badgeId);
    state = repo.getAllBadges();
  }
}

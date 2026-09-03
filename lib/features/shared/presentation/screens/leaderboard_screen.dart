import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../gamification/domain/entities/leaderboard_entity.dart';
import '../../gamification/presentation/providers/gamification_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentCategory = ref.watch(leaderboardCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Leaderboard 🏆'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ── Achievements & Records Hub (Shifted from Dashboard) ──
          const _GamificationHubRow(),
          const SizedBox(height: 20),

          // ── Weekly Competition Header ────────────────────────────
          Row(
            children: [
              const Text(
                'Weekly Standings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppTheme.primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: '⚡ XP Score',
                  selected: currentCategory == LeaderboardCategory.xp,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.xp,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: '🏋️ Volume (kg)',
                  selected: currentCategory == LeaderboardCategory.volume,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.volume,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: '📅 Workouts',
                  selected: currentCategory == LeaderboardCategory.workouts,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.workouts,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: '🔥 Streak Days',
                  selected: currentCategory == LeaderboardCategory.streak,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.streak,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Leaderboard Podium & Rankings
          leaderboardAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Error: $err')),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No entries found.')),
                );
              }

              final top3 = users.take(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Podium
                  if (top3.length >= 3) _PodiumView(top3: top3),
                  const SizedBox(height: 18),

                  // Rest of Leaderboard
                  const Text(
                    'Rankings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...users.map((u) => _UserRankTile(
                        user: u,
                        category: currentCategory,
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Achievements & Gamification Hub (My PRs, Challenges, Badges)
// ─────────────────────────────────────────────────────────────────────────────

class _GamificationHubRow extends StatelessWidget {
  const _GamificationHubRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HubCard(
            icon: Icons.emoji_events_rounded,
            title: 'My PRs',
            subtitle: 'Records',
            color: AppTheme.accentOrange,
            onTap: () => context.pushNamed('personalRecords'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HubCard(
            icon: Icons.flag_rounded,
            title: 'Challenges',
            subtitle: 'Missions',
            color: Colors.deepOrange,
            onTap: () => context.pushNamed('challenges'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HubCard(
            icon: Icons.military_tech_rounded,
            title: 'Badges',
            subtitle: 'Milestones',
            color: AppTheme.primaryGreen,
            onTap: () => context.pushNamed('badges'),
          ),
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Podium View (Top 3)
// ─────────────────────────────────────────────────────────────────────────────

class _PodiumView extends StatelessWidget {
  final List<LeaderboardUserEntity> top3;

  const _PodiumView({required this.top3});

  @override
  Widget build(BuildContext context) {
    // top3[0] = 1st, top3[1] = 2nd, top3[2] = 3rd
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          _PodiumColumn(
            user: second,
            height: 90,
            rankColor: const Color(0xFFC0C0C0),
            rankBadge: '🥈 2nd',
          ),
          // 1st Place (Gold)
          _PodiumColumn(
            user: first,
            height: 120,
            rankColor: const Color(0xFFFFD700),
            rankBadge: '👑 1st',
            isCenter: true,
          ),
          // 3rd Place (Bronze)
          _PodiumColumn(
            user: third,
            height: 75,
            rankColor: const Color(0xFFCD7F32),
            rankBadge: '🥉 3rd',
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final LeaderboardUserEntity user;
  final double height;
  final Color rankColor;
  final String rankBadge;
  final bool isCenter;

  const _PodiumColumn({
    required this.user,
    required this.height,
    required this.rankColor,
    required this.rankBadge,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar + Emoji
        Container(
          width: isCenter ? 54 : 44,
          height: isCenter ? 54 : 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 2.5),
            color: rankColor.withValues(alpha: 0.2),
          ),
          child: Text(
            user.avatarEmoji,
            style: TextStyle(fontSize: isCenter ? 24 : 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.name.split(' ').first,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isCenter ? 13 : 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // Podium Block
        Container(
          width: 76,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: rankColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            rankBadge,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: rankColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Rank Tile
// ─────────────────────────────────────────────────────────────────────────────

class _UserRankTile extends StatelessWidget {
  final LeaderboardUserEntity user;
  final LeaderboardCategory category;

  const _UserRankTile({
    required this.user,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String metricValue;
    switch (category) {
      case LeaderboardCategory.xp:
        metricValue = '${user.xp} XP';
      case LeaderboardCategory.volume:
        metricValue = '${(user.totalVolumeKg / 1000).toStringAsFixed(1)}k kg';
      case LeaderboardCategory.workouts:
        metricValue = '${user.totalWorkouts} workouts';
      case LeaderboardCategory.streak:
        metricValue = '${user.currentStreak} days 🔥';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? AppTheme.primaryGreen.withValues(alpha: 0.12)
            : (isDark ? const Color(0xFF222222) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isCurrentUser
              ? AppTheme.primaryGreen
              : (isDark ? const Color(0xFF333333) : Colors.grey.shade200),
          width: user.isCurrentUser ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 28,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: user.rank <= 3
                    ? AppTheme.accentOrange
                    : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Avatar
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: user.isCurrentUser
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 13,
                          color: user.isCurrentUser
                              ? AppTheme.primaryGreen
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${user.totalWorkouts} workouts · ${user.currentStreak}d streak',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Metric
          Text(
            metricValue,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

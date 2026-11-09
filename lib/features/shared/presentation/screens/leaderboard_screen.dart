import 'package:flutter/material.dart' hide ActionChip, Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart'
    show AppTheme;
import '../../gamification/domain/entities/leaderboard_entity.dart'
    show LeaderboardUserEntity, LeaderboardCategory;
import '../../gamification/presentation/providers/gamification_providers.dart'
    show leaderboardProvider, leaderboardCategoryProvider;
import '../../../../features/shared/presentation/widgets/ui_components_export.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentCategory = ref.watch(leaderboardCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        toolbarHeight: 56,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space6),
        children: [
          // ── Achievements & Gamification Hub ──
          SectionHeader(title: 'Achievements'),
          const SizedBox(height: AppTheme.space3),
          const _GamificationHubRow(),
          const SizedBox(height: AppTheme.space6),

          // ── Weekly Competition Header ────────────────────────────
          Row(
            children: [
              Text(
                'Weekly Standings',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'This Week',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: 'XP Score',
                  icon: Icons.bolt_rounded,
                  selected: currentCategory == LeaderboardCategory.xp,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.xp,
                ),
                const SizedBox(width: AppTheme.space2),
                _CategoryChip(
                  label: 'Volume (kg)',
                  icon: Icons.fitness_center_rounded,
                  selected: currentCategory == LeaderboardCategory.volume,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.volume,
                ),
                const SizedBox(width: AppTheme.space2),
                _CategoryChip(
                  label: 'Workouts',
                  icon: Icons.directions_run_rounded,
                  selected: currentCategory == LeaderboardCategory.workouts,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.workouts,
                ),
                const SizedBox(width: AppTheme.space2),
                _CategoryChip(
                  label: 'Streak Days',
                  icon: Icons.local_fire_department_rounded,
                  selected: currentCategory == LeaderboardCategory.streak,
                  onTap: () => ref
                      .read(leaderboardCategoryProvider.notifier)
                      .state = LeaderboardCategory.streak,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space4),

          // Time period toggle
          Row(
            children: [
              _PeriodChip(
                label: 'Weekly',
                selected: true,
                onTap: () {},
              ),
              const SizedBox(width: AppTheme.space2),
              _PeriodChip(
                label: 'Monthly',
                selected: false,
                onTap: () {},
              ),
              const SizedBox(width: AppTheme.space2),
              _PeriodChip(
                label: 'All Time',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),

          // Leaderboard Podium & Rankings
          leaderboardAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
              child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
              child: Center(child: Text('Error: $err', style: GoogleFonts.ibmPlexSans(color: theme.colorScheme.error))),
            ),
            data: (users) {
              if (users.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
                  child: Center(child: EmptyState(icon: Icons.people_outline, title: 'No entries found', message: 'Be the first to compete!')),
                );
              }

              final top3 = users.take(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Podium
                  if (top3.length >= 3) _PodiumView(top3: top3),
                  const SizedBox(height: AppTheme.space5),

                  // Rest of Leaderboard
                  SectionHeader(title: 'Rankings'),
                  const SizedBox(height: AppTheme.space3),
                  ...users.map((u) => _UserRankTile(
                        user: u,
                        category: currentCategory,
                      )),

                  const SizedBox(height: AppTheme.space6),

                  // Weekly Challenges
                  SectionHeader(title: 'Weekly Challenges'),
                  const SizedBox(height: AppTheme.space3),
                  const _WeeklyChallengesSection(),
                  const SizedBox(height: AppTheme.space6),

                  // Achievements & Badges
                  SectionHeader(title: 'Achievements'),
                  const SizedBox(height: AppTheme.space3),
                  const _AchievementsSection(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// GAMIFICATION HUB ROW
// ═══════════════════════════════════════════════════════════════════════════════════════

class _GamificationHubRow extends StatelessWidget {
  const _GamificationHubRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _HubCard(
            icon: Icons.emoji_events_rounded,
            title: 'My PRs',
            subtitle: 'Records',
            color: theme.colorScheme.secondary,
            onTap: () => context.pushNamed('personalRecords'),
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: _HubCard(
            icon: Icons.flag_rounded,
            title: 'Challenges',
            subtitle: 'Missions',
            color: Colors.deepOrange,
            onTap: () => context.pushNamed('challenges'),
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: _HubCard(
            icon: Icons.military_tech_rounded,
            title: 'Badges',
            subtitle: 'Milestones',
            color: theme.colorScheme.primary,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: DataCard(
          dense: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: AppTheme.space3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// CATEGORY CHIP
// ══════════════════════════════════════════════════════════════════════════════════════

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: label,
      icon: icon,
      selected: selected,
      color: theme.colorScheme.primary,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// PERIOD CHIP
// ══════════════════════════════════════════════════════════════════════════════════════

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: label,
      selected: selected,
      color: theme.colorScheme.primary,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// PODIUM VIEW
// ══════════════════════════════════════════════════════════════════════════════════════

class _PodiumView extends StatelessWidget {
  final List<LeaderboardUserEntity> top3;

  const _PodiumView({required this.top3});

  @override
  Widget build(BuildContext context) {
    final second = top3[1];
    final first = top3[0];
    final third = top3[2];

    return DataCard(
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
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: isCenter ? 56 : 46,
          height: isCenter ? 56 : 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 3),
            color: rankColor.withValues(alpha: 0.15),
          ),
          child: Text(
            user.avatarEmoji,
            style: TextStyle(fontSize: isCenter ? 26 : 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.name.split(' ').first,
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w600,
            fontSize: isCenter ? 13 : 11,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.xp} XP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Podium Block
        Container(
          width: 80,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
            border: Border.all(color: rankColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            rankBadge,
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: rankColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// USER RANK TILE
// ══════════════════════════════════════════════════════════════════════════════════════

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

    String metricValue;
    IconData metricIcon;
    switch (category) {
      case LeaderboardCategory.xp:
        metricValue = '${user.xp} XP';
        metricIcon = Icons.bolt_rounded;
      case LeaderboardCategory.volume:
        metricValue = '${(user.totalVolumeKg / 1000).toStringAsFixed(1)}k kg';
        metricIcon = Icons.fitness_center_rounded;
      case LeaderboardCategory.workouts:
        metricValue = '${user.totalWorkouts} workouts';
        metricIcon = Icons.directions_run_rounded;
      case LeaderboardCategory.streak:
        metricValue = '${user.currentStreak}d';
        metricIcon = Icons.local_fire_department_rounded;
    }

    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space2),
      dense: true,
      onTap: () {}, // Could navigate to profile
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: user.rank <= 3
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),

          // Avatar
          Avatar(
            emoji: user.avatarEmoji,
            size: 36,
            borderColor: user.isCurrentUser ? theme.colorScheme.primary : null,
            borderWidth: user.isCurrentUser ? 2 : 0,
          ),
          const SizedBox(width: AppTheme.space3),

          // Name & stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: user.isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                          color: user.isCurrentUser ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Badge(
                        label: 'YOU',
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${user.totalWorkouts} workouts · ${user.currentStreak}d streak',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Metric
          Row(
            children: [
              Icon(metricIcon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                metricValue,
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// WEEKLY CHALLENGES SECTION
// ══════════════════════════════════════════════════════════════════════════════════════

class _WeeklyChallengesSection extends StatelessWidget {
  const _WeeklyChallengesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final challenges = [
      _Challenge(
        title: 'Volume Beast',
        description: 'Lift 50,000 kg this week',
        progress: 0.67,
        xpReward: 500,
        color: theme.colorScheme.primary,
        icon: Icons.fitness_center_rounded,
      ),
      _Challenge(
        title: 'Streak Keeper',
        description: 'Workout 5 days in a row',
        progress: 0.8,
        xpReward: 300,
        color: Colors.deepOrange,
        icon: Icons.local_fire_department_rounded,
      ),
      _Challenge(
        title: 'Balanced Beast',
        description: 'Hit all 3 macro targets 4 days',
        progress: 0.45,
        xpReward: 400,
        color: Colors.deepPurple,
        icon: Icons.balance_outlined,
      ),
      _Challenge(
        title: 'Early Bird',
        description: 'Complete 3 workouts before 8 AM',
        progress: 1.0,
        xpReward: 200,
        color: Colors.amber,
        icon: Icons.wb_sunny_outlined,
        completed: true,
      ),
    ];

    return Column(
      children: challenges.map((c) => _ChallengeCard(challenge: c)).toList(),
    );
  }
}

class _Challenge {
  final String title;
  final String description;
  final double progress;
  final int xpReward;
  final Color color;
  final IconData icon;
  final bool completed;

  _Challenge({
    required this.title,
    required this.description,
    required this.progress,
    required this.xpReward,
    required this.color,
    required this.icon,
    this.completed = false,
  });
}

class _ChallengeCard extends StatelessWidget {
  final _Challenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DataCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: challenge.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(challenge.icon, size: 22, color: challenge.color),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (challenge.completed) ...[
                      const SizedBox(width: 6),
                      Badge(
                        label: 'CLAIMED',
                        color: const Color(0xFF007A33),
                        backgroundColor: const Color(0xFFE8F5E9),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(challenge.progress * 100).round()}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '+${challenge.xpReward} XP',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: challenge.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          if (challenge.completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF007A33).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'Claimed',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007A33),
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.color,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
              ),
              child: Text('Claim', style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════════
// ACHIEVEMENTS SECTION
// ══════════════════════════════════════════════════════════════════════════════════════

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData(title: 'First Workout', icon: '🏁', color: Colors.amber, unlocked: true),
      _BadgeData(title: 'Week Warrior', icon: '🔥', color: Colors.deepOrange, unlocked: true),
      _BadgeData(title: 'Century Club', icon: '💯', color: Colors.blue, unlocked: true),
      _BadgeData(title: 'PR Hunter', icon: '🏆', color: Colors.amber, unlocked: true),
      _BadgeData(title: 'Early Bird', icon: '🌅', color: Colors.orange, unlocked: false),
      _BadgeData(title: 'Iron Will', icon: '💪', color: Colors.red, unlocked: false),
      _BadgeData(title: 'Macro Master', icon: '🥗', color: Colors.green, unlocked: false),
      _BadgeData(title: 'Volume King', icon: '👑', color: Colors.purple, unlocked: false),
      _BadgeData(title: 'Consistency', icon: '📅', color: Colors.teal, unlocked: false),
      _BadgeData(title: 'Socialite', icon: '🤝', color: Colors.pink, unlocked: false),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: AppTheme.space2,
        mainAxisSpacing: AppTheme.space2,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
    );
  }
}

class _BadgeData {
  final String title;
  final String icon;
  final Color color;
  final bool unlocked;

  _BadgeData({required this.title, required this.icon, required this.color, required this.unlocked});
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = badge.unlocked;

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isUnlocked ? badge.color.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isUnlocked ? badge.color : theme.colorScheme.outlineVariant,
              width: isUnlocked ? 2 : 1,
            ),
          ),
          child: Text(
            badge.icon,
            style: TextStyle(fontSize: isUnlocked ? 28 : 24, color: isUnlocked ? badge.color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          badge.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 10,
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
            color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
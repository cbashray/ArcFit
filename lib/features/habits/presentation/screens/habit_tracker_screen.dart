import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';

class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedHabitDateProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(dailyCompletionsProvider);
    final streaksAsync = ref.watch(habitStreaksProvider);
    final summaryAsync = ref.watch(habitSummaryProvider);

    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker ⚡'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Pick Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                helpText: 'Select Date for Habit Tracking',
                builder: (ctx, child) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  return Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: isDark
                          ? const ColorScheme.dark(
                              primary: AppTheme.primaryGreen,
                              onPrimary: Colors.white,
                              surface: Color(0xFF1E1E1E),
                              onSurface: Colors.white,
                            )
                          : const ColorScheme.light(
                              primary: AppTheme.primaryGreen,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(selectedHabitDateProvider.notifier).state =
                    DateTime(picked.year, picked.month, picked.day);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Habit',
            onPressed: () => _showAddEditHabitModal(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(habitsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Progress Header Card
            _HeaderProgressCard(
              summary: summaryAsync.valueOrNull,
              isToday: isToday,
              selectedDate: selectedDate,
            ),
            const SizedBox(height: 16),

            // Date Selector Bar
            _HorizontalDateSelector(
              selectedDate: selectedDate,
              onSelectDate: (date) {
                ref.read(selectedHabitDateProvider.notifier).state = date;
              },
            ),
            const SizedBox(height: 20),

            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isToday
                      ? 'Today\'s Habits'
                      : 'Habits for ${DateFormat('MMM d').format(selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isToday)
                  TextButton.icon(
                    onPressed: () {
                      final now = DateTime.now();
                      ref.read(selectedHabitDateProvider.notifier).state =
                          DateTime(now.year, now.month, now.day);
                    },
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text('Go to Today'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Habits List
            habitsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Error loading habits: $err',
                      style: const TextStyle(color: AppTheme.errorRed)),
                ),
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return _EmptyHabitsCard(
                    onCreate: () => _showAddEditHabitModal(context, ref),
                  );
                }

                final completedIds = completionsAsync.valueOrNull ?? {};
                final streaksMap = streaksAsync.valueOrNull ?? {};

                return Column(
                  children: habits.map((habit) {
                    final isCompleted = completedIds.contains(habit.id);
                    final streak = streaksMap[habit.id] ??
                        HabitStreakEntity.empty(habit.id);

                    return _HabitCard(
                      key: ValueKey(habit.id),
                      habit: habit,
                      isCompleted: isCompleted,
                      streak: streak,
                      onToggle: () {
                        ref
                            .read(dailyCompletionsProvider.notifier)
                            .toggle(habit.id);
                      },
                      onEdit: () =>
                          _showAddEditHabitModal(context, ref, habit: habit),
                      onDelete: () => _confirmDeleteHabit(context, ref, habit),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditHabitModal(context, ref),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddEditHabitModal(BuildContext context, WidgetRef ref,
      {HabitEntity? habit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEditHabitSheet(habit: habit),
    );
  }

  void _confirmDeleteHabit(
      BuildContext context, WidgetRef ref, HabitEntity habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'Are you sure you want to remove "${habit.name}"? Your past completions will be preserved in history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed "${habit.name}"')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Progress Card
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderProgressCard extends StatelessWidget {
  final HabitSummary? summary;
  final bool isToday;
  final DateTime selectedDate;

  const _HeaderProgressCard({
    required this.summary,
    required this.isToday,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final completed = summary?.completed ?? 0;
    final total = summary?.total ?? 0;
    final progress = summary?.progress ?? 0.0;
    final pct = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF0083B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      isToday
                          ? 'Today\'s Consistency'
                          : DateFormat('EEEE, MMM d').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'No active habits set up yet.'
                      : (completed == total
                          ? '🎉 All habits completed! Amazing work!'
                          : '$completed of $total habits checked off ($pct%)'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular Progress Badge
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$pct%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal Date Selector with Week Navigation & Calendar Picker
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const _HorizontalDateSelector({
    required this.selectedDate,
    required this.onSelectDate,
  });

  Future<void> _openCalendarPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Select Date for Habit Tracking',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppTheme.primaryGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryGreen,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelectDate(DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _shiftWeek(int deltaDays) {
    onSelectDate(selectedDate.add(Duration(days: deltaDays)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate Monday of the current selected week
    final int weekdayOffset = (selectedDate.weekday - 1) % 7; // Monday = 0
    final startOfWeek = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: weekdayOffset));

    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final endOfWeek = weekDays.last;

    final isSameMonth = startOfWeek.month == endOfWeek.month;
    final rangeTitle = isSameMonth
        ? DateFormat('MMMM yyyy').format(startOfWeek)
        : '${DateFormat('MMM').format(startOfWeek)} - ${DateFormat('MMM yyyy').format(endOfWeek)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Week Header Bar with < Month/Year / Calendar >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Week
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                iconSize: 24,
                tooltip: 'Previous Week',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _shiftWeek(-7),
              ),

              // Month & Year clickable picker
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openCalendarPicker(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rangeTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              // Next Week
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                iconSize: 24,
                tooltip: 'Next Week',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _shiftWeek(7),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7-day strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isCurrentToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onSelectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : (isDark ? const Color(0xFF262626) : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : (isCurrentToday
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.6)
                                  : (isDark ? const Color(0xFF333333) : Colors.grey.shade200)),
                          width: isSelected || isCurrentToday ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white60 : Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          if (isCurrentToday)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Habit Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _HabitCard extends StatelessWidget {
  final HabitEntity habit;
  final bool isCompleted;
  final HabitStreakEntity streak;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.streak,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = Color(habit.colorValue);
    final iconData = habitIconFromCodePoint(habit.iconCodePoint);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? AppTheme.primaryGreen.withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Habit Icon Box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconData,
                  color: habitColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title, Description & Streaks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isCompleted
                            ? (isDark ? Colors.white54 : Colors.grey.shade500)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        habit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Streaks Badges Row
                    Row(
                      children: [
                        // Current Streak
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                '${streak.currentStreak}d streak',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Longest Streak
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                'Best: ${streak.longestStreak}d',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Checkbox Toggle Button
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primaryGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : (isDark ? Colors.white38 : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),

              // Action Options Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppTheme.errorRed),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppTheme.errorRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHabitsCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyHabitsCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: AppTheme.primaryGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Habits Found',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Build healthy routines by tracking daily fitness and wellness habits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create a Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Habit Icons Constant Mapping
// ─────────────────────────────────────────────────────────────────────────────

const List<IconData> _kAvailableHabitIcons = [
  Icons.water_drop_rounded,
  Icons.self_improvement_rounded,
  Icons.bedtime_rounded,
  Icons.restaurant_rounded,
  Icons.fitness_center_rounded,
  Icons.directions_run_rounded,
  Icons.directions_walk_rounded,
  Icons.menu_book_rounded,
  Icons.favorite_rounded,
  Icons.bolt_rounded,
  Icons.psychology_rounded,
  Icons.timer_rounded,
];

IconData habitIconFromCodePoint(int codePoint) {
  for (final icon in _kAvailableHabitIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  return Icons.check_circle_rounded;
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Habit Bottom Sheet Modal
// ─────────────────────────────────────────────────────────────────────────────

class _AddEditHabitSheet extends ConsumerStatefulWidget {
  final HabitEntity? habit;

  const _AddEditHabitSheet({this.habit});

  @override
  ConsumerState<_AddEditHabitSheet> createState() => _AddEditHabitSheetState();
}

class _AddEditHabitSheetState extends ConsumerState<_AddEditHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  late IconData _selectedIcon;
  late Color _selectedColor;

  static const List<IconData> _availableIcons = _kAvailableHabitIcons;

  static const List<Color> _availableColors = [
    AppTheme.primaryGreen,
    AppTheme.secondaryBlue,
    AppTheme.accentOrange,
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF009688), // Teal
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFF5722), // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descController =
        TextEditingController(text: widget.habit?.description ?? '');

    if (widget.habit != null) {
      _selectedIcon = habitIconFromCodePoint(widget.habit!.iconCodePoint);
      _selectedColor = Color(widget.habit!.colorValue);
    } else {
      _selectedIcon = _availableIcons.first;
      _selectedColor = _availableColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (widget.habit != null) {
      final updated = widget.habit!.copyWith(
        name: name,
        description: desc,
        iconCodePoint: _selectedIcon.codePoint,
        iconFontFamily: _selectedIcon.fontFamily,
        iconFontPackage: _selectedIcon.fontPackage,
        colorValue: _selectedColor.toARGB32(),
      );
      ref.read(habitsProvider.notifier).updateHabit(updated);
    } else {
      ref.read(habitsProvider.notifier).createHabit(
            name: name,
            description: desc,
            iconCodePoint: _selectedIcon.codePoint,
            iconFontFamily: _selectedIcon.fontFamily,
            iconFontPackage: _selectedIcon.fontPackage,
            colorValue: _selectedColor.toARGB32(),
          );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.habit != null
            ? 'Updated "$name"'
            : 'Created habit "$name" 🎉'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.habit != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Text(
                isEdit ? 'Edit Habit' : 'Create New Habit',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                autofocus: !isEdit,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g. 10 Min Morning Stretch',
                  prefixIcon: Icon(Icons.check_circle_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description Field
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Focus on hips and hamstrings',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 18),

              // Icon Picker
              const Text(
                'Choose Icon',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = icon == _selectedIcon;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.2)
                              : (isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? _selectedColor
                              : (isDark ? Colors.white70 : Colors.grey.shade700),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Color Picker
              const Text(
                'Choose Color',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = color == _selectedColor;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isEdit ? 'Save Changes' : 'Create Habit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

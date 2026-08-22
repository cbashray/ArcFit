import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/water_providers.dart';

class WaterIntakeWidget extends ConsumerWidget {
  const WaterIntakeWidget({super.key});

  void _showCustomWaterDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: '250');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Water'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            suffixText: 'ml',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                ref.read(dailyWaterProvider.notifier).addWater(val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSetTargetDialog(
      BuildContext context, WidgetRef ref, int currentTarget) {
    final controller = TextEditingController(text: currentTarget.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Water Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Daily Goal (ml)',
            suffixText: 'ml',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val >= 500) {
                ref.read(dailyWaterProvider.notifier).setTarget(val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(dailyWaterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return waterAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
      error: (err, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load water intake: $err'),
        ),
      ),
      data: (water) {
        final pct = (water.progress * 100).toInt();
        const waterColor = Color(0xFF00A3FF);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: waterColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('💧', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Water Intake',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              water.isGoalReached
                                  ? '🎉 Daily goal reached!'
                                  : '${water.remainingMl} ml remaining',
                              style: TextStyle(
                                fontSize: 12,
                                color: water.isGoalReached
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.shade600,
                                fontWeight: water.isGoalReached
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Set Target',
                      onPressed: () =>
                          _showSetTargetDialog(context, ref, water.targetMl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount and Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                        ),
                        children: [
                          TextSpan(
                            text: '${water.amountMl}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: waterColor,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${water.targetMl} ml',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: waterColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: water.progress,
                    minHeight: 12,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(waterColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Add Buttons
                Row(
                  children: [
                    Expanded(
                      child: _QuickAddButton(
                        label: '+250 ml',
                        icon: Icons.local_drink_outlined,
                        onTap: () => ref
                            .read(dailyWaterProvider.notifier)
                            .addWater(250),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        label: '+500 ml',
                        icon: Icons.water_drop_outlined,
                        onTap: () => ref
                            .read(dailyWaterProvider.notifier)
                            .addWater(500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        label: 'Custom',
                        icon: Icons.add_rounded,
                        onTap: () => _showCustomWaterDialog(context, ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00A3FF).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00A3FF)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00A3FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

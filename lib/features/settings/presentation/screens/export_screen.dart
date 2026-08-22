import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _exporting = false;

  Future<void> _exportCSV() async {
    setState(() => _exporting = true);
    try {
      final workouts = await ref.read(workoutsProvider.future);
      if (workouts.isEmpty) {
        _showSnack('No workouts to export yet.', isError: true);
        return;
      }

      final buf = StringBuffer();
      buf.writeln('Date,Title,Exercise,Sets,Reps,Weight(kg),Duration(min)');

      for (final w in workouts) {
        final date = DateFormat('yyyy-MM-dd').format(w.date);
        for (final ex in w.exercises) {
          buf.writeln(
            '"$date","${w.title}","${ex.exerciseName}",'
            '${ex.sets},${ex.reps},${ex.weight ?? 0},'
            '${w.durationMinutes.round()}',
          );
        }
      }

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/fitx_workouts_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
      await file.writeAsString(buf.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My FitX workout history',
        subject: 'FitX Workout History',
      );
    } catch (e) {
      _showSnack('Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📤 Export Your Data',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                workoutsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (workouts) => Text(
                    '${workouts.length} workouts · '
                    '${workouts.fold<int>(0, (sum, w) => sum + w.totalSets)} total sets',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CSV Export
          _ExportOptionCard(
            icon: Icons.table_chart_outlined,
            iconColor: AppTheme.primaryGreen,
            title: 'Export as CSV',
            subtitle: 'Spreadsheet-compatible format. Works with Excel, Google Sheets.',
            buttonLabel: _exporting ? 'Exporting…' : 'Export CSV',
            onTap: _exporting ? null : _exportCSV,
          ),
          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.secondaryBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data is stored locally on device. '
                    'Export creates a file you can share or back up anywhere.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;

  const _ExportOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

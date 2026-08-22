import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../progress/domain/entities/body_metric_entity.dart';
import '../providers/progress_providers.dart';

class BodyMetricsScreen extends ConsumerStatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  ConsumerState<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends ConsumerState<BodyMetricsScreen> {
  final _weightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    for (final ctrl in [
      _weightCtrl,
      _bodyFatCtrl,
      _chestCtrl,
      _waistCtrl,
      _hipsCtrl,
      _armCtrl,
      _notesCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least your weight.')),
      );
      return;
    }

    final metric = BodyMetricEntity(
      id: const Uuid().v4(),
      userId: 'local',
      date: DateTime.now(),
      weightKg: weight,
      bodyFatPct: double.tryParse(_bodyFatCtrl.text),
      chestCm: double.tryParse(_chestCtrl.text),
      waistCm: double.tryParse(_waistCtrl.text),
      hipsCm: double.tryParse(_hipsCtrl.text),
      armCm: double.tryParse(_armCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    await ref.read(bodyMetricsProvider.notifier).add(metric);
    if (!mounted) return;

    for (final ctrl in [
      _weightCtrl,
      _bodyFatCtrl,
      _chestCtrl,
      _waistCtrl,
      _hipsCtrl,
      _armCtrl,
      _notesCtrl,
    ]) {
      ctrl.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurements saved! 💪'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Body Metrics ⚖️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Log new entry ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Log Today\'s Measurements',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                          ctrl: _weightCtrl,
                          label: 'Weight (kg)',
                          icon: Icons.monitor_weight_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumField(
                          ctrl: _bodyFatCtrl,
                          label: 'Body fat %',
                          icon: Icons.percent),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                          ctrl: _chestCtrl,
                          label: 'Chest (cm)',
                          icon: Icons.straighten),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumField(
                          ctrl: _waistCtrl,
                          label: 'Waist (cm)',
                          icon: Icons.straighten),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                          ctrl: _hipsCtrl,
                          label: 'Hips (cm)',
                          icon: Icons.straighten),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumField(
                          ctrl: _armCtrl,
                          label: 'Arm (cm)',
                          icon: Icons.fitness_center_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Measurements'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── History ──
          const Text('History',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          metricsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (metrics) {
              if (metrics.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No measurements logged yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              }
              return Column(
                children: metrics.map((m) => _MetricRow(
                      metric: m,
                      onDelete: () =>
                          ref.read(bodyMetricsProvider.notifier).delete(m.id),
                    )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;

  const _NumField(
      {required this.ctrl, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final BodyMetricEntity metric;
  final VoidCallback onDelete;

  const _MetricRow({required this.metric, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d • h:mm a').format(metric.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (metric.weightKg != null)
                      _MetricChip(
                          '⚖️ ${metric.weightKg!.toStringAsFixed(1)} kg',
                          AppTheme.primaryGreen),
                    if (metric.bodyFatPct != null)
                      _MetricChip(
                          '💧 ${metric.bodyFatPct!.toStringAsFixed(1)}%',
                          AppTheme.secondaryBlue),
                    if (metric.waistCm != null)
                      _MetricChip(
                          '📏 waist ${metric.waistCm!.round()}cm',
                          AppTheme.accentOrange),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Colors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetricChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color)),
    );
  }
}

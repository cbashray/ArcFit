import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../domain/entities/personal_record_entity.dart';

/// Shows the 1RM calculator as a modal bottom sheet.
void showOneRmCalculator(
  BuildContext context, {
  double initialWeight = 0,
  int initialReps = 10,
  String exerciseName = '',
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OneRmSheet(
      initialWeight: initialWeight,
      initialReps: initialReps,
      exerciseName: exerciseName,
    ),
  );
}

class _OneRmSheet extends StatefulWidget {
  final double initialWeight;
  final int initialReps;
  final String exerciseName;

  const _OneRmSheet({
    required this.initialWeight,
    required this.initialReps,
    required this.exerciseName,
  });

  @override
  State<_OneRmSheet> createState() => _OneRmSheetState();
}

class _OneRmSheetState extends State<_OneRmSheet> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;
  double _oneRm = 0;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
        text: widget.initialWeight > 0 ? '${widget.initialWeight.round()}' : '');
    _repsCtrl = TextEditingController(text: '${widget.initialReps}');
    _calculate();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    setState(() {
      _oneRm = PersonalRecordEntity.calculateOneRepMax(weight, reps);
    });
  }

  /// Percentage of 1RM for common training zones.
  static const _zones = [
    (label: '100% — 1 RM', pct: 1.0, color: Color(0xFFD22B2B)),
    (label: '95% — 2–3 RM', pct: 0.95, color: Color(0xFFFF6B35)),
    (label: '90% — 4–5 RM', pct: 0.90, color: Color(0xFFFF9500)),
    (label: '85% — 6 RM', pct: 0.85, color: Color(0xFFFFCC00)),
    (label: '80% — 8 RM', pct: 0.80, color: Color(0xFF34C759)),
    (label: '75% — 10 RM', pct: 0.75, color: Color(0xFF00A859)),
    (label: '70% — 12 RM', pct: 0.70, color: Color(0xFF007AFF)),
    (label: '65% — 15 RM', pct: 0.65, color: Color(0xFF5856D6)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.exerciseName.isNotEmpty
                  ? '🏋️ 1RM – ${widget.exerciseName}'
                  : '🏋️ One-Rep Max Calculator',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Epley formula: weight × (1 + reps ÷ 30)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      isDense: true,
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      isDense: true,
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Result
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated 1RM',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _oneRm > 0 ? '${_oneRm.round()} kg' : '—',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            if (_oneRm > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Training zones',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ..._zones.map(
                (zone) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: zone.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          zone.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${(_oneRm * zone.pct).round()} kg',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: zone.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

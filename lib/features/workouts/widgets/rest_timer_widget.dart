import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Preset rest durations in seconds.
const _presets = [30, 60, 90, 120, 180];

/// Shows a bottom-sheet countdown rest timer.
void showRestTimer(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RestTimerSheet(),
  );
}

class _RestTimerSheet extends StatefulWidget {
  const _RestTimerSheet();

  @override
  State<_RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<_RestTimerSheet>
    with SingleTickerProviderStateMixin {
  int _totalSeconds = 60;
  int _remaining = 60;
  bool _running = false;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        HapticFeedback.heavyImpact();
        _timer?.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      } else {
        if (_remaining <= 4) HapticFeedback.lightImpact();
        setState(() => _remaining--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _totalSeconds;
      _running = false;
    });
  }

  void _setPreset(int seconds) {
    _timer?.cancel();
    setState(() {
      _totalSeconds = seconds;
      _remaining = seconds;
      _running = false;
    });
  }

  double get _progress =>
      _totalSeconds > 0 ? _remaining / _totalSeconds : 0.0;

  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = _remaining == 0;
    final timerColor =
        isDone ? AppTheme.primaryGreen : AppTheme.accentOrange;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            isDone ? '✅ Rest Complete!' : '⏱ Rest Timer',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          // Circular progress + time
          SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final scale = _running && !isDone
                    ? 1.0 + _pulseController.value * 0.02
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    painter: _CircularTimerPainter(
                      progress: _progress,
                      color: timerColor,
                      trackColor:
                          timerColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        _timeLabel,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: timerColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Preset chips
          Wrap(
            spacing: 8,
            children: _presets.map((s) {
              final label = s < 60 ? '${s}s' : '${s ~/ 60}m';
              final selected = _totalSeconds == s;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => _setPreset(s),
                selectedColor: timerColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? timerColor : null,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              IconButton.outlined(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Reset',
                onPressed: _reset,
              ),
              const SizedBox(width: 16),

              // Play/Pause
              FilledButton.icon(
                onPressed: isDone
                    ? () => _setPreset(_totalSeconds)
                    : (_running ? _pause : _start),
                icon: Icon(
                  isDone
                      ? Icons.replay_rounded
                      : (_running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                ),
                label: Text(
                  isDone
                      ? 'Again'
                      : (_running ? 'Pause' : 'Start'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: timerColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),

              // Close
              IconButton.outlined(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _CircularTimerPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter old) =>
      old.progress != progress || old.color != color;
}

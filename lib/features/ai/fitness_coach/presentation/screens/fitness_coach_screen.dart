import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart'
    show AppTheme;
import 'package:arcfit/features/shared/presentation/widgets/ui_components.dart';

class FitnessCoachScreen extends ConsumerStatefulWidget {
  const FitnessCoachScreen({super.key});

  @override
  ConsumerState<FitnessCoachScreen> createState() => _FitnessCoachScreenState();
}

class _FitnessCoachScreenState extends ConsumerState<FitnessCoachScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hey! 👋 I'm your ArcFit AI Coach. I can help you with workout tips, nutrition advice, recovery strategies, and more. What's on your mind today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _messageController.clear();
      _isLoading = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final response = _generateResponse(text);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  String _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('workout') || lower.contains('exercise') || lower.contains('train')) {
      return "For your next workout, I'd recommend a **Push/Pull/Legs split** hitting each muscle group 2x/week. Since you're doing 5 days, try:\n\n• **Mon**: Push (chest, shoulders, triceps)\n• **Tue**: Pull (back, biceps)\n• **Wed**: Legs (quads, hamstrings, glutes)\n• **Thu**: Upper Body (mixed)\n• **Fri**: Core + Cardio\n\nStart with compound movements (bench, rows, squats) for 3×8-10, then accessories for 3×12-15. Want me to generate a specific workout?";
    }

    if (lower.contains('diet') || lower.contains('nutrition') || lower.contains('food') || lower.contains('macro') || lower.contains('calorie')) {
      return "For nutrition, aim for **1.6-2.2g protein per kg bodyweight** daily. Split into 4-5 meals with 30-40g protein each.\n\n**Sample day (80kg male, maintenance ~2500 kcal):**\n• Breakfast: 3 eggs + oats + banana (45g P, 55g C, 15g F)\n• Lunch: Chicken rice bowl + veggies (40g P, 60g C, 10g F)\n• Pre-workout: Greek yogurt + honey (20g P, 30g C, 5g F)\n• Post-workout: Whey + dextrose (30g P, 40g C, 0g F)\n• Dinner: Salmon + sweet potato + broccoli (35g P, 40g C, 15g F)\n\nTotal: ~170g P, 225g C, 45g F. Adjust carbs/fats based on preference!";
    }

    if (lower.contains('recover') || lower.contains('sleep') || lower.contains('rest') || lower.contains('sore')) {
      return "Recovery is where growth happens. **Key pillars:**\n\n1. **Sleep**: 7-9 hours non-negotiable. GH peaks in deep sleep.\n2. **Protein timing**: 30-40g before bed (casein/cottage cheese) for overnight MPS.\n3. **Active recovery**: Light cardio + mobility on rest days improves blood flow.\n4. **Deload**: Every 4-6 weeks, cut volume 50% for a week.\n5. **Hydration**: 3-4L water daily. Even 2% dehydration drops performance 10%.\n\nIf soreness >72h, reduce volume 20% next week. Consider creatine (5g daily) for recovery.";
    }

    if (lower.contains('progress') || lower.contains('pr') || lower.contains('strength') || lower.contains('plateau')) {
      return "To break plateaus, apply **progressive overload** systematically:\n\n1. **Add weight**: +2.5kg upper / +5kg lower when you hit top of rep range\n2. **Add reps**: Push 1-2 more reps before adding weight\n3. **Add sets**: 4th set when 3×10 feels easy\n4. **Tempo**: Slow eccentric (3s down) increases time under tension\n5. **Rest periods**: 2-3min for compounds, 60-90s for accessories\n\nTrack everything in ArcFit. If stuck 3+ weeks on a lift, deload 15% and rebuild. Consistency > intensity.";
    }

    return "That's a great question! As your AI coach, I can help with:\n\n🏋️ **Workouts** - Programming, exercise selection, periodization\n🥗 **Nutrition** - Macros, meal timing, supplementation\n😴 **Recovery** - Sleep, deloads, mobility, injury prevention\n📈 **Progress** - Breaking plateaus, PR tracking, volume management\n\nTry asking me something specific like:\n• \"Generate a 4-day upper/lower split\"\n• \"What should I eat for 2000 kcal cutting?\"\n• \"How to fix my bench press plateau?\"\n• \"Best recovery strategies for leg day\"";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, size: 22, color: theme.colorScheme.onSurfaceVariant),
            tooltip: 'Clear Chat',
            onPressed: () => setState(() => _messages.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick prompt chips
          Container(
            padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space3),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickPromptChip(
                    label: 'Workout Plan',
                    icon: Icons.fitness_center_rounded,
                    onTap: () => _messageController.text = 'Generate a workout plan for me',
                  ),
                  const SizedBox(width: AppTheme.space2),
                  _QuickPromptChip(
                    label: 'Nutrition',
                    icon: Icons.restaurant_menu_rounded,
                    onTap: () => _messageController.text = 'Help me with nutrition and macros',
                  ),
                  const SizedBox(width: AppTheme.space2),
                  _QuickPromptChip(
                    label: 'Recovery',
                    icon: Icons.bedtime_rounded,
                    onTap: () => _messageController.text = 'Best recovery strategies',
                  ),
                  const SizedBox(width: AppTheme.space2),
                  _QuickPromptChip(
                    label: 'Break Plateau',
                    icon: Icons.trending_up_rounded,
                    onTap: () => _messageController.text = 'How to break my strength plateau',
                  ),
                ],
              ),
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.space4),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // Typing indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space2),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Text('🤖', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  _TypingIndicator(),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(AppTheme.space4, AppTheme.space3, AppTheme.space4, AppTheme.space3),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        prefixIcon: Icon(Icons.mic_outlined, color: theme.colorScheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.attach_file_outlined, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () {},
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space2),
                  FilledButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Icon(Icons.send_rounded, size: 22, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickPromptChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DataChip(
      label: label,
      icon: icon,
      onTap: onTap,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Avatar(
              emoji: '🤖',
              size: 32,
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.12),
            ),
            const SizedBox(width: AppTheme.space2),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMd),
                  topRight: Radius.circular(AppTheme.radiusMd),
                  bottomLeft: Radius.circular(isUser ? AppTheme.radiusMd : AppTheme.radiusXs),
                  bottomRight: Radius.circular(isUser ? AppTheme.radiusXs : AppTheme.radiusMd),
                ),
                border: isUser ? null : Border.all(color: theme.colorScheme.outlineVariant, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      color: isUser ? Colors.white : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      color: isUser ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppTheme.space2),
            Avatar(
              size: 32,
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.15;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = (value * 2 - 1).abs();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.5 + scale * 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
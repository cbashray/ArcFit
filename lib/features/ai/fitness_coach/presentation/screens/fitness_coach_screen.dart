import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_theme.dart';

// ─── Chat Message Entity ──────────────────────────────────────────────────────

enum ChatRole { user, model }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

// ─── Coach Provider ───────────────────────────────────────────────────────────

class CoachChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const CoachChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  CoachChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return CoachChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final coachChatProvider =
    NotifierProvider<CoachChatNotifier, CoachChatState>(
        CoachChatNotifier.new);

class CoachChatNotifier extends Notifier<CoachChatState> {
  @override
  CoachChatState build() {
    return CoachChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          role: ChatRole.model,
          content:
              "Hey! 👋 I'm your OnyxFit AI Coach. I can help you with workout tips, nutrition advice, recovery strategies, and more. What's on your mind today?",
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    // Generate AI response (rule-based fallback; swap for Gemini API)
    await Future.delayed(const Duration(milliseconds: 800));
    final reply = _generateResponse(text.trim().toLowerCase());

    final aiMsg = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
    );
  }

  void clear() => state = build();

  /// Smart rule-based responses — swap `_generateResponse` body with a Gemini
  /// API call to `generateContent` for full LLM power.
  String _generateResponse(String query) {
    if (query.contains('protein') || query.contains('eat')) {
      return '💪 For muscle building, aim for **1.6–2.2g of protein per kg of body weight** daily. Great sources include chicken breast (31g/100g), paneer (21g/100g), dal (8g/100g), and whey protein. Spread intake across 4–5 meals for best absorption.';
    }
    if (query.contains('fat') || query.contains('lose weight') ||
        query.contains('calorie')) {
      return '🔥 For fat loss, create a moderate calorie deficit of 300–500 kcal/day. Keep protein high (2g/kg) to preserve muscle, strength train 3–4x/week, and add 30 min cardio 3x/week. Track your food in the Nutrition tab!';
    }
    if (query.contains('rest') || query.contains('recover') ||
        query.contains('sore')) {
      return '😴 Recovery is when muscles actually grow! Ensure **7–9 hours of sleep**, eat adequate protein, and consider active recovery (light walking, stretching) on rest days. DOMS (delayed onset muscle soreness) is normal for 24–72 hours after new exercises.';
    }
    if (query.contains('chest') || query.contains('push')) {
      return '🏋️ For chest development, focus on: **Bench Press** (compound strength), **Incline DB Press** (upper chest), **Cable Flyes** (isolation/stretch). Progressive overload is key — increase weight by 2.5kg when you can complete all reps with good form.';
    }
    if (query.contains('back') || query.contains('pull')) {
      return '💪 Build a strong back with: **Deadlifts** (overall mass), **Pull-ups/Lat Pulldowns** (lat width), **Barbell Rows** (thickness), **Face Pulls** (rear delts + health). Pull-to-push ratio of 2:1 prevents imbalances.';
    }
    if (query.contains('leg') || query.contains('squat')) {
      return '🦵 Legs are 60% of your muscle mass! Prioritize: **Squats** (king of exercises), **Romanian Deadlifts** (hamstrings), **Leg Press** (volume), **Lunges** (balance). Don\'t skip legs — they boost total testosterone production!';
    }
    if (query.contains('supplement') || query.contains('creatine')) {
      return '💊 Evidence-based supplements:\n• **Creatine monohydrate** (5g/day) — proven muscle/strength gains\n• **Whey protein** — convenient protein source\n• **Vitamin D3** — especially important in India (low sun exposure indoors)\n• **Caffeine** — proven performance booster\n\nSkip the rest — most are marketing.';
    }
    if (query.contains('warm') || query.contains('warmup')) {
      return '🔥 A good warmup takes 5–10 min:\n1. Light cardio (jumping jacks, bike)\n2. Dynamic stretches (arm circles, leg swings)\n3. Activation (band pull-aparts, glute bridges)\n4. 2–3 warm-up sets at 40–60% of working weight\n\nThis prevents injury and improves performance!';
    }
    if (query.contains('Indian') || query.contains('desi') ||
        query.contains('roti') || query.contains('dal')) {
      return '🇮🇳 Indian food is **great for fitness**! High-protein options: paneer, dal, rajma, chole, chicken tikka, eggs. For carbs: brown rice, roti, oats-upma, poha. Use your Nutrition tab to track — I\'ve loaded it with 30+ Indian foods with accurate macros!';
    }
    if (query.contains('beginner') || query.contains('start') ||
        query.contains('new')) {
      return '🌟 Welcome to your fitness journey! Start with:\n• **3 days/week** full-body workouts\n• Master the **big 5**: squat, deadlift, bench, row, overhead press\n• Focus on **form over weight** for first 3 months\n• **Progressive overload**: add a small amount each week\n• Track everything in OnyxFit — data drives progress!';
    }
    return '🤔 Great question! As your AI coach, I\'d suggest focusing on consistency above all else. Log your workouts daily, track your nutrition, and aim to progressively overload each week. Small improvements compound into massive results over time. What specific aspect of your training would you like to optimize?';
  }
}

// ─── Fitness Coach Screen ─────────────────────────────────────────────────────

class FitnessCoachScreen extends ConsumerStatefulWidget {
  const FitnessCoachScreen({super.key});

  @override
  ConsumerState<FitnessCoachScreen> createState() => _FitnessCoachScreenState();
}

class _FitnessCoachScreenState extends ConsumerState<FitnessCoachScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _quickPrompts = [
    '💪 How much protein do I need?',
    '🔥 How do I lose fat?',
    '😴 How do I recover faster?',
    '🏋️ Best chest exercises?',
    '🦵 Best leg day routine?',
    '💊 Which supplements work?',
    '🇮🇳 Best Indian foods for fitness?',
    '🌟 Tips for beginners',
  ];

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? text]) async {
    final msg = text ?? _textCtrl.text;
    if (msg.trim().isEmpty) return;
    _textCtrl.clear();
    await ref.read(coachChatProvider.notifier).sendMessage(msg);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(coachChatProvider);
    final theme = Theme.of(context);

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [Colors.deepPurple, AppTheme.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            const Text('AI Coach'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New conversation',
            onPressed: () => ref.read(coachChatProvider.notifier).clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chat.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: chat.messages[index]);
              },
            ),
          ),

          // Quick prompts (shown only when first message)
          if (chat.messages.length <= 1)
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(
                      _quickPrompts[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () =>
                        _send(_quickPrompts[index].replaceAll(RegExp(r'^[^\w]+'), '')),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Ask your AI coach...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: chat.isLoading ? null : _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [Colors.deepPurple, AppTheme.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primaryGreen
                    : (theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : null,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Colors.deepPurple, AppTheme.secondaryBlue],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Opacity(
                      opacity: ((_anim.value + delay) % 1.0)
                          .clamp(0.2, 1.0),
                      child: const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

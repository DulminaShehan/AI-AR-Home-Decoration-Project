import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

/// AI Design Assistant chat screen with message bubbles and quick suggestions.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  bool _isTyping = false;

  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _messages = DummyData.initialMessages
        .asMap()
        .entries
        .map((e) => ChatMessage(
              text: e.value.$2,
              isUser: e.value.$1,
              time: now.subtract(
                  Duration(minutes: (DummyData.initialMessages.length - e.key) * 3)),
            ))
        .toList();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
    );
    setState(() {
      _messages.add(msg);
      _isTyping = true;
      _input.clear();
    });
    _scrollToBottom();

    // Simulate AI reply after a short delay
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: _aiReply(text),
          isUser: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _aiReply(String q) {
    final lower = q.toLowerCase();
    if (lower.contains('color') || lower.contains('colour')) {
      return 'For a timeless palette, start with a neutral base (warm whites or soft greys) and layer in 1–2 accent colours. A 60-30-10 rule works beautifully: 60% dominant, 30% secondary, 10% accent.';
    }
    if (lower.contains('sofa') || lower.contains('couch')) {
      return 'A sofa is the anchor of any living room. Float it away from walls, face it toward the focal point, and ground it with a rug. For small spaces, a loveseat or modular sofa saves valuable floor space.';
    }
    if (lower.contains('light') || lower.contains('lamp')) {
      return 'Layer your lighting with three types:\n• Ambient (overhead) — sets the baseline\n• Task (reading lamps) — targeted illumination\n• Accent (strip lights, sconces) — adds mood and depth';
    }
    if (lower.contains('budget') || lower.contains('cheap') || lower.contains('afford')) {
      return 'Great design doesn\'t require a big budget! Focus on:\n• Statement pieces for hero spots (sofa, dining table)\n• Budget-friendly options for secondary items\n• Plants and textiles for affordable warmth';
    }
    if (lower.contains('small') || lower.contains('tiny') || lower.contains('compact')) {
      return 'For small spaces: use vertical space with tall shelving, choose furniture with exposed legs to float the eye, use mirrors to double perceived depth, and keep a consistent light colour palette throughout.';
    }
    return 'That\'s a great design question! The key is to balance function and aesthetics. Consider your lifestyle, the natural light available, and pick a cohesive colour story before selecting furniture. Would you like specific advice on any particular aspect?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60, left: -40,
            child: _Glow(
                color: AppTheme.violet.withValues(alpha: 0.12), size: 240),
          ),

          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),

              // ── App Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const _GlassBtn(
                          icon: Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 12),
                    // AI avatar
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.violetGlow,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Design Assistant',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          Row(children: [
                            Container(
                              width: 6, height: 6,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.teal,
                              ),
                            ),
                            const Text('Online',
                                style: TextStyle(
                                  color: AppTheme.teal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                )),
                          ]),
                        ],
                      ),
                    ),
                    const _GlassBtn(icon: Icons.more_vert_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              const Divider(
                  color: AppTheme.glassBorder, height: 1, thickness: 1),

              // ── Messages ─────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_isTyping && i == _messages.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(msg: _messages[i]);
                  },
                ),
              ),

              // ── Quick suggestions ─────────────────────────────────────
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyData.chatSuggestions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () =>
                        _sendMessage(DummyData.chatSuggestions[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.violet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.violet.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        DummyData.chatSuggestions[i],
                        style: const TextStyle(
                          color: AppTheme.violetLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Input bar ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, MediaQuery.of(context).padding.bottom + 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg2,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _input,
                              style: const TextStyle(
                                  color: AppTheme.textHigh, fontSize: 14),
                              maxLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Ask about design…',
                                hintStyle: TextStyle(
                                    color: AppTheme.textLow, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _sendMessage(_input.text),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.heroGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppTheme.violetGlow,
                              ),
                              child: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.heroGradient : null,
                color: isUser ? null : AppTheme.bg3,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppTheme.glassBorder),
                boxShadow: isUser
                    ? [BoxShadow(
                        color: AppTheme.violet.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )]
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textHigh,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: AppTheme.bg3,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppTheme.textMid, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 600),
            )..repeat(reverse: true, period: Duration(milliseconds: 600 + i * 150)));
    _anims = _ctrls
        .map((c) =>
            Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bg3,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.violet.withValues(
                          alpha: 0.3 + _anims[i].value * 0.7),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: AppTheme.glass,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Icon(icon, size: 18, color: AppTheme.textHigh),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

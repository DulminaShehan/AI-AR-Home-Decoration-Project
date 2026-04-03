import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/ai_suggestion.dart';
import '../theme/app_theme.dart';

/// Premium staggered AI suggestion panel with glassmorphism tiles.
class AiSuggestionPanel extends StatefulWidget {
  final List<AiSuggestion> suggestions;
  const AiSuggestionPanel({super.key, required this.suggestions});

  @override
  State<AiSuggestionPanel> createState() => _AiSuggestionPanelState();
}

class _AiSuggestionPanelState extends State<AiSuggestionPanel> {
  final List<bool> _visible = [];

  @override
  void initState() {
    super.initState();
    _visible.addAll(List.filled(widget.suggestions.length, false));
    for (var i = 0; i < widget.suggestions.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 130), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Row(
          children: [
            // Gradient icon badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.violetGlow,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Design Insights',
                    style: Theme.of(context).textTheme.titleLarge),
                const Text('Personalised recommendations',
                    style: TextStyle(
                      color: AppTheme.textMid,
                      fontSize: 12,
                    )),
              ],
            ),
            const Spacer(),
            // "See all" ghost chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Text('See all',
                  style: TextStyle(
                    color: AppTheme.violetLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Tiles ─────────────────────────────────────────────────────────
        ...List.generate(widget.suggestions.length, (i) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: _visible[i] ? 1.0 : 0.0,
            curve: Curves.easeOut,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 450),
              offset: _visible[i] ? Offset.zero : const Offset(0.0, 0.12),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionTile(suggestion: widget.suggestions[i]),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final AiSuggestion suggestion;
  const _SuggestionTile({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.glass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.glassBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box with violet tint
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.violet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: AppTheme.violet.withValues(alpha: 0.25),
                      width: 1),
                ),
                alignment: Alignment.center,
                child: Text(suggestion.icon,
                    style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.title,
                        style: const TextStyle(
                          color: AppTheme.textHigh,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(suggestion.body,
                        style: const TextStyle(
                          color: AppTheme.textMid,
                          fontSize: 12,
                          height: 1.5,
                        )),
                  ],
                ),
              ),

              // Arrow
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppTheme.textLow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/dummy_data.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_suggestion_panel.dart';
import '../widgets/animated_gradient_button.dart';
import '../widgets/ar_preview_widget.dart';
import '../widgets/furniture_card.dart';

/// Premium Room Detail screen — glassmorphism header, AR toggle, furniture carousel.
class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _arActive = false;
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _enterFade =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final furniture   = DummyData.furnitureByRoom[widget.room.id] ?? [];
    final suggestions = DummyData.suggestionsByRoom[widget.room.id] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: FadeTransition(
        opacity: _enterFade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Collapsing image header ──────────────────────────────
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppTheme.bg1,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero room photo
                    Hero(
                      tag: 'room_image_${widget.room.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.room.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppTheme.bg3),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppTheme.bg3),
                      ),
                    ),
                    // Gradient scrim — bottom heavy
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppTheme.bg1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.4, 1.0],
                        ),
                      ),
                    ),
                    // Ambient violet tint
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.violet.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Room name overlay (bottom)
                    Positioned(
                      left: 22, right: 22, bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tag
                          if (widget.room.tag.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.heroGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(widget.room.tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  )),
                            ),
                          Text(widget.room.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 30)),
                          const SizedBox(height: 4),
                          Text(widget.room.description,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Transparent top bar with back + action buttons
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassIconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(children: [
                    _GlassIconBtn(
                        icon: Icons.share_outlined, onTap: () {}),
                    const SizedBox(width: 8),
                    _GlassIconBtn(
                        icon: Icons.bookmark_border_rounded,
                        onTap: () {}),
                  ]),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Quick stats chips ──────────────────────────
                    _QuickStats(room: widget.room),
                    const SizedBox(height: 28),

                    // ── AR Preview section ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AR Preview',
                            style:
                                Theme.of(context).textTheme.titleLarge),
                        // Live / Static toggle pill
                        _TogglePill(
                          active: _arActive,
                          onToggle: () =>
                              setState(() => _arActive = !_arActive),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Animated swap AR ↔ static
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                            scale: Tween(begin: 0.96, end: 1.0)
                                .animate(anim),
                            child: child),
                      ),
                      child: _arActive
                          ? ArPreviewWidget(
                              key: const ValueKey('ar'),
                              roomId: widget.room.id,
                            )
                          : _StaticPreview(
                              key: const ValueKey('static'),
                              imageUrl: widget.room.imageUrl,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ── AR CTA button ──────────────────────────────
                    AnimatedGradientButton(
                      label: _arActive ? 'Stop AR View' : 'Start AR View',
                      icon: _arActive
                          ? Icons.stop_circle_outlined
                          : Icons.view_in_ar_rounded,
                      gradient: _arActive
                          ? const LinearGradient(
                              colors: [AppTheme.teal, Color(0xFF059669)])
                          : AppTheme.cyanGradient,
                      glow: _arActive
                          ? [BoxShadow(
                              color: AppTheme.teal.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6))]
                          : AppTheme.cyanGlow,
                      onTap: () =>
                          setState(() => _arActive = !_arActive),
                    ),

                    const SizedBox(height: 32),

                    // ── Furniture carousel ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recommended Furniture',
                            style:
                                Theme.of(context).textTheme.titleLarge),
                        _GhostLink(label: 'View all', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 290,
                      child: furniture.isNotEmpty
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 4),
                              itemCount: furniture.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, i) =>
                                  FurnitureCard(furniture: furniture[i]),
                            )
                          : const _EmptyState(
                              label: 'No furniture data yet.'),
                    ),

                    const SizedBox(height: 32),

                    // ── AI Suggestions ─────────────────────────────
                    if (suggestions.isNotEmpty)
                      AiSuggestionPanel(suggestions: suggestions),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

/// Glass icon button used in the app bar
class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bg0.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(13),
              border:
                  Border.all(color: AppTheme.glassBorder, width: 1),
            ),
            child: Icon(icon, size: 17, color: AppTheme.textHigh),
          ),
        ),
      ),
    );
  }
}

/// Quick-stats chips row
class _QuickStats extends StatelessWidget {
  final Room room;
  const _QuickStats({required this.room});

  @override
  Widget build(BuildContext context) {
    final fCount =
        DummyData.furnitureByRoom[room.id]?.length ?? 0;
    final sCount =
        DummyData.suggestionsByRoom[room.id]?.length ?? 0;

    return Row(children: [
      _StatChip(
          icon: Icons.chair_outlined,
          label: '$fCount items',
          color: AppTheme.violet),
      const SizedBox(width: 10),
      _StatChip(
          icon: Icons.auto_awesome_rounded,
          label: '$sCount tips',
          color: AppTheme.cyan),
      const SizedBox(width: 10),
      const _StatChip(
          icon: Icons.view_in_ar_rounded,
          label: 'AR Ready',
          color: AppTheme.teal),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

/// AR/Static toggle pill
class _TogglePill extends StatelessWidget {
  final bool active;
  final VoidCallback onToggle;
  const _TogglePill({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.cyanGradient : null,
          color: active ? null : AppTheme.bg3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active
                  ? Colors.transparent
                  : AppTheme.glassBorder),
          boxShadow: active ? AppTheme.cyanGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                active
                    ? Icons.videocam_rounded
                    : Icons.image_outlined,
                size: 13,
                color: active ? Colors.white : AppTheme.textMid),
            const SizedBox(width: 5),
            Text(active ? 'Live AR' : 'Static',
                style: TextStyle(
                  color: active ? Colors.white : AppTheme.textMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

/// Static room snapshot (pre-AR)
class _StaticPreview extends StatelessWidget {
  final String imageUrl;
  const _StaticPreview({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 256,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(height: 256, color: AppTheme.bg3),
            errorWidget: (_, __, ___) =>
                Container(height: 256, color: AppTheme.bg3),
          ),
          // "Activate AR" hint chip (bottom-right)
          Positioned(
            bottom: 14, right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bg0.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.cyan.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_in_ar_rounded,
                          size: 13, color: AppTheme.cyan),
                      SizedBox(width: 5),
                      Text('Activate AR',
                          style: TextStyle(
                            color: AppTheme.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: const Text('View all',
            style: TextStyle(
              color: AppTheme.violetLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label,
          style: const TextStyle(color: AppTheme.textMid)),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/room.dart';
import '../theme/app_theme.dart';

/// Premium glassmorphism room card for the home screen grid.
class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { _ctrl.forward(); setState(() => _hovering = true); },
      onTapUp:     (_) { _ctrl.reverse(); setState(() => _hovering = false); widget.onTap(); },
      onTapCancel: ()  { _ctrl.reverse(); setState(() => _hovering = false); },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.violet.withValues(alpha: _hovering ? 0.3 : 0.12),
                blurRadius: _hovering ? 28 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Room image ─────────────────────────────────────────
                Hero(
                  tag: 'room_image_${widget.room.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.room.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _Shimmer(),
                    errorWidget: (_, __, ___) => _Placeholder(),
                  ),
                ),

                // ── Deep gradient scrim ────────────────────────────────
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xF0070B14)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                    ),
                  ),
                ),

                // ── Tag badge ──────────────────────────────────────────
                if (widget.room.tag.isNotEmpty)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _TagBadge(label: widget.room.tag),
                  ),

                // ── Favourite micro-button ─────────────────────────────
                Positioned(
                  top: 10,
                  right: 10,
                  child: _FavButton(),
                ),

                // ── Text info ──────────────────────────────────────────
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pill row: AR + item count
                      const Row(
                        children: [
                          _MicroPill(
                              icon: Icons.view_in_ar_rounded,
                              label: 'AR Ready',
                              color: AppTheme.cyan),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.room.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.room.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TagBadge extends StatelessWidget {
  final String label;
  const _TagBadge({required this.label});

  LinearGradient get _grad {
    switch (label) {
      case 'Popular':  return const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]);
      case 'New':      return AppTheme.cyanGradient;
      case 'Trending': return AppTheme.heroGradient;
      default:         return AppTheme.heroGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: _grad,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 6, offset: const Offset(0, 2),
        )],
      ),
      child: Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          )),
    );
  }
}

class _MicroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MicroPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(color: color, fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavButton extends StatefulWidget {
  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton>
    with SingleTickerProviderStateMixin {
  bool _fav = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _fav = !_fav);
        _ctrl.forward(from: 0);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder, width: 0.8),
            ),
            child: ScaleTransition(
              scale: _scale,
              child: Icon(
                _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 15,
                color: _fav ? AppTheme.rose : AppTheme.textMid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppTheme.bg2,
        highlightColor: AppTheme.bg3,
        child: Container(color: AppTheme.bg2),
      );
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.bg3,
        child: const Icon(Icons.image_outlined,
            color: AppTheme.textLow, size: 36),
      );
}

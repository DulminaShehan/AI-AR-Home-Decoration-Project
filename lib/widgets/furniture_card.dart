import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/furniture.dart';
import '../theme/app_theme.dart';

/// Premium glassmorphism furniture card for the horizontal carousel.
class FurnitureCard extends StatefulWidget {
  final Furniture furniture;
  const FurnitureCard({super.key, required this.furniture});

  @override
  State<FurnitureCard> createState() => _FurnitureCardState();
}

class _FurnitureCardState extends State<FurnitureCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _liked = !_liked);
    _heartCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.furniture;

    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ────────────────────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 126,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: f.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: AppTheme.bg2,
                    highlightColor: AppTheme.bg3,
                    child: Container(color: AppTheme.bg2, height: 126),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.bg3,
                    height: 126,
                    child: const Icon(Icons.chair_outlined,
                        color: AppTheme.textLow, size: 36),
                  ),
                ),
              ),

              // Gradient over image bottom
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.bg2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // "New" badge
              if (f.isNew)
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cyanGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('NEW',
                        style: TextStyle(
                          color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w800, letterSpacing: 0.8,
                        )),
                  ),
                ),

              // Like button
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.glass,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: AppTheme.glassBorder, width: 0.8),
                        ),
                        child: ScaleTransition(
                          scale: _heartScale,
                          child: Icon(
                            _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color: _liked
                                ? AppTheme.rose
                                : AppTheme.textMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.violet.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(f.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.violetLight,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      )),
                ),
                const SizedBox(height: 5),

                // Name
                Text(f.name,
                    style: const TextStyle(
                      color: AppTheme.textHigh,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),

                // Price + rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.formattedPrice,
                        style: const TextStyle(
                          color: AppTheme.amber,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        )),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppTheme.amber),
                      const SizedBox(width: 3),
                      Text(f.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textMid,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
                    ]),
                  ],
                ),
                const SizedBox(height: 10),

                // Place in AR button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppTheme.cyanGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.cyanGlow,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_in_ar_rounded,
                            size: 13, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Place in AR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
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

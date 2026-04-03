import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/furniture.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Saved favourites grid — listens to [AppState.instance.favorites].
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: Stack(
        children: [
          Positioned(
            top: -60, right: -60,
            child: _Glow(
                color: AppTheme.rose.withValues(alpha: 0.08), size: 220),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),

              // ── App bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const _GlassBtn(
                          icon: Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Favourites',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium),
                    ),
                    ValueListenableBuilder<List<Furniture>>(
                      valueListenable: AppState.instance.favorites,
                      builder: (_, favs, __) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.rose.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_rounded,
                                size: 12, color: AppTheme.rose),
                            const SizedBox(width: 5),
                            Text('${favs.length}',
                                style: const TextStyle(
                                  color: AppTheme.rose,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Content ────────────────────────────────────────────
              Expanded(
                child: ValueListenableBuilder<List<Furniture>>(
                  valueListenable: AppState.instance.favorites,
                  builder: (_, favs, __) {
                    if (favs.isEmpty) {
                      return const _EmptyFavourites();
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: favs.length,
                      itemBuilder: (_, i) =>
                          _FavCard(furniture: favs[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Favourite card ────────────────────────────────────────────────────────────

class _FavCard extends StatelessWidget {
  final Furniture furniture;
  const _FavCard({required this.furniture});

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: f.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.bg3,
                    child: const Icon(Icons.chair_outlined,
                        color: AppTheme.textLow, size: 36),
                  ),
                ),
                // Bottom fade
                const Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: SizedBox(
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppTheme.bg2],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () =>
                        AppState.instance.toggleFavorite(f),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.rose.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                                color: AppTheme.rose.withValues(alpha: 0.4),
                                width: 0.8),
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              size: 15, color: AppTheme.rose),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Info ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.violetLight,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    )),
                const SizedBox(height: 3),
                Text(f.name,
                    style: const TextStyle(
                      color: AppTheme.textHigh,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.formattedPrice,
                        style: const TextStyle(
                          color: AppTheme.amber,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        )),
                    GestureDetector(
                      onTap: () =>
                          AppState.instance.addToCart(f.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cyanGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 12,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppTheme.rose.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.rose.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: AppTheme.rose, size: 40),
          ),
          const SizedBox(height: 18),
          const Text('No favourites yet',
              style: TextStyle(
                color: AppTheme.textHigh,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          const Text('Tap the heart icon on any item\nto save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMid,
                fontSize: 13,
                height: 1.5,
              )),
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

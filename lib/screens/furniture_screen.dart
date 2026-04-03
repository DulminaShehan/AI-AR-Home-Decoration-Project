import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../data/dummy_data.dart';
import '../models/furniture.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Full furniture browser with category filter, search, and cart/favourites.
class FurnitureScreen extends StatefulWidget {
  const FurnitureScreen({super.key});

  @override
  State<FurnitureScreen> createState() => _FurnitureScreenState();
}

class _FurnitureScreenState extends State<FurnitureScreen> {
  int _selectedCat = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  static const _categories = [
    'All', 'Seating', 'Tables', 'Storage',
    'Beds', 'Lighting', 'Desks', 'Decor', 'Accessories', 'Vanities',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Furniture> get _filtered {
    var list = DummyData.allFurniture;
    if (_selectedCat != 0) {
      list = list
          .where((f) => f.category == _categories[_selectedCat])
          .toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((f) => f.name.toLowerCase().contains(_query.toLowerCase()) ||
              f.category.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -80, right: -60,
            child: _Glow(color: AppTheme.cyan.withValues(alpha: 0.08), size: 260),
          ),

          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),

              // ── App Bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const _GlassBtn(icon: Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Furniture',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    ValueListenableBuilder<Map<String, int>>(
                      valueListenable: AppState.instance.cart,
                      builder: (_, cart, __) {
                        final count = AppState.instance.cartItemCount;
                        return Stack(
                          children: [
                            _GlassBtn(
                              icon: Icons.shopping_bag_outlined,
                              onTap: () {},
                            ),
                            if (count > 0)
                              Positioned(
                                top: 6, right: 6,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.rose,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Search bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.glass,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                            color: AppTheme.textHigh, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search furniture…',
                          hintStyle: const TextStyle(
                              color: AppTheme.textLow, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textMid, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: const Icon(Icons.close_rounded,
                                      color: AppTheme.textMid, size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Category filter ──────────────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final active = i == _selectedCat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCat = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: active ? AppTheme.heroGradient : null,
                          color: active ? null : AppTheme.bg2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? Colors.transparent
                                : AppTheme.glassBorder,
                          ),
                          boxShadow:
                              active ? AppTheme.violetGlow : null,
                        ),
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : AppTheme.textMid,
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Grid ─────────────────────────────────────────────────────
              Expanded(
                child: Builder(
                  builder: (_) {
                    final items = _filtered;
                    if (items.isEmpty) {
                      return const _EmptyState();
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) =>
                          _FurnitureGridCard(furniture: items[i]),
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

// ── Grid card ─────────────────────────────────────────────────────────────────

class _FurnitureGridCard extends StatefulWidget {
  final Furniture furniture;
  const _FurnitureGridCard({required this.furniture});

  @override
  State<_FurnitureGridCard> createState() => _FurnitureGridCardState();
}

class _FurnitureGridCardState extends State<_FurnitureGridCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
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
    final f = widget.furniture;
    return ValueListenableBuilder<List<Furniture>>(
      valueListenable: AppState.instance.favorites,
      builder: (_, favs, __) {
        final isFav = AppState.instance.isFavorite(f.id);
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
              // ── Image ────────────────────────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: f.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppTheme.bg2,
                        highlightColor: AppTheme.bg3,
                        child: Container(color: AppTheme.bg2),
                      ),
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
                        height: 48,
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
                    // New badge
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
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              )),
                        ),
                      ),
                    // Heart button
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () {
                          AppState.instance.toggleFavorite(f);
                          _ctrl.forward(from: 0);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.glass,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: AppTheme.glassBorder,
                                    width: 0.8),
                              ),
                              child: ScaleTransition(
                                scale: _scale,
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 15,
                                  color: isFav
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
              ),

              // ── Info ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(f.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.violetLight,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        )),
                    const SizedBox(height: 3),
                    // Name
                    Text(f.name,
                        style: const TextStyle(
                          color: AppTheme.textHigh,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    // Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(f.formattedPrice,
                            style: const TextStyle(
                              color: AppTheme.amber,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            )),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 11, color: AppTheme.amber),
                          const SizedBox(width: 2),
                          Text(f.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppTheme.textMid,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              )),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Add to cart
                    ValueListenableBuilder<Map<String, int>>(
                      valueListenable: AppState.instance.cart,
                      builder: (_, cart, __) {
                        final qty = AppState.instance.cartQuantity(f.id);
                        return qty == 0
                            ? GestureDetector(
                                onTap: () =>
                                    AppState.instance.addToCart(f.id),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.cyanGradient,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    boxShadow: AppTheme.cyanGlow,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_shopping_cart_rounded,
                                          size: 12,
                                          color: Colors.white),
                                      SizedBox(width: 5),
                                      Text('Add to Cart',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppTheme.bg3,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppTheme.cyan
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () => AppState.instance
                                          .decreaseCart(f.id),
                                      child: const Icon(Icons.remove,
                                          size: 14,
                                          color: AppTheme.textMid),
                                    ),
                                    Text('$qty',
                                        style: const TextStyle(
                                          color: AppTheme.cyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    GestureDetector(
                                      onTap: () => AppState.instance
                                          .addToCart(f.id),
                                      child: const Icon(Icons.add,
                                          size: 14,
                                          color: AppTheme.cyan),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _GlassBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: ClipRRect(
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppTheme.bg2,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppTheme.textLow, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No items found',
              style: TextStyle(
                  color: AppTheme.textMid,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Try a different category or search',
              style: TextStyle(color: AppTheme.textLow, fontSize: 13)),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/room_card.dart';
import 'ai_chat_screen.dart';
import 'ar_camera_screen.dart';
import 'budget_planner_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'furniture_screen.dart';
import 'room_detail_screen.dart';

/// Premium Home Screen — glassmorphism header + staggered room grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  int _selectedCategory = 0;
  int _selectedStyle = 0;

  static const List<String> _categories = [
    'All', 'Living', 'Bedroom', 'Kitchen', 'Office',
  ];

  static const List<(IconData, String, Color)> _styles = [
    (Icons.auto_awesome_rounded,      'Modern',        AppTheme.violet),
    (Icons.spa_outlined,              'Minimal',        AppTheme.cyan),
    (Icons.diamond_outlined,          'Luxury',         AppTheme.amber),
    (Icons.forest_outlined,           'Scandinavian',   AppTheme.teal),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // ── Ambient background glows ──────────────────────────────
            Positioned(
              top: -120, left: -80,
              child: _AmbientGlow(
                  color: AppTheme.violet.withValues(alpha: 0.18),
                  size: 340),
            ),
            Positioned(
              top: 200, right: -100,
              child: _AmbientGlow(
                  color: AppTheme.indigo.withValues(alpha: 0.12),
                  size: 280),
            ),

            // ── Main scroll content ───────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top safe-area spacer ────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 16),
                ),

                // ── Header row ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _HeaderRow(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Hero banner ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _HeroBanner(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 22)),

                // ── Style selector ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _StyleSelector(
                      styles: _styles,
                      selected: _selectedStyle,
                      onSelect: (i) => setState(() => _selectedStyle = i),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Stats row ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _StatsRow(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Section title + category filter ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Choose a Room',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                            _GhostChip(label: 'View all', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _CategoryRow(
                          categories: _categories,
                          selected: _selectedCategory,
                          onSelect: (i) =>
                              setState(() => _selectedCategory = i),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Room grid ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final room = DummyData.rooms[i];
                        return _StaggerCard(
                          delay: Duration(milliseconds: 60 * i),
                          child: RoomCard(
                            room: room,
                            onTap: () => _openRoom(ctx, room.id),
                          ),
                        );
                      },
                      childCount: DummyData.rooms.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                    child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 40)),
              ],
            ),
          ],
        ),
      ),

      // ── Bottom nav bar ──────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(),
    );
  }

  void _openRoom(BuildContext context, String roomId) {
    final room = DummyData.rooms.firstWhere((r) => r.id == roomId);
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => RoomDetailScreen(room: room),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    ));
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.violetGlow,
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning,',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 12)),
            Text('Designer',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const Spacer(),
        // Search
        _IconBtn(icon: Icons.search_rounded, onTap: () {}),
        const SizedBox(width: 8),
        // Notifications
        Stack(children: [
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
          Positioned(
            top: 8, right: 8,
            child: Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.rose,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppTheme.glass,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.glassBorder, width: 1),
            ),
            child: Icon(icon, size: 20, color: AppTheme.textHigh),
          ),
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1645), Color(0xFF151D3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppTheme.violet.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: AppTheme.violet.withValues(alpha: 0.2),
              blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.violet.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.violet.withValues(alpha: 0.35)),
                  ),
                  child: const Text('✦  AI + AR POWERED',
                      style: TextStyle(
                        color: AppTheme.violetLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      )),
                ),
                const SizedBox(height: 10),
                const Text('Design Your\nDream Home',
                    style: TextStyle(
                      color: AppTheme.textHigh,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.4,
                    )),
                const SizedBox(height: 8),
                const Text(
                  'Point your camera at any room\nand let AI suggest the perfect layout.',
                  style: TextStyle(
                    color: AppTheme.textMid,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // CTA
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration:
                          const Duration(milliseconds: 380),
                      pageBuilder: (_, __, ___) =>
                          const AiChatScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(
                        opacity: CurvedAnimation(
                            parent: anim, curve: Curves.easeOut),
                        child: child,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.violetGlow,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Try Demo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // AR icon
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.violet.withValues(alpha: 0.3),
                  AppTheme.violet.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                  color: AppTheme.violet.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.view_in_ar_rounded,
                size: 44, color: AppTheme.violetLight),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            icon: Icons.home_work_outlined,
            value: '${DummyData.rooms.length}',
            label: 'Rooms',
            gradient: AppTheme.heroGradient,
            onTap: null),
        const SizedBox(width: 10),
        _StatCard(
            icon: Icons.chair_outlined,
            value: '${DummyData.allFurniture.length}',
            label: 'Furniture',
            gradient: AppTheme.cyanGradient,
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 380),
              pageBuilder: (_, __, ___) => const FurnitureScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ))),
        const SizedBox(width: 10),
        _StatCard(
            icon: Icons.savings_outlined,
            value: 'Plan',
            label: 'Budget',
            gradient: const LinearGradient(
                colors: [AppTheme.teal, Color(0xFF059669)]),
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 380),
              pageBuilder: (_, __, ___) =>
                  const BudgetPlannerScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.gradient,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.bg2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.glassBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                  color: AppTheme.textHigh,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                )),
            Text(label,
                style: const TextStyle(
                  color: AppTheme.textMid,
                  fontSize: 11,
                )),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Category filter ───────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelect;
  const _CategoryRow(
      {required this.categories,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? AppTheme.heroGradient : null,
                color: active ? null : AppTheme.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppTheme.glassBorder,
                  width: 1,
                ),
                boxShadow: active ? AppTheme.violetGlow : null,
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  color:
                      active ? Colors.white : AppTheme.textMid,
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
    );
  }
}

// ── Ghost chip ────────────────────────────────────────────────────────────────

class _GhostChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

// ── Style Selector ────────────────────────────────────────────────────────────

class _StyleSelector extends StatelessWidget {
  final List<(IconData, String, Color)> styles;
  final int selected;
  final ValueChanged<int> onSelect;
  const _StyleSelector(
      {required this.styles,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(styles.length, (i) {
        final s = styles[i];
        final active = i == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.only(right: i < styles.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? s.$3.withValues(alpha: 0.15)
                    : AppTheme.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? s.$3.withValues(alpha: 0.5)
                      : AppTheme.glassBorder,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(s.$1,
                      size: 18,
                      color: active ? s.$3 : AppTheme.textLow),
                  const SizedBox(height: 4),
                  Text(s.$2,
                      style: TextStyle(
                        color: active ? s.$3 : AppTheme.textLow,
                        fontSize: 10,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _current = 0;

  static const _items = [
    (Icons.home_rounded,             'Home'),
    (Icons.chair_outlined,           'Furniture'),
    (Icons.view_in_ar_rounded,       'AR'),
    (Icons.favorite_border_rounded,  'Favorites'),
    (Icons.shopping_bag_outlined,    'Cart'),
  ];

  void _onTap(int i, BuildContext ctx) {
    if (i == _current && i == 0) return;
    setState(() => _current = i);
    switch (i) {
      case 1:
        Navigator.of(ctx)
            .push(_slide(const FurnitureScreen()))
            .then((_) => setState(() => _current = 0));
      case 2:
        Navigator.of(ctx)
            .push(_slide(const ARRoomEntry()))
            .then((_) => setState(() => _current = 0));
      case 3:
        Navigator.of(ctx)
            .push(_slide(const FavoritesScreen()))
            .then((_) => setState(() => _current = 0));
      case 4:
        Navigator.of(ctx)
            .push(_slide(const CartScreen()))
            .then((_) => setState(() => _current = 0));
      default:
        break;
    }
  }

  PageRouteBuilder<void> _slide(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD9070B14),
            border: Border(
                top: BorderSide(color: AppTheme.glassBorder, width: 1)),
          ),
          padding: EdgeInsets.only(
            top: 10,
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == _current;
              final item = _items[i];
              return GestureDetector(
                onTap: () => _onTap(i, context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.violet.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1,
                          size: 22,
                          color: active
                              ? AppTheme.violetLight
                              : AppTheme.textLow),
                      const SizedBox(height: 4),
                      Text(item.$2,
                          style: TextStyle(
                            color: active
                                ? AppTheme.violetLight
                                : AppTheme.textLow,
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Ambient glow blob ────────────────────────────────────────────────────────

class _AmbientGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _AmbientGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

// ── Staggered card entrance ───────────────────────────────────────────────────

class _StaggerCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggerCard({required this.child, required this.delay});

  @override
  State<_StaggerCard> createState() => _StaggerCardState();
}

class _StaggerCardState extends State<_StaggerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _opacity =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

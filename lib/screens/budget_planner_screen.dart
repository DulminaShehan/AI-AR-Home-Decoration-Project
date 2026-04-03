import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/dummy_data.dart';
import '../models/furniture.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Budget planner — slider filters furniture by price in real time.
class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() =>
      _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  double _budget = 800;
  static const double _min = 50;
  static const double _max = 5000;

  List<Furniture> get _withinBudget =>
      DummyData.allFurniture.where((f) => f.price <= _budget).toList()
        ..sort((a, b) => b.price.compareTo(a.price));

  List<Furniture> get _overBudget =>
      DummyData.allFurniture.where((f) => f.price > _budget).toList()
        ..sort((a, b) => a.price.compareTo(b.price));

  double get _totalSelected =>
      _withinBudget.fold(0.0, (sum, f) => sum + f.price);

  @override
  Widget build(BuildContext context) {
    final within = _withinBudget;
    final over = _overBudget;

    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: Stack(
        children: [
          Positioned(
            bottom: 80, right: -60,
            child: _Glow(
                color: AppTheme.teal.withValues(alpha: 0.08), size: 240),
          ),

          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),

              // ── App bar ──────────────────────────────────────────────
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
                      child: Text('Budget Planner',
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                    ),
                    // Savings badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.teal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.savings_outlined,
                              size: 13, color: AppTheme.teal),
                          const SizedBox(width: 5),
                          Text(
                            '\$${(_budget - _totalSelected.clamp(0, _budget)).toStringAsFixed(0)} left',
                            style: const TextStyle(
                              color: AppTheme.teal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Budget slider card ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0E1C2E), Color(0xFF0A1520)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppTheme.cyan.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.cyan.withValues(alpha: 0.08),
                          blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your Budget',
                              style: TextStyle(
                                color: AppTheme.textMid,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              )),
                          Text(
                            '\$${_budget.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.cyan,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: AppTheme.cyan,
                          inactiveTrackColor:
                              AppTheme.cyan.withValues(alpha: 0.15),
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10),
                          overlayColor:
                              AppTheme.cyan.withValues(alpha: 0.15),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20),
                        ),
                        child: Slider(
                          value: _budget,
                          min: _min,
                          max: _max,
                          onChanged: (v) =>
                              setState(() => _budget = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${_min.toInt()}',
                              style: const TextStyle(
                                  color: AppTheme.textLow, fontSize: 11)),
                          Text('\$${_max.toInt()}',
                              style: const TextStyle(
                                  color: AppTheme.textLow, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Stats row
                      Row(children: [
                        _BudgetStat(
                          label: 'Items within budget',
                          value: '${within.length}',
                          color: AppTheme.teal,
                        ),
                        const SizedBox(width: 12),
                        _BudgetStat(
                          label: 'Over budget',
                          value: '${over.length}',
                          color: AppTheme.rose,
                        ),
                        const SizedBox(width: 12),
                        _BudgetStat(
                          label: 'Best match',
                          value: within.isNotEmpty
                              ? within.first.formattedPrice
                              : '—',
                          color: AppTheme.amber,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Furniture list ────────────────────────────────────────
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Within budget section
                    if (within.isNotEmpty) ...[
                      SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: _SectionHeader(
                            label: '✓  Within Budget',
                            count: within.length,
                            color: AppTheme.teal,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _BudgetItemRow(
                                furniture: within[i],
                                withinBudget: true),
                            childCount: within.length,
                          ),
                        ),
                      ),
                    ],
                    // Over budget section
                    if (over.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: _SectionHeader(
                            label: '↑  Over Budget',
                            count: over.length,
                            color: AppTheme.rose,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _BudgetItemRow(
                                furniture: over[i],
                                withinBudget: false),
                            childCount: over.length,
                          ),
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                        child: SizedBox(
                            height: MediaQuery.of(context).padding.bottom +
                                20)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textLow,
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _BudgetItemRow extends StatelessWidget {
  final Furniture furniture;
  final bool withinBudget;
  const _BudgetItemRow(
      {required this.furniture, required this.withinBudget});

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: withinBudget
              ? AppTheme.teal.withValues(alpha: 0.15)
              : AppTheme.glassBorder,
        ),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: f.imageUrl,
              width: 60, height: 60,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 60, height: 60,
                color: AppTheme.bg3,
                child: const Icon(Icons.chair_outlined,
                    color: AppTheme.textLow, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name,
                    style: const TextStyle(
                      color: AppTheme.textHigh,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 3),
                Text(f.category,
                    style: const TextStyle(
                      color: AppTheme.textMid,
                      fontSize: 11,
                    )),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 11, color: AppTheme.amber),
                  const SizedBox(width: 3),
                  Text(f.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppTheme.textMid, fontSize: 11,
                      )),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(f.formattedPrice,
                  style: TextStyle(
                    color: withinBudget ? AppTheme.teal : AppTheme.rose,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => AppState.instance.addToCart(f.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: withinBudget
                        ? const LinearGradient(
                            colors: [AppTheme.teal, Color(0xFF059669)])
                        : null,
                    color: withinBudget ? null : AppTheme.bg3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    withinBudget ? 'Add' : 'Over',
                    style: TextStyle(
                      color: withinBudget
                          ? Colors.white
                          : AppTheme.textLow,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

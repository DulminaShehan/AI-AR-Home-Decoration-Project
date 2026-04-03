import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/dummy_data.dart';
import '../models/furniture.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Shopping cart with quantity controls, order summary, and checkout CTA.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoCtrl = TextEditingController();
  bool _promoApplied = false;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: ValueListenableBuilder<Map<String, int>>(
        valueListenable: AppState.instance.cart,
        builder: (_, cartMap, __) {
          final allFurniture = DummyData.allFurniture;
          final cartItems = cartMap.entries
              .map((e) {
                final furniture = allFurniture.firstWhere(
                  (f) => f.id == e.key,
                  orElse: () => const Furniture(
                      id: '', name: '', category: '',
                      imageUrl: '', price: 0),
                );
                return (furniture, e.value); // (Furniture, qty)
              })
              .where((pair) => pair.$1.id.isNotEmpty)
              .toList();

          final subtotal = AppState.instance.cartTotal(allFurniture);
          final discount = _promoApplied ? subtotal * 0.1 : 0.0;
          final delivery = subtotal > 500 ? 0.0 : 29.99;
          final total = subtotal - discount + delivery;

          return Stack(
            children: [
              Positioned(
                bottom: 100, left: -60,
                child: _Glow(
                    color: AppTheme.violet.withValues(alpha: 0.08),
                    size: 220),
              ),

              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 8),

                  // ── App bar ──────────────────────────────────────────
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
                          child: Text('Cart',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium),
                        ),
                        // Item count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.violetGlow,
                          ),
                          child: Text(
                            '${AppState.instance.cartItemCount} items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Content ──────────────────────────────────────────
                  Expanded(
                    child: cartItems.isEmpty
                        ? const _EmptyCart()
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // Cart item list
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (_, i) => _CartItemRow(
                                      furniture: cartItems[i].$1,
                                      qty: cartItems[i].$2,
                                    ),
                                    childCount: cartItems.length,
                                  ),
                                ),
                              ),

                              // Promo code
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 0),
                                sliver: SliverToBoxAdapter(
                                  child: _PromoField(
                                    controller: _promoCtrl,
                                    applied: _promoApplied,
                                    onApply: () {
                                      if (_promoCtrl.text.isNotEmpty) {
                                        setState(
                                            () => _promoApplied = true);
                                        FocusScope.of(context).unfocus();
                                      }
                                    },
                                  ),
                                ),
                              ),

                              // Order summary
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 16, 20, 0),
                                sliver: SliverToBoxAdapter(
                                  child: _OrderSummary(
                                    subtotal: subtotal,
                                    discount: discount,
                                    delivery: delivery,
                                    total: total,
                                  ),
                                ),
                              ),

                              // Checkout button
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 16, 20, 0),
                                sliver: SliverToBoxAdapter(
                                  child: _CheckoutButton(total: total),
                                ),
                              ),

                              SliverToBoxAdapter(
                                child: SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                            24),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Cart item row ─────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  final Furniture furniture;
  final int qty;
  const _CartItemRow({required this.furniture, required this.qty});

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: f.imageUrl,
              width: 70, height: 70,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 70, height: 70,
                color: AppTheme.bg3,
                child: const Icon(Icons.chair_outlined,
                    color: AppTheme.textLow, size: 28),
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
                      color: AppTheme.textMid, fontSize: 11,
                    )),
                const SizedBox(height: 8),
                Text(
                  '\$${(f.price * qty).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Qty controls + delete
          Column(
            children: [
              // Delete
              GestureDetector(
                onTap: () => AppState.instance.removeFromCart(f.id),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: AppTheme.rose.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 14, color: AppTheme.rose),
                ),
              ),
              const SizedBox(height: 8),
              // Qty stepper
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bg3,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          AppState.instance.decreaseCart(f.id),
                      child: Container(
                        width: 28, height: 28,
                        alignment: Alignment.center,
                        child: const Icon(Icons.remove,
                            size: 13, color: AppTheme.textMid),
                      ),
                    ),
                    Container(
                      width: 28, height: 28,
                      alignment: Alignment.center,
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          color: AppTheme.textHigh,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => AppState.instance.addToCart(f.id),
                      child: Container(
                        width: 28, height: 28,
                        alignment: Alignment.center,
                        child: const Icon(Icons.add,
                            size: 13, color: AppTheme.cyan),
                      ),
                    ),
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

// ── Promo field ───────────────────────────────────────────────────────────────

class _PromoField extends StatelessWidget {
  final TextEditingController controller;
  final bool applied;
  final VoidCallback onApply;
  const _PromoField(
      {required this.controller,
      required this.applied,
      required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: applied
                ? AppTheme.teal.withValues(alpha: 0.4)
                : AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Icon(
            applied ? Icons.check_circle_rounded : Icons.local_offer_outlined,
            size: 18,
            color: applied ? AppTheme.teal : AppTheme.textMid,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: applied
                ? const Text('SAVE10 applied — 10% off!',
                    style: TextStyle(
                      color: AppTheme.teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ))
                : TextField(
                    controller: controller,
                    style: const TextStyle(
                        color: AppTheme.textHigh, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(
                          color: AppTheme.textLow, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: applied ? null : onApply,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: applied ? null : AppTheme.cyanGradient,
                color: applied ? AppTheme.bg3 : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                applied ? 'Applied' : 'Apply',
                style: TextStyle(
                  color: applied ? AppTheme.textMid : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order summary ─────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;
  const _OrderSummary({
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppTheme.textMid),
              SizedBox(width: 8),
              Text('Order Summary',
                  style: TextStyle(
                    color: AppTheme.textHigh,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.glassBorder, height: 1),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal',
              value: '\$${subtotal.toStringAsFixed(2)}'),
          if (discount > 0)
            _SummaryRow(
              label: 'Promo discount (10%)',
              value: '− \$${discount.toStringAsFixed(2)}',
              valueColor: AppTheme.teal,
            ),
          _SummaryRow(
            label: delivery == 0 ? 'Delivery (Free)' : 'Delivery',
            value: delivery == 0 ? 'FREE' : '\$${delivery.toStringAsFixed(2)}',
            valueColor: delivery == 0 ? AppTheme.teal : null,
          ),
          if (subtotal > 0 && delivery > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                  'Add \$${(500 - subtotal).toStringAsFixed(0)} more for free delivery',
                  style: const TextStyle(
                      color: AppTheme.cyan, fontSize: 10)),
            ),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.glassBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                    color: AppTheme.textHigh,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMid, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textHigh,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ── Checkout button ───────────────────────────────────────────────────────────

class _CheckoutButton extends StatefulWidget {
  final double total;
  const _CheckoutButton({required this.total});

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96)
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Order placed! Total: \$${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white)),
            ]),
            backgroundColor: AppTheme.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.violetGlow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('\$${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty cart ────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppTheme.violet.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.violet.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppTheme.violetLight, size: 40),
          ),
          const SizedBox(height: 18),
          const Text('Your cart is empty',
              style: TextStyle(
                color: AppTheme.textHigh,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          const Text('Browse furniture and add items\nto start decorating.',
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

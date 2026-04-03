import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/dummy_data.dart';
import '../models/furniture.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';

/// Simulated AR room designer: drag & drop furniture, lighting slider,
/// wall colour picker — all rendered in Flutter (no native AR required).
class RoomDesignScreen extends StatefulWidget {
  final Room room;
  const RoomDesignScreen({super.key, required this.room});

  @override
  State<RoomDesignScreen> createState() => _RoomDesignScreenState();
}

class _RoomDesignScreenState extends State<RoomDesignScreen>
    with SingleTickerProviderStateMixin {
  // ── Canvas state ────────────────────────────────────────────────────────────
  double _brightness = 0.0;      // 0 = bright, 0.55 = dark
  Color _wallTint = Colors.transparent;
  late List<_PlacedItem> _placed;

  static const List<Color> _wallColors = [
    Colors.transparent,
    Color(0x1A7C6FCD), // violet wash
    Color(0x1A22D3EE), // cyan mist
    Color(0x1A10B981), // sage
    Color(0x1AFBBF24), // warm cream
    Color(0x1AF43F5E), // blush rose
    Color(0x1A1E3A5F), // deep navy
  ];

  static const List<(IconData, String)> _palette = [
    (Icons.chair_rounded,        'Sofa'),
    (Icons.table_restaurant_rounded, 'Table'),
    (Icons.local_florist_rounded, 'Plant'),
    (Icons.light_rounded,        'Lamp'),
    (Icons.bed_rounded,          'Bed'),
    (Icons.tv_rounded,           'TV'),
  ];

  late final AnimationController _arPulse;

  @override
  void initState() {
    super.initState();
    _arPulse = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    // Pre-seed a few items on the canvas
    _placed = [
      _PlacedItem(icon: Icons.chair_rounded, label: 'Sofa',
          position: const Offset(60, 90)),
      _PlacedItem(icon: Icons.table_restaurant_rounded, label: 'Table',
          position: const Offset(200, 140)),
      _PlacedItem(icon: Icons.local_florist_rounded, label: 'Plant',
          position: const Offset(280, 60)),
    ];
  }

  @override
  void dispose() {
    _arPulse.dispose();
    super.dispose();
  }

  void _addToCanvas(IconData icon, String label) {
    setState(() {
      _placed.add(_PlacedItem(
        icon: icon,
        label: label,
        position: Offset(
          80 + (_placed.length * 30) % 200,
          80 + (_placed.length * 20) % 100,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final furniture = DummyData.furnitureByRoom[widget.room.id] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bg1,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          // ── App bar overlaying the canvas ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const _GlassBtn(
                      icon: Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.room.name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                // AR badge
                AnimatedBuilder(
                  animation: _arPulse,
                  builder: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cyan
                          .withValues(alpha: 0.08 + _arPulse.value * 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.cyan.withValues(
                              alpha: 0.3 + _arPulse.value * 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar_rounded,
                            size: 13, color: AppTheme.cyan),
                        SizedBox(width: 5),
                        Text('AR SIM',
                            style: TextStyle(
                              color: AppTheme.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Draggable canvas ───────────────────────────────────────────
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (_, constraints) {
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppTheme.cyan.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Room image
                        CachedNetworkImage(
                          imageUrl: widget.room.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppTheme.bg3),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppTheme.bg3),
                        ),

                        // Wall colour tint
                        if (_wallTint != Colors.transparent)
                          Container(color: _wallTint),

                        // Brightness overlay
                        if (_brightness > 0)
                          Container(
                            color: Colors.black
                                .withValues(alpha: _brightness),
                          ),

                        // Draggable furniture items
                        ..._placed.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return _DraggableItem(
                            key: ValueKey('item_$idx'),
                            item: item,
                            canvasSize: Size(
                                constraints.maxWidth - 32,
                                constraints.maxHeight),
                            onMove: (offset) {
                              setState(() =>
                                  _placed[idx].position = offset);
                            },
                            onRemove: () {
                              setState(() => _placed.removeAt(idx));
                            },
                          );
                        }),

                        // Corner brackets
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _CornersPainter(
                                  color: AppTheme.cyan
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ),

                        // Top hint
                        Positioned(
                          top: 12, left: 0, right: 0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg0
                                        .withValues(alpha: 0.55),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppTheme.glassBorder),
                                  ),
                                  child: const Text(
                                    'Drag items to rearrange',
                                    style: TextStyle(
                                      color: AppTheme.textMid,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
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
                );
              },
            ),
          ),

          // ── Control panel ──────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Lighting ──────────────────────────────────────
                  _SectionLabel(
                      icon: Icons.light_mode_rounded, label: 'Lighting'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bg2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_outlined,
                            size: 16, color: AppTheme.amber),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: AppTheme.amber,
                              inactiveTrackColor:
                                  AppTheme.amber.withValues(alpha: 0.15),
                              thumbColor: Colors.white,
                              thumbShape:
                                  const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                              overlayShape:
                                  const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                              overlayColor:
                                  AppTheme.amber.withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: _brightness,
                              min: 0, max: 0.55,
                              onChanged: (v) =>
                                  setState(() => _brightness = v),
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${((1 - _brightness / 0.55) * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Wall colour ───────────────────────────────────
                  _SectionLabel(
                      icon: Icons.format_paint_rounded,
                      label: 'Wall Colour'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _wallColors.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = _wallColors[i];
                        final selected = c == _wallTint;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _wallTint = c),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == 0
                                  ? AppTheme.bg3
                                  : c.withValues(alpha: 1.0),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.cyan
                                    : AppTheme.glassBorder,
                                width: selected ? 2.5 : 1,
                              ),
                              boxShadow: selected
                                  ? AppTheme.cyanGlow
                                  : null,
                            ),
                            child: i == 0
                                ? const Icon(Icons.block_rounded,
                                    size: 18,
                                    color: AppTheme.textLow)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Add furniture ─────────────────────────────────
                  _SectionLabel(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Add Furniture'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _palette.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final item = _palette[i];
                        return GestureDetector(
                          onTap: () =>
                              _addToCanvas(item.$1, item.$2),
                          child: Container(
                            width: 68,
                            decoration: BoxDecoration(
                              color: AppTheme.bg2,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.glassBorder),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(item.$1,
                                    size: 22,
                                    color: AppTheme.violetLight),
                                const SizedBox(height: 4),
                                Text(item.$2,
                                    style: const TextStyle(
                                      color: AppTheme.textMid,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Room furniture carousel ───────────────────────
                  if (furniture.isNotEmpty) ...[
                    _SectionLabel(
                        icon: Icons.auto_awesome_outlined,
                        label: 'Recommended'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: furniture.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = furniture[i];
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 130,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.bg2,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppTheme.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: f.imageUrl,
                                      width: 44, height: 44,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (_, __, ___) =>
                                              Container(
                                        width: 44, height: 44,
                                        color: AppTheme.bg3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(f.name,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppTheme.textHigh,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                            )),
                                        Text(f.formattedPrice,
                                            style: const TextStyle(
                                              color: AppTheme.amber,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placed item model ─────────────────────────────────────────────────────────

class _PlacedItem {
  final IconData icon;
  final String label;
  Offset position;
  _PlacedItem(
      {required this.icon, required this.label, required this.position});
}

// ── Draggable item widget ─────────────────────────────────────────────────────

class _DraggableItem extends StatefulWidget {
  final _PlacedItem item;
  final Size canvasSize;
  final ValueChanged<Offset> onMove;
  final VoidCallback onRemove;

  const _DraggableItem({
    super.key,
    required this.item,
    required this.canvasSize,
    required this.onMove,
    required this.onRemove,
  });

  @override
  State<_DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<_DraggableItem> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return Positioned(
      left: widget.item.position.dx,
      top: widget.item.position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate: (d) {
          final nx = (widget.item.position.dx + d.delta.dx)
              .clamp(0.0, widget.canvasSize.width - size);
          final ny = (widget.item.position.dy + d.delta.dy)
              .clamp(0.0, widget.canvasSize.height - size);
          widget.onMove(Offset(nx, ny));
        },
        onPanEnd: (_) => setState(() => _dragging = false),
        onLongPress: widget.onRemove,
        child: AnimatedScale(
          scale: _dragging ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              color: AppTheme.bg0.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _dragging
                    ? AppTheme.cyan
                    : AppTheme.cyan.withValues(alpha: 0.4),
                width: _dragging ? 1.8 : 1.0,
              ),
              boxShadow: _dragging
                  ? [BoxShadow(
                      color: AppTheme.cyan.withValues(alpha: 0.4),
                      blurRadius: 14)]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.item.icon,
                    size: 22, color: AppTheme.cyan),
                const SizedBox(height: 2),
                Text(widget.item.label,
                    style: const TextStyle(
                      color: AppTheme.textHigh,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Corner brackets painter ───────────────────────────────────────────────────

class _CornersPainter extends CustomPainter {
  final Color color;
  const _CornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const m = 18.0;
    const l = 22.0;
    // TL
    canvas.drawLine(const Offset(m, m + l), const Offset(m, m), paint);
    canvas.drawLine(const Offset(m, m), const Offset(m + l, m), paint);
    // TR
    canvas.drawLine(Offset(size.width - m, m + l),
        Offset(size.width - m, m), paint);
    canvas.drawLine(Offset(size.width - m, m),
        Offset(size.width - m - l, m), paint);
    // BL
    canvas.drawLine(Offset(m, size.height - m - l),
        Offset(m, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m),
        Offset(m + l, size.height - m), paint);
    // BR
    canvas.drawLine(Offset(size.width - m, size.height - m - l),
        Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m),
        Offset(size.width - m - l, size.height - m), paint);
  }

  @override
  bool shouldRepaint(covariant _CornersPainter old) =>
      old.color != color;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.violetLight),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(
            color: AppTheme.textHigh,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          )),
    ]);
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

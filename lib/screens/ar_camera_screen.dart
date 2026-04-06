import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AR Room Designer Screen
//  Full camera preview + tap-to-place furniture + drag + AI suggestions
// ─────────────────────────────────────────────────────────────────────────────

/// Top-level entry: discovers cameras, then shows [ARCameraScreen].
class ARRoomEntry extends StatefulWidget {
  const ARRoomEntry({super.key});

  @override
  State<ARRoomEntry> createState() => _ARRoomEntryState();
}

class _ARRoomEntryState extends State<ARRoomEntry> {
  late final Future<List<CameraDescription>> _camerasFuture;

  @override
  void initState() {
    super.initState();
    _camerasFuture = availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
      future: _camerasFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _LoadingScreen(message: 'Initialising camera…');
        }
        if (snap.hasError || (snap.data?.isEmpty ?? true)) {
          return const _LoadingScreen(message: 'No camera found on this device');
        }
        return ARCameraScreen(cameras: snap.data!);
      },
    );
  }
}

// ── Furniture model ───────────────────────────────────────────────────────────

/// Represents a single piece of furniture placed on the AR canvas.
class FurnitureItem {
  final String id;
  Offset position;
  final FurnitureType type;

  FurnitureItem({
    required this.id,
    required this.position,
    required this.type,
  });
}

/// All supported furniture types.
enum FurnitureType { sofa, chair, table, lamp, plant }

extension FurnitureTypeX on FurnitureType {
  String get label {
    switch (this) {
      case FurnitureType.sofa:  return 'Sofa';
      case FurnitureType.chair: return 'Chair';
      case FurnitureType.table: return 'Table';
      case FurnitureType.lamp:  return 'Lamp';
      case FurnitureType.plant: return 'Plant';
    }
  }

  IconData get icon {
    switch (this) {
      case FurnitureType.sofa:  return Icons.weekend_rounded;
      case FurnitureType.chair: return Icons.chair_rounded;
      case FurnitureType.table: return Icons.table_restaurant_rounded;
      case FurnitureType.lamp:  return Icons.light_rounded;
      case FurnitureType.plant: return Icons.local_florist_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FurnitureType.sofa:  return const Color(0xFF7C6FCD);
      case FurnitureType.chair: return const Color(0xFF22D3EE);
      case FurnitureType.table: return const Color(0xFFFBBF24);
      case FurnitureType.lamp:  return const Color(0xFFF97316);
      case FurnitureType.plant: return const Color(0xFF10B981);
    }
  }

  /// Rendered width on screen.
  double get width {
    switch (this) {
      case FurnitureType.sofa:  return 110;
      case FurnitureType.chair: return 80;
      case FurnitureType.table: return 100;
      case FurnitureType.lamp:  return 55;
      case FurnitureType.plant: return 65;
    }
  }

  /// Rendered height on screen.
  double get height {
    switch (this) {
      case FurnitureType.sofa:  return 70;
      case FurnitureType.chair: return 80;
      case FurnitureType.table: return 65;
      case FurnitureType.lamp:  return 95;
      case FurnitureType.plant: return 85;
    }
  }
}

// ── Main AR screen ────────────────────────────────────────────────────────────

class ARCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ARCameraScreen({super.key, required this.cameras});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen>
    with TickerProviderStateMixin {
  // ── Camera ────────────────────────────────────────────────────────────────
  late final CameraController _cam;
  late final Future<void> _camInit;

  // ── Furniture ─────────────────────────────────────────────────────────────
  final List<FurnitureItem> _items = [];
  int _nextId = 0;
  String? _draggingId;

  // ── Add mode ──────────────────────────────────────────────────────────────
  bool _addMode = false;
  FurnitureType _pendingType = FurnitureType.sofa;

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _showGrid = true;
  String _suggestion = 'Tap "Add Furniture" to begin decorating';
  bool _suggestionVisible = true;

  // ── Entrance animations (scale-bounce per item) ───────────────────────────
  final Map<String, AnimationController> _aCtrls = {};
  final Map<String, Animation<double>> _aAnims = {};

  @override
  void initState() {
    super.initState();
    _cam = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _camInit = _cam.initialize();
  }

  @override
  void dispose() {
    _cam.dispose();
    for (final c in _aCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Place item at position ─────────────────────────────────────────────────

  void _place(Offset pos) {
    final id = 'f${_nextId++}';
    final item = FurnitureItem(id: id, position: pos, type: _pendingType);

    // Scale-bounce entrance animation
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.elasticOut),
    );
    _aCtrls[id] = ctrl;
    _aAnims[id] = anim;

    setState(() {
      _items.add(item);
      _addMode = false;
      _updateSuggestion(item);
    });
    ctrl.forward();
  }

  // ── Remove item ────────────────────────────────────────────────────────────

  void _remove(String id) {
    _aCtrls[id]?.dispose();
    _aCtrls.remove(id);
    _aAnims.remove(id);
    setState(() {
      _items.removeWhere((i) => i.id == id);
      if (_items.isEmpty) {
        _suggestion = 'Tap "Add Furniture" to begin decorating';
      }
    });
  }

  // ── Clear all ──────────────────────────────────────────────────────────────

  void _clearAll() {
    for (final c in _aCtrls.values) {
      c.dispose();
    }
    _aCtrls.clear();
    _aAnims.clear();
    setState(() {
      _items.clear();
      _addMode = false;
      _suggestion = 'Tap "Add Furniture" to begin decorating';
      _suggestionVisible = true;
    });
  }

  // ── AI suggestion logic ────────────────────────────────────────────────────

  void _updateSuggestion(FurnitureItem item) {
    final size = MediaQuery.of(context).size;
    final p = item.position;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dist =
        math.sqrt(math.pow(p.dx - cx, 2) + math.pow(p.dy - cy, 2));

    String msg;
    if (p.dx < size.width * 0.12) {
      msg = '← Move away from the left edge';
    } else if (p.dx > size.width * 0.88) {
      msg = '→ Move away from the right edge';
    } else if (p.dy < size.height * 0.13) {
      msg = '↑ Too high — try moving it down';
    } else if (p.dy > size.height * 0.80) {
      msg = '↓ Too low — try moving it up a bit';
    } else if (dist < size.width * 0.15) {
      msg = '✨ Perfect! Great central placement';
    } else if (dist < size.width * 0.30) {
      msg = '👍 Good position — well balanced';
    } else {
      msg = '💡 Try centering the ${item.type.label} for better balance';
    }

    setState(() {
      _suggestion = msg;
      _suggestionVisible = true;
    });
  }

  // ── Furniture picker sheet ─────────────────────────────────────────────────

  void _openPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FurniturePicker(
        onSelect: (type) {
          Navigator.pop(context);
          setState(() {
            _pendingType = type;
            _addMode = true;
            _suggestion = 'Tap anywhere to place ${type.label}';
            _suggestionVisible = true;
          });
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _camInit,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _LoadingScreen(message: 'Starting camera…');
          }
          if (snap.hasError) {
            return _LoadingScreen(
                message: 'Camera error: ${snap.error}');
          }

          return GestureDetector(
            // Tap-to-place when in add mode
            onTapDown: (d) {
              if (_addMode) _place(d.localPosition);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── 1. Live camera preview ───────────────────────────
                _CameraPreviewFill(controller: _cam),

                // ── 2. AR grid overlay ───────────────────────────────
                if (_showGrid)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _GridPainter(),
                      size: Size.infinite,
                    ),
                  ),

                // ── 3. Placed furniture ──────────────────────────────
                ..._items.map((item) {
                  final anim = _aAnims[item.id]!;
                  return _DraggableFurniture(
                    key: ValueKey(item.id),
                    item: item,
                    scaleAnim: anim,
                    isDragging: _draggingId == item.id,
                    onDragUpdate: (d) {
                      setState(() {
                        final idx =
                            _items.indexWhere((i) => i.id == item.id);
                        if (idx < 0) return;
                        _items[idx].position += d.delta;
                        _draggingId = item.id;
                        _updateSuggestion(_items[idx]);
                      });
                    },
                    onDragEnd: () =>
                        setState(() => _draggingId = null),
                    onLongPress: () => _remove(item.id),
                  );
                }),

                // ── 4. Tap-to-place hint overlay ─────────────────────
                if (_addMode)
                  IgnorePointer(
                    child: Container(
                      color: const Color(0xFF22D3EE).withValues(alpha: 0.07),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFF22D3EE)
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_pendingType.icon,
                                color: _pendingType.color, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Tap to place ${_pendingType.label}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── 5. Top bar ───────────────────────────────────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: _TopBar(
                    itemCount: _items.length,
                    showGrid: _showGrid,
                    onToggleGrid: () =>
                        setState(() => _showGrid = !_showGrid),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),

                // ── 6. AI suggestion bubble ──────────────────────────
                if (_suggestionVisible &&
                    (_items.isNotEmpty || _addMode))
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: bottomPad + 92,
                    child: _SuggestionBubble(message: _suggestion),
                  ),

                // ── 7. Bottom action bar ─────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomBar(
                    itemCount: _items.length,
                    onAdd: _openPicker,
                    onClear: _clearAll,
                    bottomPad: bottomPad,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen camera preview that fills and centres the viewport.
class _CameraPreviewFill extends StatelessWidget {
  final CameraController controller;
  const _CameraPreviewFill({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final camRatio = controller.value.aspectRatio;
    final screenRatio = size.width / size.height;

    double scaleX, scaleY;
    if (screenRatio < camRatio) {
      // Screen is taller → fit height
      scaleY = 1.0;
      scaleX = camRatio / screenRatio;
    } else {
      scaleX = 1.0;
      scaleY = screenRatio / camRatio;
    }

    return OverflowBox(
      maxWidth: size.width * scaleX,
      maxHeight: size.height * scaleY,
      child: CameraPreview(controller),
    );
  }
}

/// Draggable positioned furniture icon widget.
class _DraggableFurniture extends StatelessWidget {
  final FurnitureItem item;
  final Animation<double> scaleAnim;
  final bool isDragging;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onLongPress;

  const _DraggableFurniture({
    super.key,
    required this.item,
    required this.scaleAnim,
    required this.isDragging,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final w = item.type.width;
    final h = item.type.height;
    final color = item.type.color;

    return Positioned(
      left: item.position.dx - w / 2,
      top: item.position.dy - h / 2,
      child: GestureDetector(
        onPanUpdate: onDragUpdate,
        onPanEnd: (_) => onDragEnd(),
        onLongPress: onLongPress,
        child: AnimatedBuilder(
          animation: scaleAnim,
          builder: (_, child) => Transform.scale(
            scale: scaleAnim.value,
            child: child,
          ),
          child: AnimatedScale(
            scale: isDragging ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                // Semi-transparent fill in furniture colour
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDragging
                      ? color
                      : color.withValues(alpha: 0.6),
                  width: isDragging ? 2.0 : 1.2,
                ),
                // Drop shadow
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDragging ? 0.5 : 0.25),
                    blurRadius: isDragging ? 24 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.type.icon,
                      color: color, size: h * 0.42),
                  const SizedBox(height: 4),
                  Text(
                    item.type.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AR-style perspective grid drawn with CustomPainter.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const vLines = 10;
    const hLines = 14;

    // Horizontal lines
    for (var i = 0; i <= hLines; i++) {
      final y = size.height * i / hLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines with slight perspective taper
    for (var i = 0; i <= vLines; i++) {
      final t = i / vLines;
      final xTop = size.width * t;
      // slight convergence toward center-top
      final xBot = size.width * 0.05 + size.width * 0.9 * t;
      canvas.drawLine(Offset(xTop, 0), Offset(xBot, size.height), paint);
    }

    // Corner brackets at center area
    final cx = size.width / 2;
    final cy = size.height / 2;
    const bl = 28.0;
    const bm = 60.0;
    final bracketPaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.45)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // TL
    canvas.drawLine(Offset(cx - bm, cy - bm + bl),
        Offset(cx - bm, cy - bm), bracketPaint);
    canvas.drawLine(Offset(cx - bm, cy - bm),
        Offset(cx - bm + bl, cy - bm), bracketPaint);
    // TR
    canvas.drawLine(Offset(cx + bm, cy - bm + bl),
        Offset(cx + bm, cy - bm), bracketPaint);
    canvas.drawLine(Offset(cx + bm, cy - bm),
        Offset(cx + bm - bl, cy - bm), bracketPaint);
    // BL
    canvas.drawLine(Offset(cx - bm, cy + bm - bl),
        Offset(cx - bm, cy + bm), bracketPaint);
    canvas.drawLine(Offset(cx - bm, cy + bm),
        Offset(cx - bm + bl, cy + bm), bracketPaint);
    // BR
    canvas.drawLine(Offset(cx + bm, cy + bm - bl),
        Offset(cx + bm, cy + bm), bracketPaint);
    canvas.drawLine(Offset(cx + bm, cy + bm),
        Offset(cx + bm - bl, cy + bm), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Glassmorphism top bar.
class _TopBar extends StatelessWidget {
  final int itemCount;
  final bool showGrid;
  final VoidCallback onToggleGrid;
  final VoidCallback onBack;

  const _TopBar({
    required this.itemCount,
    required this.showGrid,
    required this.onToggleGrid,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, MediaQuery.of(context).padding.top + 6, 12, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.black.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back button
          _CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 12),

          // Title + item counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AR Room Designer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (itemCount > 0)
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} placed'
                    '  •  Long-press to remove',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Grid toggle
          _CircleBtn(
            icon: showGrid
                ? Icons.grid_on_rounded
                : Icons.grid_off_rounded,
            onTap: onToggleGrid,
            active: showGrid,
          ),
        ],
      ),
    );
  }
}

/// Floating AI suggestion bubble.
class _SuggestionBubble extends StatelessWidget {
  final String message;
  const _SuggestionBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(message),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 15, color: Color(0xFF22D3EE)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom action bar.
class _BottomBar extends StatelessWidget {
  final int itemCount;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final double bottomPad;

  const _BottomBar({
    required this.itemCount,
    required this.onAdd,
    required this.onClear,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Add furniture
          Expanded(
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C6FCD), Color(0xFF4F6EF7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6FCD).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text('Add Furniture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Clear all
          GestureDetector(
            onTap: itemCount > 0 ? onClear : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: itemCount > 0
                    ? const Color(0xFFF43F5E).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: itemCount > 0
                      ? const Color(0xFFF43F5E).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: itemCount > 0
                        ? const Color(0xFFF43F5E)
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Clear All',
                    style: TextStyle(
                      color: itemCount > 0
                          ? const Color(0xFFF43F5E)
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Furniture picker bottom sheet.
class _FurniturePicker extends StatelessWidget {
  final ValueChanged<FurnitureType> onSelect;
  const _FurniturePicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1220),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Choose Furniture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          // Grid of types
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            physics: const NeverScrollableScrollPhysics(),
            children: FurnitureType.values.map((type) {
              return GestureDetector(
                onTap: () => onSelect(type),
                child: Container(
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: type.color.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(type.icon, color: type.color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: type.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Small circular glass button for top bar.
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _CircleBtn(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF22D3EE).withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? const Color(0xFF22D3EE).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon,
            size: 18,
            color: active
                ? const Color(0xFF22D3EE)
                : Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}

/// Generic loading / error screen.
class _LoadingScreen extends StatelessWidget {
  final String message;
  const _LoadingScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF22D3EE)),
            const SizedBox(height: 20),
            Text(message,
                style: const TextStyle(
                    color: Color(0xFF94A3C4), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

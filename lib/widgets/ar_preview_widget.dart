import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/app_theme.dart';

/// Premium AR viewfinder with multi-layer animations.
class ArPreviewWidget extends StatefulWidget {
  final String roomId;
  const ArPreviewWidget({super.key, required this.roomId});

  @override
  State<ArPreviewWidget> createState() => _ArPreviewWidgetState();
}

class _ArPreviewWidgetState extends State<ArPreviewWidget>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;    // outer ring rotation
  late final AnimationController _ring2Ctrl;   // inner ring (counter-rotate)
  late final AnimationController _scanCtrl;    // scan line
  late final AnimationController _pulseCtrl;   // corner bracket pulse
  late final AnimationController _glowCtrl;    // centre glow breathe

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))..repeat();
    _ring2Ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))..repeat();
    _scanCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _ring2Ctrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 256,
        decoration: BoxDecoration(
          gradient: AppTheme.arBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppTheme.cyan.withValues(alpha: 0.2), width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Dot grid ──────────────────────────────────────────────
            CustomPaint(painter: _DotGridPainter()),

            // ── Outer ring (CW) ───────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _ringCtrl.value * 2 * math.pi,
                  child: SizedBox(
                    width: 176,
                    height: 176,
                    child: CustomPaint(
                      painter: _DashedRingPainter(
                          color: AppTheme.cyan.withValues(alpha: 0.35),
                          dashCount: 20, strokeWidth: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // ── Inner ring (CCW) ──────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _ring2Ctrl,
                builder: (_, __) => Transform.rotate(
                  angle: -_ring2Ctrl.value * 2 * math.pi,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _DashedRingPainter(
                          color: AppTheme.violet.withValues(alpha: 0.4),
                          dashCount: 12, strokeWidth: 1.0),
                    ),
                  ),
                ),
              ),
            ),

            // ── Scan line ─────────────────────────────────────────────
            AnimatedBuilder(
              animation: _scanCtrl,
              builder: (_, __) => Positioned(
                left: 0, right: 0,
                top: _scanCtrl.value * 240,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppTheme.cyan.withValues(alpha: 0.7),
                      Colors.transparent,
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.cyan.withValues(alpha: 0.5),
                          blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ── Corner brackets ───────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => CustomPaint(
                painter: _CornerBracketPainter(
                  color: AppTheme.cyan.withValues(
                      alpha: 0.55 + _pulseCtrl.value * 0.45),
                ),
              ),
            ),

            // ── Centre glow + crosshair ───────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow orb
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cyan.withValues(alpha: 0.08),
                        border: Border.all(
                            color: AppTheme.cyan.withValues(
                                alpha: 0.5 + _glowCtrl.value * 0.4),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.cyan.withValues(
                                  alpha: 0.3 + _glowCtrl.value * 0.3),
                              blurRadius: 16),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cyan.withValues(
                                alpha: 0.8 + _glowCtrl.value * 0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.cyan.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.teal,
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.teal,
                                    blurRadius: 5),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text('AR READY — Tap to activate',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              )),
                        ],
                      ),
                    ),
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

// ── Custom Painters ──────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.cyan.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;
  _DashedRingPainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * math.pi) / dashCount;
    for (var i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.65,
        false,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const m = 22.0;
    const l = 24.0;

    // TL
    canvas.drawLine(const Offset(m, m + l), const Offset(m, m), paint);
    canvas.drawLine(const Offset(m, m), const Offset(m + l, m), paint);
    // TR
    canvas.drawLine(Offset(size.width - m, m + l), Offset(size.width - m, m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(size.width - m - l, m), paint);
    // BL
    canvas.drawLine(Offset(m, size.height - m - l), Offset(m, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m), Offset(m + l, size.height - m), paint);
    // BR
    canvas.drawLine(Offset(size.width - m, size.height - m - l), Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m), Offset(size.width - m - l, size.height - m), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

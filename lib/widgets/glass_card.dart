import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable glassmorphism container.
/// Wrap any child in this to get a frosted-glass card effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? tint;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 16,
    this.tint,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(24);
    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadows ?? AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? AppTheme.glass,
              borderRadius: br,
              border: Border.all(
                color: borderColor ?? AppTheme.glassBorder,
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

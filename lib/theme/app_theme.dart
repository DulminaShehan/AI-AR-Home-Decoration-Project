import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium design system for Smart Home Designer.
/// Built on glassmorphism + deep dark palette.
class AppTheme {
  // ── Core Palette ─────────────────────────────────────────────────────────
  static const Color bg0        = Color(0xFF070B14); // deepest background
  static const Color bg1        = Color(0xFF0D1220); // canvas
  static const Color bg2        = Color(0xFF131929); // card base
  static const Color bg3        = Color(0xFF1A2138); // elevated surface

  // Glass surfaces
  static const Color glass      = Color(0x18FFFFFF); // white 9%
  static const Color glassBorder= Color(0x28FFFFFF); // white 16%
  static const Color glassDeep  = Color(0x22000000); // dark frost

  // Accent spectrum
  static const Color violet     = Color(0xFF7C6FCD); // primary accent
  static const Color violetLight= Color(0xFFAA9EF5); // hover
  static const Color indigo     = Color(0xFF4F6EF7); // secondary
  static const Color cyan       = Color(0xFF22D3EE); // AR / highlight
  static const Color teal       = Color(0xFF14B8A6); // success
  static const Color rose       = Color(0xFFF43F5E); // danger / like
  static const Color amber      = Color(0xFFFBBF24); // price / rating
  static const Color emerald    = Color(0xFF10B981); // badge new

  // Text
  static const Color textHigh   = Color(0xFFF1F5FB); // headings
  static const Color textMid    = Color(0xFF94A3C4); // body
  static const Color textLow    = Color(0xFF4B5675); // captions / dividers

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF7C6FCD), Color(0xFF4F6EF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF4F6EF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xDD070B14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient arBg = LinearGradient(
    colors: [Color(0xFF0D1828), Color(0xFF081020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows / glows ────────────────────────────────────────────────────────
  static List<BoxShadow> violetGlow = [
    BoxShadow(color: violet.withValues(alpha: 0.35),
        blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> cyanGlow = [
    BoxShadow(color: cyan.withValues(alpha: 0.30),
        blurRadius: 20, offset: const Offset(0, 6)),
  ];
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.40),
        blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // ── ThemeData ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg1,
      colorScheme: const ColorScheme.dark(
        primary:   violet,
        secondary: indigo,
        surface:   bg2,
        onPrimary: Colors.white,
        onSurface: textHigh,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 34, fontWeight: FontWeight.w800,
          color: textHigh, letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: textHigh, letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: textHigh, letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: textHigh,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: textMid, height: 1.55,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: textLow, letterSpacing: 1.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textHigh),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: textHigh, letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: bg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: textLow, thickness: 0.5),
    );
  }
}

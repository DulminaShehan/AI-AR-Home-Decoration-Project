import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  Smart Home Designer — AI + AR Home Decoration Assistant
///  Entry point
/// ─────────────────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar so the dark theme bleeds edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bg0,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait-only orientation for consistent layout
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Designer',
      debugShowCheckedModeBanner: false,

      // Apply the centralised dark theme
      theme: AppTheme.darkTheme,

      // Start on the Home screen
      home: const HomeScreen(),
    );
  }
}

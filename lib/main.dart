import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MelanoScanAI());
}

class MelanoScanAI extends StatelessWidget {
  const MelanoScanAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MelanoScan AI',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

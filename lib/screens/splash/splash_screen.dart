import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // =====================================================
            // MELANOSCAN AI LOGO
            // =====================================================
            Container(
              height: 120,
              width: 120,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),

              clipBehavior: Clip.antiAlias,

              child: Image.asset(
                'assets/images/melanoscan_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ).animate().scale(duration: 900.ms).fade(),

            const SizedBox(height: 35),

            // =====================================================
            // APP NAME
            // =====================================================
            Text(
              "MelanoScan AI",

              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: .4),

            const SizedBox(height: 10),

            // =====================================================
            // DESCRIPTION
            // =====================================================
            Text(
              "AI Powered Gingival\nPigmentation Assessment",

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ).animate().fade(delay: 700.ms),

            const SizedBox(height: 80),

            // =====================================================
            // LOADING INDICATOR
            // =====================================================
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

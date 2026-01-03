import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/glitch_logo.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodePalette.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. VB LOGOSU
            const GlitchLogo(size: 150, text: 'VB')
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack, begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 20),

            // 2. VALOBOARD YAZISI (Sonradan gelir)
            Text(
              "VALOBOARD",
              style: GoogleFonts.oswald(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Colors.white,
              ),
            ).animate()
             .fadeIn(delay: 1000.ms, duration: 800.ms)
             .moveY(begin: 20, end: 0, delay: 1000.ms, duration: 800.ms)
             .then(delay: 2000.ms)
             .callback(callback: (_) => context.go('/landing')),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glitch_logo.dart';
import '../../core/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: GlitchLogo(size: 150)),
              const SizedBox(height: 20),
              Text("TACTICAL PLANNING", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 2.0, color: Colors.white54)),
              const Spacer(),
              _MenuCard(title: "TACTICS BOARD", subtitle: "Map Planning & Strategy", icon: Icons.map, color: CodePalette.primary, onTap: () => context.push('/tactics')),
              const SizedBox(height: 16),
              _MenuCard(title: "AGENT STATS", subtitle: "Data & Analytics", icon: Icons.analytics, color: CodePalette.cyanAccent, onTap: () => context.push('/stats')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: CodePalette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24, color: Colors.white)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
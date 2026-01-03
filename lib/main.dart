import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/stats/presentation/stats_screen.dart';
import 'features/tactics/presentation/tactics_board.dart';

void main() {
  runApp(const ProviderScope(child: ValBoardApp()));
}

class ValBoardApp extends StatelessWidget {
  const ValBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ValBoard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF4655),
        scaffoldBackgroundColor: const Color(0xFF0F1923),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "VALBOARD",
                  style: TextStyle(
                    fontFamily: 'Valorant',
                    fontSize: 60,
                    color: Color(0xFFECE8E1),
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4655),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("TACTICAL & STATS COMPANION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                SizedBox(height: isLandscape ? 30 : 80),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMenuCard(
                      context,
                      title: "AGENT STATS",
                      subtitle: "Check MMR, K/D & Matches",
                      icon: Icons.person_search,
                      color: const Color(0xFFFF4655),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: "TACTICS BOARD",
                      subtitle: "Map Planning & Strategy",
                      icon: Icons.map,
                      color: const Color(0xFF0F1923),
                      borderColor: Colors.white24,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TacticsBoard())),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Text("v1.0.5 • Powered by HenrikDev API", style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, Color? borderColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Valorant')),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
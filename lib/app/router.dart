import 'package:go_router/go_router.dart';
import '../features/intro/splash_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/tactics/presentation/tactics_board.dart';
import '../features/stats/presentation/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/landing', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/tactics', builder: (context, state) => const TacticsBoard()),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
  ],
);
import 'package:go_router/go_router.dart';
import '../../features/navigation/presentation/screens/main_nav_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavScreen(),
    ),
  ],
);

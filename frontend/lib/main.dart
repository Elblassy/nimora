import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/story_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/story_screen.dart';
import 'screens/completed_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QissatiApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/story', builder: (context, state) => const StoryScreen()),
    GoRoute(path: '/completed', builder: (context, state) => const CompletedScreen()),
  ],
);

class QissatiApp extends StatelessWidget {
  const QissatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: MaterialApp.router(
        title: 'Qissati',
        theme: AppTheme.theme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

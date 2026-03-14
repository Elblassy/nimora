import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/story_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/story_screen.dart';
import 'screens/completed_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_starry_background.dart';
import 'widgets/app_header.dart';

void main() {
  runApp(const NimoraApp());
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AnimatedStarryBackground(
          child: Column(
            children: [
              const SafeArea(bottom: false, child: AppHeader()),
              Expanded(child: child),
            ],
          ),
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
        GoRoute(path: '/story', builder: (context, state) => const StoryScreen()),
        GoRoute(path: '/completed', builder: (context, state) => const CompletedScreen()),
      ],
    ),
  ],
);

class NimoraApp extends StatelessWidget {
  const NimoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: MaterialApp.router(
        title: 'Nimora',
        theme: AppTheme.theme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

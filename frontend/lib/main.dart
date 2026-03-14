import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;
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

/// All images to precache on startup so animations are smooth.
const _precacheImages = [
  'assets/images/nimora_fox/fox_earch.png',
  'assets/images/nimora_fox/fox_light.png',
  'assets/images/nimora_fox/fox_student.png',
  'assets/images/nimora_fox/fox_study.png',
  'assets/images/nimora_fox/fox_teach.png',
  'assets/images/nimora_fox/fox_think.png',
  'assets/images/adventure/01_forest_journey.jpg',
  'assets/images/adventure/02_space_mission.jpg',
  'assets/images/adventure/03_pirate_island.jpg',
  'assets/images/adventure/04_dinosaur_world.jpg',
  'assets/images/adventure/05_magic_kingdom.jpg',
  'assets/images/adventure/06_ocean_quest.jpg',
  'assets/images/adventure/07_desert_treasure.jpg',
  'assets/images/adventure/08_castle_mystery.jpg',
  'assets/images/look/01_watercolor.jpg',
  'assets/images/look/02_digital.jpg',
  'assets/images/look/03_clay.jpg',
  'assets/images/look/04_3d.jpg',
];

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
        builder: (context, child) {
          return _AssetPreloader(child: child!);
        },
      ),
    );
  }
}

class _AssetPreloader extends StatefulWidget {
  final Widget child;
  const _AssetPreloader({required this.child});

  @override
  State<_AssetPreloader> createState() => _AssetPreloaderState();
}

class _AssetPreloaderState extends State<_AssetPreloader> {
  bool _started = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _precacheAll();
    }
  }

  Future<void> _precacheAll() async {
    await Future.wait([
      for (final path in _precacheImages)
        precacheImage(AssetImage(path), context),
    ]);
    // Remove the HTML splash screen now that all assets are ready
    final splash = web.document.getElementById('splash');
    if (splash != null) {
      splash.classList.add('fade-out');
      await Future.delayed(const Duration(milliseconds: 400));
      splash.remove();
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return widget.child;
  }
}

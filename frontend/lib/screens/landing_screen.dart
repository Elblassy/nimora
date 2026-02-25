import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/story_provider.dart';
import '../widgets/upload_form.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 72,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appNameArabic,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.tagline,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  UploadForm(
                    onSubmit: (childInfo) {
                      final provider = context.read<StoryProvider>();
                      provider.startStory(childInfo);
                      context.go('/story');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

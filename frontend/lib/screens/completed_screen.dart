import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/story_provider.dart';
import '../widgets/story_page_widget.dart';
import '../theme/app_theme.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, _) {
            final pages = provider.pages;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.star, size: 48, color: AppTheme.accent),
                      const SizedBox(height: 8),
                      Text(
                        'The End!',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.primary,
                            ),
                      ),
                      Text(
                        '${provider.childInfo?.name}\'s Story',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return StoryPageWidget(page: pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.reset();
                            context.go('/');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('New Story'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

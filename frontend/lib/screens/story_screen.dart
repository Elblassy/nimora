import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/story_provider.dart';
import '../widgets/story_page_widget.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/loading_magic.dart';
import '../theme/app_theme.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, _) {
            if (provider.state == StoryState.loading) {
              return const LoadingMagic();
            }

            if (provider.state == StoryState.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong.',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          provider.reset();
                          context.go('/');
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.state == StoryState.complete) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/completed');
              });
              return const LoadingMagic(message: 'The End!');
            }

            final currentPage = provider.currentPage;
            if (currentPage == null) {
              return const LoadingMagic();
            }

            return Column(
              children: [
                Expanded(
                  child: StoryPageWidget(page: currentPage),
                ),
                if (currentPage.choices.isNotEmpty)
                  ChoiceButtons(
                    choices: currentPage.choices,
                    onChoiceSelected: (index) {
                      provider.makeChoice(index);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}

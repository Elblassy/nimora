import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChoiceButtons extends StatelessWidget {
  final List<String> choices;
  final Function(int) onChoiceSelected;

  const ChoiceButtons({
    super.key,
    required this.choices,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'What happens next?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...choices.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => onChoiceSelected(index),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.secondary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppTheme.surface,
                  ),
                  child: Text(
                    choice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

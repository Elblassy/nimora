import 'package:flutter/material.dart';
import '../nimora_button.dart';

class WelcomeStep extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.isDesktop, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 40 : 26,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          'Nimora',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 80 : 52,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Text(
          'Your story starts here.',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 22 : 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: isDesktop ? 60 : 40),
        NimoraButton(
          label: 'Start',
          onTap: onNext,
          width: isDesktop ? 340 : 200,
          height: isDesktop ? 130 : 85,
          fontSize: isDesktop ? 80 : 34,
        ),
      ],
    );
  }
}

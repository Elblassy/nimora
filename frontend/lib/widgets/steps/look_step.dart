import 'package:flutter/material.dart';
import '../nimora_button.dart';
import 'carousel_helpers.dart';
import 'step_data.dart';

class LookStep extends StatelessWidget {
  final bool isDesktop;
  final int selectedStyle;
  final ValueChanged<int> onStyleChanged;
  final VoidCallback onNext;

  const LookStep({
    super.key,
    required this.isDesktop,
    required this.selectedStyle,
    required this.onStyleChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final style = styles[selectedStyle];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pick a Look',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 80 : 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 40 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildArrow(
              isDesktop: isDesktop,
              isLeft: true,
              onTap: () => onStyleChanged(
                (selectedStyle - 1 + styles.length) % styles.length,
              ),
            ),
            SizedBox(width: isDesktop ? 60 : 8),
            buildCarouselCard(
              isDesktop: isDesktop,
              cardKey: style.key,
              image: style.image,
              color: style.color,
              label: style.label,
            ),
            SizedBox(width: isDesktop ? 60 : 8),
            buildArrow(
              isDesktop: isDesktop,
              isLeft: false,
              onTap: () => onStyleChanged((selectedStyle + 1) % styles.length),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 40 : 20),
        NimoraButton(
          label: 'Create',
          onTap: onNext,
          width: isDesktop ? 340 : 200,
          height: isDesktop ? 130 : 85,
          fontSize: isDesktop ? 80 : 34,
        ),
        SizedBox(height: isDesktop ? 80 : 40),

      ],
    );
  }
}

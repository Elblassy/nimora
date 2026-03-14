import 'package:flutter/material.dart';
import '../nimora_button.dart';
import 'carousel_helpers.dart';
import 'step_data.dart';

class AdventureStep extends StatelessWidget {
  final bool isDesktop;
  final int selectedCategory;
  final ValueChanged<int> onCategoryChanged;
  final VoidCallback onNext;

  const AdventureStep({
    super.key,
    required this.isDesktop,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cat = categories[selectedCategory];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pick Your Adventure',
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
              onTap: () => onCategoryChanged(
                (selectedCategory - 1 + categories.length) % categories.length,
              ),
            ),
            SizedBox(width: isDesktop ? 60 : 8),
            buildCarouselCard(
              isDesktop: isDesktop,
              cardKey: cat.key,
              image: cat.image,
              color: cat.color,
              label: cat.label,
            ),
            SizedBox(width: isDesktop ? 60 : 8),
            buildArrow(
              isDesktop: isDesktop,
              isLeft: false,
              onTap: () =>
                  onCategoryChanged((selectedCategory + 1) % categories.length),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 40 : 20),
        NimoraButton(
          label: 'Next',
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildArrow({
  required bool isDesktop,
  required bool isLeft,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Transform.flip(
        flipX: isLeft,
        child: SvgPicture.asset(
          'assets/images/components/arrow.svg',
          height: isDesktop ? 80 : 50,
        ),
      ),
    ),
  );
}

Widget buildCarouselCard({
  required bool isDesktop,
  required String cardKey,
  required String image,
  required Color color,
  required String label,
}) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation) =>
        ScaleTransition(scale: animation, child: child),
    child: Container(
      key: ValueKey(cardKey),
      width: isDesktop ? 540 : 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: isDesktop ? 450 : 190,
          width: isDesktop ? 650 : 190,
          child: Stack(
            children: [
              // Image fills the whole card
              Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
              // Gradient fade + text at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: isDesktop ? 100 : 24,
                    bottom: isDesktop ? 16 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isDesktop ? 40 : 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

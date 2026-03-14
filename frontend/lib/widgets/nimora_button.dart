import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable button widget that uses the Nimora SVG button asset as background.
class NimoraButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double fontSize;
  final Widget? icon;
  final bool showShadow;

  const NimoraButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 260,
    this.height = 80,
    this.fontSize = 30,
    this.icon,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: width,
          height: height,
          decoration: showShadow
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.45),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // SVG button background
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/images/components/button.svg',
                  fit: BoxFit.fill,
                ),
              ),
              // Label + optional icon — shifted up slightly for 3D bottom edge
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      SizedBox(width: 8),
                      icon!,
                      SizedBox(width: fontSize * 0.3),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

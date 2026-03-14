import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/story_page.dart';
import '../utils/url_helpers.dart';
import '../utils/icon_map.dart';
import 'nimora_button.dart';

class StoryMobileLayout extends StatelessWidget {
  final StoryPage page;
  final Function(int)? onChoiceSelected;
  final Widget speakerButton;

  const StoryMobileLayout({
    super.key,
    required this.page,
    this.onChoiceSelected,
    required this.speakerButton,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 24).clamp(0.0, 500.0); // 12 padding each side

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Column(
          children: [
            // Image card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: page.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: getFullUrl(page.imageUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: const Color(0xFFE0E0E0),
                                highlightColor: const Color(0xFFF5F5F5),
                                child: Container(color: const Color(0xFFE0E0E0)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFE8E8E8),
                                child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFE8E8E8),
                              child: const Icon(Icons.auto_stories, size: 64, color: Colors.grey),
                            ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Page ${page.pageNumber}',
                          style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: speakerButton,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text + choices card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    page.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2D3436),
                      height: 1.6,
                    ),
                  ),
                  if (page.choices.isNotEmpty && onChoiceSelected != null) ...[
                    const SizedBox(height: 16),
                    ...page.choices.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildChoiceButton(entry.key, entry.value),
                      );
                    }),
                  ] else if (page.isEnding) ...[
                    const SizedBox(height: 16),
                    const Icon(Icons.star, size: 36, color: Color(0xFFFF6B35)),
                    const SizedBox(height: 6),
                    Text(
                      'The End!',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Swipe to read through the pages',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(int index, StoryChoice choice) {
    return NimoraButton(
      label: choice.text,
      onTap: onChoiceSelected != null ? () => onChoiceSelected!(index) : () {},
      height: 100,
      fontSize: 16,
      showShadow: false,
      icon: FaIcon(
        getIconData(choice.icon),
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

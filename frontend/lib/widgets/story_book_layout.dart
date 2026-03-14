import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/story_page.dart';
import '../utils/url_helpers.dart';
import '../utils/icon_map.dart';
import 'nimora_button.dart';

class StoryBookLayout extends StatelessWidget {
  final StoryPage page;
  final Function(int)? onChoiceSelected;
  final Widget speakerButton;

  const StoryBookLayout({
    super.key,
    required this.page,
    this.onChoiceSelected,
    required this.speakerButton,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bookHeight = (size.height * 0.82).clamp(400.0, 650.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1300, maxHeight: bookHeight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Left page: Illustration
                Expanded(
                  flex: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      page.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: getFullUrl(page.imageUrl),
                              fit: BoxFit.cover,
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
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: speakerButton,
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${page.pageNumber}',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Book spine divider
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.brown.shade300.withValues(alpha: 0.4),
                        Colors.brown.shade200.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),

                // Right page: Story text + choices
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFFFFFBF5),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
                            child: Text(
                              page.text,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF2D3436),
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                        if (page.choices.isNotEmpty && onChoiceSelected != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: page.choices.asMap().entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildChoiceButton(entry.key, entry.value),
                                );
                              }).toList(),
                            ),
                          )
                        else if (page.isEnding)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 48, color: Color(0xFFFF6B35)),
                                const SizedBox(height: 8),
                                Text(
                                  'The End!',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Swipe to read through the pages',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                    color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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

  Widget _buildChoiceButton(int index, StoryChoice choice) {
    return NimoraButton(
      label: choice.text,
      onTap: onChoiceSelected != null ? () => onChoiceSelected!(index) : () {},
      height: 90,
      fontSize: 16,
      showShadow: false,
      icon: FaIcon(
        getIconData(choice.icon),
        size: 32,
        color: Colors.white,
      ),
    );
  }
}

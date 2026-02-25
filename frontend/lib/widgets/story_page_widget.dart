import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/story_page.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class StoryPageWidget extends StatelessWidget {
  final StoryPage page;

  const StoryPageWidget({super.key, required this.page});

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${AppConstants.apiBaseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Page ${page.pageNumber}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: page.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _getFullImageUrl(page.imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.storyBackground,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    )
                  : Container(
                      color: AppTheme.storyBackground,
                      child: const Icon(Icons.auto_stories, size: 64),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.storyBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              page.text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

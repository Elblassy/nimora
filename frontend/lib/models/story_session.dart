import 'story_page.dart';

class StorySession {
  final String sessionId;
  final List<StoryPage> pages;
  final bool isComplete;
  final String storyTitle;

  StorySession({
    required this.sessionId,
    this.pages = const [],
    this.isComplete = false,
    this.storyTitle = '',
  });
}

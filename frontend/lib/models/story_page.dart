class StoryChoice {
  final String text;
  final String icon;

  StoryChoice({required this.text, this.icon = 'compass'});

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      text: json['text'] as String? ?? '',
      icon: json['icon'] as String? ?? 'compass',
    );
  }
}

class StoryPage {
  final int pageNumber;
  final String text;
  final String imageUrl;
  final String audioUrl;
  final List<StoryChoice> choices;
  final bool isEnding;

  StoryPage({
    required this.pageNumber,
    required this.text,
    required this.imageUrl,
    this.audioUrl = '',
    this.choices = const [],
    this.isEnding = false,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      pageNumber: json['page_number'] as int,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String,
      audioUrl: json['audio_url'] as String? ?? '',
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) => StoryChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEnding: json['is_ending'] as bool? ?? false,
    );
  }
}

class StoryPage {
  final int pageNumber;
  final String text;
  final String imageUrl;
  final List<String> choices;
  final bool isEnding;

  StoryPage({
    required this.pageNumber,
    required this.text,
    required this.imageUrl,
    this.choices = const [],
    this.isEnding = false,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      pageNumber: json['page_number'] as int,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String,
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isEnding: json['is_ending'] as bool? ?? false,
    );
  }
}

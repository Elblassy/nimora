import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/story_page.dart';
import '../utils/constants.dart';

class ApiService {
  static const String _baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> startStory({
    required String childName,
    required int childAge,
    required String theme,
    required String style,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/story/start');
    final request = http.MultipartRequest('POST', uri)
      ..fields['child_name'] = childName
      ..fields['child_age'] = childAge.toString()
      ..fields['theme'] = theme
      ..fields['style'] = style;
    if (photoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: photoFileName ?? 'photo.png',
      ));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('Failed to start story: ${response.body}');
    }
    final data = json.decode(response.body);
    return {
      'session_id': data['session_id'] as String,
      'page': StoryPage.fromJson(data['page']),
      'story_title': data['story_title'] as String? ?? '',
    };
  }

  Future<Map<String, dynamic>> makeChoice({
    required String sessionId,
    required int choiceIndex,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/story/$sessionId/choose');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'choice_index': choiceIndex}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to make choice: ${response.body}');
    }
    final data = json.decode(response.body);
    return {
      'page': StoryPage.fromJson(data['page']),
      'is_complete': data['is_complete'] as bool,
    };
  }

  /// Poll for audio URL (background-generated on backend)
  Future<String> pollAudioUrl({
    required String sessionId,
    required int pageNumber,
    int maxRetries = 15,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/story/$sessionId/audio/$pageNumber'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final url = data['audio_url'] as String? ?? '';
          if (url.isNotEmpty) return url;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
    return '';
  }

  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

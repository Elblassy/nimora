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
    required Uint8List photoBytes,
    required String photoFileName,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/story/start');
    final request = http.MultipartRequest('POST', uri)
      ..fields['child_name'] = childName
      ..fields['child_age'] = childAge.toString()
      ..fields['theme'] = theme
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: photoFileName,
      ));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('Failed to start story: ${response.body}');
    }
    final data = json.decode(response.body);
    return {
      'session_id': data['session_id'] as String,
      'page': StoryPage.fromJson(data['page']),
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

  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

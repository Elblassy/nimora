import 'package:flutter/material.dart';
import '../models/child_info.dart';
import '../models/story_page.dart';
import '../models/story_session.dart';
import '../services/api_service.dart';

enum StoryState { idle, loading, ready, error, complete }

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  StoryState _state = StoryState.idle;
  StorySession? _session;
  String _errorMessage = '';
  ChildInfo? _childInfo;

  StoryState get state => _state;
  StorySession? get session => _session;
  String get errorMessage => _errorMessage;
  ChildInfo? get childInfo => _childInfo;
  List<StoryPage> get pages => _session?.pages ?? [];
  StoryPage? get currentPage => pages.isNotEmpty ? pages.last : null;
  bool get isComplete => _session?.isComplete ?? false;

  Future<void> startStory(ChildInfo childInfo) async {
    _childInfo = childInfo;
    _state = StoryState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _apiService.startStory(
        childName: childInfo.name,
        childAge: childInfo.age,
        theme: childInfo.theme,
        photoBytes: childInfo.photoBytes!,
        photoFileName: childInfo.photoFileName ?? 'photo.png',
      );

      final page = result['page'] as StoryPage;
      _session = StorySession(
        sessionId: result['session_id'] as String,
        pages: [page],
      );
      _state = StoryState.ready;
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> makeChoice(int choiceIndex) async {
    if (_session == null) return;

    _state = StoryState.loading;
    notifyListeners();

    try {
      final result = await _apiService.makeChoice(
        sessionId: _session!.sessionId,
        choiceIndex: choiceIndex,
      );

      final page = result['page'] as StoryPage;
      final isComplete = result['is_complete'] as bool;

      _session = StorySession(
        sessionId: _session!.sessionId,
        pages: [..._session!.pages, page],
        isComplete: isComplete,
      );

      _state = isComplete ? StoryState.complete : StoryState.ready;
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _state = StoryState.idle;
    _session = null;
    _errorMessage = '';
    _childInfo = null;
    notifyListeners();
  }
}

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
  String get storyTitle => _session?.storyTitle ?? '';

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
        style: childInfo.style,
        photoBytes: childInfo.photoBytes,
        photoFileName: childInfo.photoFileName,
      );

      final page = result['page'] as StoryPage;
      final sessionId = result['session_id'] as String;
      final storyTitle = result['story_title'] as String? ?? '';
      _session = StorySession(
        sessionId: sessionId,
        pages: [page],
        storyTitle: storyTitle,
      );
      _state = StoryState.ready;
      notifyListeners();

      // Poll for audio in background
      _pollAudio(sessionId, page.pageNumber);
      return;
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Track last failed choice for retry
  int? _lastFailedChoiceIndex;

  /// Retry the last failed action (start or choice)
  Future<void> retry() async {
    if (_session == null && _childInfo != null) {
      // Failed during startStory — retry it
      await startStory(_childInfo!);
    } else if (_lastFailedChoiceIndex != null) {
      // Failed during makeChoice — retry same choice
      await makeChoice(_lastFailedChoiceIndex!);
    }
  }

  Future<void> makeChoice(int choiceIndex) async {
    if (_session == null) return;

    _lastFailedChoiceIndex = choiceIndex;
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
        storyTitle: _session!.storyTitle,
      );

      _lastFailedChoiceIndex = null;  // clear on success
      _state = isComplete ? StoryState.complete : StoryState.ready;
      notifyListeners();

      // Poll for audio in background (including the final page)
      _pollAudio(_session!.sessionId, page.pageNumber);
      return;
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> _pollAudio(String sessionId, int pageNumber) async {
    final audioUrl = await _apiService.pollAudioUrl(
      sessionId: sessionId,
      pageNumber: pageNumber,
    );
    if (audioUrl.isNotEmpty && _session != null) {
      final updatedPages = _session!.pages.map((p) {
        if (p.pageNumber == pageNumber) {
          return StoryPage(
            pageNumber: p.pageNumber,
            text: p.text,
            imageUrl: p.imageUrl,
            audioUrl: audioUrl,
            choices: p.choices,
            isEnding: p.isEnding,
          );
        }
        return p;
      }).toList();
      _session = StorySession(
        sessionId: _session!.sessionId,
        pages: updatedPages,
        isComplete: _session!.isComplete,
        storyTitle: _session!.storyTitle,
      );
      notifyListeners();
    }
  }

  void reset() {
    _state = StoryState.idle;
    _session = null;
    _errorMessage = '';
    _childInfo = null;
    notifyListeners();
  }
}

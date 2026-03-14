import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import '../utils/url_helpers.dart';

class WebAudioPlayer {
  web.HTMLAudioElement? _audio;
  bool _isPlaying = false;
  bool _isLoading = false;

  final VoidCallback onStateChanged;

  WebAudioPlayer({required this.onStateChanged});

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  void play(String url) {
    if (url.isEmpty) return;

    if (_isPlaying) {
      _audio?.pause();
      _isPlaying = false;
      onStateChanged();
      return;
    }

    final fullUrl = getFullUrl(url);

    if (_audio == null) {
      _isLoading = true;
      onStateChanged();
      _audio = web.HTMLAudioElement()..src = fullUrl;
      _audio!.onCanPlayThrough.listen((_) {
        _isLoading = false;
        onStateChanged();
      });
      _audio!.onEnded.listen((_) {
        _isPlaying = false;
        onStateChanged();
      });
      _audio!.onError.listen((_) {
        _isLoading = false;
        _isPlaying = false;
        onStateChanged();
      });
    }

    _audio!.play();
    _isPlaying = true;
    onStateChanged();
  }

  void stop() {
    _audio?.pause();
    _audio = null;
    _isPlaying = false;
    _isLoading = false;
  }

  void dispose() {
    stop();
  }
}

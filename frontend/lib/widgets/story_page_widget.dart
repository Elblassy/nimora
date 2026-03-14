import 'package:flutter/material.dart';
import '../models/story_page.dart';
import '../services/audio_service.dart';
import 'story_book_layout.dart';
import 'story_mobile_layout.dart';

class StoryPageWidget extends StatefulWidget {
  final StoryPage page;
  final Function(int)? onChoiceSelected;

  const StoryPageWidget({
    super.key,
    required this.page,
    this.onChoiceSelected,
  });

  @override
  State<StoryPageWidget> createState() => _StoryPageWidgetState();
}

class _StoryPageWidgetState extends State<StoryPageWidget> {
  late final WebAudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = WebAudioPlayer(onStateChanged: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(StoryPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.audioUrl != widget.page.audioUrl) {
      _player.stop();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildSpeakerButton(bool isDesktop) {
    final iconSize = isDesktop ? 24.0 : 18.0;
    final padding = isDesktop ? 10.0 : 8.0;

    return GestureDetector(
      onTap: widget.page.audioUrl.isNotEmpty
          ? () => _player.play(widget.page.audioUrl)
          : null,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: _player.isPlaying
              ? const Color(0xFFFF6B35).withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: (_player.isLoading || widget.page.audioUrl.isEmpty)
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                _player.isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: iconSize,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    if (isDesktop) {
      return Center(
        child: StoryBookLayout(
          page: widget.page,
          onChoiceSelected: widget.onChoiceSelected,
          speakerButton: _buildSpeakerButton(true),
        ),
      );
    }
    return StoryMobileLayout(
      page: widget.page,
      onChoiceSelected: widget.onChoiceSelected,
      speakerButton: _buildSpeakerButton(false),
    );
  }
}

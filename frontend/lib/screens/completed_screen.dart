import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/story_provider.dart';
import '../widgets/story_page_widget.dart';
import '../theme/app_theme.dart';
import '../services/pdf_service.dart';
import '../utils/web_download.dart';
import '../widgets/nimora_button.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  bool _isGeneratingPdf = false;
  String _pdfStatus = '';

  Future<void> _startPdfDownload(StoryProvider provider) async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
      _pdfStatus = 'Fetching images...';
    });

    // Yield a frame so the overlay paints before heavy work starts
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      final pdfService = PdfService();

      final imageBytes = await pdfService.fetchAllImages(provider.pages);

      if (!mounted) return;
      setState(() => _pdfStatus = 'Building PDF...');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final bytes = await pdfService.buildPdf(
        pages: provider.pages,
        imageBytes: imageBytes,
        childName: provider.childInfo?.name ?? 'Child',
        storyTitle: provider.storyTitle,
      );

      if (!mounted) return;
      setState(() => _pdfStatus = 'Downloading...');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final filename =
          '${provider.childInfo?.name ?? 'story'}_nimora_story.pdf';
      downloadFile(bytes, filename);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
          _pdfStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<StoryProvider>(
        builder: (context, provider, _) {
          final pages = provider.pages;

          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      clipBehavior: Clip.none,
                      scrollBehavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: PointerDeviceKind.values.toSet(),
                      ),
                      controller: PageController(initialPage: pages.length - 1),
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return StoryPageWidget(page: pages[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NimoraButton(
                          label: 'Download PDF',
                          onTap: () => _startPdfDownload(provider),
                          width: isDesktop ? 340 : 170,
                          height: isDesktop ? 130 : 65,
                          fontSize: isDesktop ? 34 : 16,
                          icon: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: isDesktop ? 34 : 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        NimoraButton(
                          label: 'New Story',
                          onTap: () {
                            provider.reset();
                            context.go('/');
                          },
                          width: isDesktop ? 340 : 170,
                          height: isDesktop ? 130 : 65,
                          fontSize: isDesktop ? 34 : 16,
                          icon: Icon(
                            Icons.auto_stories,
                            color: Colors.white,
                            size: isDesktop ? 34 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // PDF loading overlay
              if (_isGeneratingPdf)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                      decoration: BoxDecoration(
                        color: AppTheme.skyDeep,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _pdfStatus,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Creating your storybook...',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

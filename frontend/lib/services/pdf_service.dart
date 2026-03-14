import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/story_page.dart';
import '../utils/url_helpers.dart';

class PdfService {
  pw.Font? _fredokaRegular;
  pw.Font? _fredokaSemiBold;
  Uint8List? _titleBgBytes;

  Future<void> _loadAssets() async {
    if (_fredokaRegular != null) return;
    final regularData = await rootBundle.load('assets/fonts/Fredoka-Regular.ttf');
    final semiBoldData = await rootBundle.load('assets/fonts/Fredoka-SemiBold.ttf');
    _fredokaRegular = pw.Font.ttf(regularData);
    _fredokaSemiBold = pw.Font.ttf(semiBoldData);

    final bgData = await rootBundle.load('assets/images/components/pdf_bg.png');
    _titleBgBytes = bgData.buffer.asUint8List();
  }

  pw.TextStyle _style({
    double fontSize = 14,
    PdfColor color = const PdfColor.fromInt(0xFF2D3436),
    bool bold = false,
    bool italic = false,
    double? lineSpacing,
  }) {
    return pw.TextStyle(
      font: bold ? _fredokaSemiBold : _fredokaRegular,
      fontBold: _fredokaSemiBold,
      fontSize: fontSize,
      color: color,
      fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
      lineSpacing: lineSpacing,
    );
  }

  // Nimora brand colors
  static const _coral = PdfColor.fromInt(0xFFFF6B35);
  static const _cream = PdfColor.fromInt(0xFFFFFBF5);
  static const _textDark = PdfColor.fromInt(0xFF2D3436);
  static const _textMuted = PdfColor.fromInt(0xFFB0B8CC);
  static const _white = PdfColor.fromInt(0xFFFFFFFF);

  /// Phase 1: Fetch all images concurrently (async, non-blocking).
  Future<List<Uint8List?>> fetchAllImages(List<StoryPage> pages) async {
    final futures = pages.map((page) => _fetchImage(page.imageUrl));
    return Future.wait(futures);
  }

  /// Phase 2: Build the PDF with UI yields between pages so the spinner stays alive.
  Future<Uint8List> buildPdf({
    required List<StoryPage> pages,
    required List<Uint8List?> imageBytes,
    required String childName,
    String storyTitle = '',
  }) async {
    await _loadAssets();
    final pdf = pw.Document();
    final title = storyTitle.isNotEmpty ? storyTitle : '$childName\'s Adventure';

    pdf.addPage(_buildTitlePage(childName, pages.length, title));
    await Future<void>.delayed(Duration.zero);

    for (var i = 0; i < pages.length; i++) {
      pdf.addPage(_buildStoryPage(pages[i], imageBytes[i], childName, pages.length, title));
      await Future<void>.delayed(Duration.zero);
    }

    final bytes = pdf.save();
    await Future<void>.delayed(Duration.zero);
    return bytes;
  }

  pw.Page _buildTitlePage(String childName, int totalPages, String storyTitle) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Stack(
        children: [
          // Background image
          pw.Positioned.fill(
            child: pw.Image(
              pw.MemoryImage(_titleBgBytes!),
              fit: pw.BoxFit.cover,
            ),
          ),
          // Content overlay
          pw.Positioned.fill(
            child: pw.Padding(
          padding: const pw.EdgeInsets.all(60),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // Stars decoration — white
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('*', style: _style(fontSize: 24, color: _white)),
                  pw.SizedBox(width: 16),
                  pw.Text('*', style: _style(fontSize: 16, color: _white)),
                  pw.SizedBox(width: 24),
                  pw.Text('*', style: _style(fontSize: 20, color: _white)),
                ],
              ),
              pw.SizedBox(height: 40),

              // Nimora title
              pw.Text(
                'Nimora',
                style: _style(fontSize: 64, bold: true, color: _coral),
              ),
              pw.SizedBox(height: 8),
              // Line below Nimora — white
              pw.Container(width: 120, height: 3, color: _white),
              pw.SizedBox(height: 24),

              // Story title
              pw.Text(
                storyTitle,
                style: _style(fontSize: 32, bold: true, color: _white),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'A personalized interactive story',
                style: _style(fontSize: 16, color: _textMuted),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '$totalPages magical pages',
                style: _style(fontSize: 14, color: _textMuted),
              ),

              pw.SizedBox(height: 60),

              // Stars decoration bottom — white
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('*', style: _style(fontSize: 16, color: _white)),
                  pw.SizedBox(width: 20),
                  pw.Text('*', style: _style(fontSize: 24, color: _white)),
                  pw.SizedBox(width: 20),
                  pw.Text('*', style: _style(fontSize: 16, color: _white)),
                ],
              ),
              pw.SizedBox(height: 40),
              // "Every child..." — white
              pw.Text(
                'Every child is the hero of their story',
                style: _style(fontSize: 12, bold: true, color: _white, italic: true),
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  pw.Page _buildStoryPage(
    StoryPage page,
    Uint8List? imgData,
    String childName,
    int totalPages,
    String storyTitle,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Column(
        children: [
          // Image with padding and rounded corners
          if (imgData != null)
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: pw.ClipRRect(
                horizontalRadius: 16,
                verticalRadius: 16,
                child: pw.Image(
                  pw.MemoryImage(imgData),
                  fit: pw.BoxFit.cover,
                  width: PdfPageFormat.a4.width - 48,
                  height: PdfPageFormat.a4.width - 48,
                ),
              ),
            )
          else
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: pw.ClipRRect(
                horizontalRadius: 16,
                verticalRadius: 16,
                child: pw.Container(
                  width: PdfPageFormat.a4.width - 48,
                  height: PdfPageFormat.a4.width - 48,
                  color: PdfColor.fromInt(0xFFE8E8E8),
                ),
              ),
            ),

          // Story text area
          pw.Expanded(
            child: pw.Container(
              width: double.infinity,
              color: _cream,
              padding: const pw.EdgeInsets.fromLTRB(48, 12, 48, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Story text
                  pw.Text(
                    page.text,
                    style: _style(fontSize: 14, color: _textDark, lineSpacing: 5),
                  ),

                  pw.Spacer(),

                  // Ending section
                  if (page.isEnding) ...[
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text('*', style: _style(fontSize: 12, color: _textDark)),
                              pw.SizedBox(width: 10),
                              pw.Text(
                                'The End',
                                style: _style(fontSize: 22, bold: true, color: _coral),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Text('*', style: _style(fontSize: 12, color: _textDark)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'A story created for $childName',
                            style: _style(fontSize: 10, color: _textDark, italic: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Footer — always visible, outside Expanded
          pw.Container(
            width: double.infinity,
            color: _cream,
            padding: const pw.EdgeInsets.fromLTRB(48, 0, 48, 12),
            child: pw.Column(
              children: [
                pw.Divider(color: PdfColor.fromInt(0xFFE0E0E0), thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'Nimora',
                      style: _style(fontSize: 9, bold: true, color: _coral),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      storyTitle,
                      style: _style(fontSize: 9, color: PdfColor.fromInt(0xFF9E9E9E)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    '${page.pageNumber} / $totalPages',
                    style: _style(fontSize: 8, color: PdfColor.fromInt(0xFF9E9E9E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _fetchImage(String url) async {
    if (url.isEmpty) return null;
    try {
      final fullUrl = getFullUrl(url);
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('image/') ||
            response.bodyBytes.length > 5000) {
          return _compressToJpeg(response.bodyBytes);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Compress PNG to JPEG at quality 85 — visually identical, ~5-10x smaller.
  Uint8List _compressToJpeg(Uint8List rawBytes) {
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) return rawBytes;
      return Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
    } catch (_) {
      return rawBytes;
    }
  }
}

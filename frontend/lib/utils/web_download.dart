import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadFile(Uint8List bytes, String filename) {
  final base64 = base64Encode(bytes);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = 'data:application/pdf;base64,$base64'
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor as web.Node);
  anchor.click();
  anchor.remove();
}

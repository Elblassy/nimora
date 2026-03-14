import 'dart:typed_data';

class ChildInfo {
  final String name;
  final int age;
  final Uint8List? photoBytes;
  final String? photoFileName;
  final String theme;
  final String style;

  ChildInfo({
    required this.name,
    required this.age,
    this.photoBytes,
    this.photoFileName,
    this.theme = 'forest_journey',
    this.style = 'watercolor',
  });
}

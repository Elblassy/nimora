import 'dart:typed_data';

class ChildInfo {
  final String name;
  final int age;
  final Uint8List? photoBytes;
  final String? photoFileName;
  final String theme;

  ChildInfo({
    required this.name,
    required this.age,
    this.photoBytes,
    this.photoFileName,
    this.theme = 'adventure',
  });
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhotoPreview extends StatelessWidget {
  final Uint8List? photoBytes;
  final VoidCallback onTap;
  final double size;

  const PhotoPreview({
    super.key,
    this.photoBytes,
    required this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 3),
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: photoBytes != null
              ? Image.memory(photoBytes!, fit: BoxFit.cover)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 36, color: AppTheme.primary),
                    SizedBox(height: 4),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

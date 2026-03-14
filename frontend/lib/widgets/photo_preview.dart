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
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x22FFFFFF),
                border: Border.all(
                  color: photoBytes != null
                      ? AppTheme.secondary
                      : AppTheme.primary.withValues(alpha: 0.3),
                  width: photoBytes != null ? 3 : 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                boxShadow: photoBytes != null
                    ? [
                        BoxShadow(
                          color: AppTheme.secondary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: photoBytes != null
                    ? Image.memory(photoBytes!, fit: BoxFit.cover, width: size, height: size)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: size * 0.3,
                            color: AppTheme.primary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              photoBytes != null ? 'Change Photo' : 'Add Photo (Optional)',
              style: TextStyle(
                fontSize: 12,
                color: photoBytes != null ? AppTheme.secondary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

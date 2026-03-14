import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../nimora_button.dart';

class UploadStep extends StatelessWidget {
  final bool isDesktop;
  final Uint8List? photoBytes;
  final VoidCallback onPickPhoto;
  final VoidCallback onNext;

  const UploadStep({
    super.key,
    required this.isDesktop,
    required this.photoBytes,
    required this.onPickPhoto,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upload Your Photo',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 80 : 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 40 : 24),
        GestureDetector(
          onTap: onPickPhoto,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                width: isDesktop ? 250 : 150,
                height: isDesktop ? 250 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: photoBytes != null
                    ? ClipOval(
                        child: Image.memory(
                          photoBytes!,
                          fit: BoxFit.cover,
                          width: isDesktop ? 250 : 150,
                          height: isDesktop ? 250 : 150,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            size: isDesktop ? 140 : 44,
                            color: const Color(0xFFFC6929),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: isDesktop ? 32 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 40 : 24),
        NimoraButton(
          label: 'Next',
          onTap: onNext,
          width: isDesktop ? 340 : 200,
          height: isDesktop ? 130 : 85,
          fontSize: isDesktop ? 80 : 34,
        ),
        SizedBox(height: isDesktop ? 20 : 12),
        Text(
          'We never save your photo.',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 32 : 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: isDesktop ? 0 : 60),
      ],
    );
  }
}

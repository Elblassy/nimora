import 'package:flutter/material.dart';
import '../nimora_button.dart';

class NameStep extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController nameController;
  final VoidCallback onNext;

  const NameStep({
    super.key,
    required this.isDesktop,
    required this.nameController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Name Your Hero',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isDesktop ? 80 : 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 100 : 30),
        SizedBox(
          width: isDesktop ? 450 : 300,
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isDesktop ? 60 : 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Enter name',
              hintStyle: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isDesktop ? 60 : 22,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              filled: false,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(80),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: isDesktop ? 20 : 16,
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        SizedBox(height: isDesktop ? 100 : 30),
        NimoraButton(
          label: 'Next',
          onTap: onNext,
          width: isDesktop ? 340 : 200,
          height: isDesktop ? 130 : 85,
          fontSize: isDesktop ? 80 : 34,
        ),
      ],
    );
  }
}

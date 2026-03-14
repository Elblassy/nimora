import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: isDesktop ? 14 : 10,
      ),
      child: Row(
        children: [
          // Logo — fox + "Nimora" + sparkles
          GestureDetector(
            onTap: () => context.go('/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SvgPicture.asset(
                width: 250,
                'assets/images/logo/nimora_logo.svg',
                semanticsLabel: 'Nimora Logo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

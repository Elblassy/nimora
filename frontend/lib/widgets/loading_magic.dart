import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingMagic extends StatefulWidget {
  final String message;

  const LoadingMagic({
    super.key,
    this.message = 'Get Ready...',
  });

  @override
  State<LoadingMagic> createState() => _LoadingMagicState();
}

class _LoadingMagicState extends State<LoadingMagic>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _starController;
  late AnimationController _pulseController;

  // Star positions: [angle, distance, svgIndex(1-3), size, alphaBase]
  static final _stars = [
    _StarInfo(angle: -60, dist: 130, svg: 1, size: 18, alpha: 0.9),
    _StarInfo(angle: -20, dist: 110, svg: 2, size: 12, alpha: 0.5),
    _StarInfo(angle: 20, dist: 140, svg: 1, size: 28, alpha: 0.7),
    _StarInfo(angle: 70, dist: 120, svg: 2, size: 20, alpha: 0.6),
    _StarInfo(angle: 110, dist: 150, svg: 1, size: 16, alpha: 0.8),
    _StarInfo(angle: 160, dist: 125, svg: 2, size: 24, alpha: 0.5),
    _StarInfo(angle: 200, dist: 145, svg: 1, size: 30, alpha: 0.7),
    _StarInfo(angle: 250, dist: 115, svg: 2, size: 14, alpha: 0.6),
    _StarInfo(angle: 300, dist: 135, svg: 3, size: 8, alpha: 0.4),
    _StarInfo(angle: 340, dist: 105, svg: 3, size: 6, alpha: 0.3),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _starController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;
    final centerSize = isDesktop ? 100.0 : 70.0;
    final ringSize = isDesktop ? 160.0 : 100.0;
    final areaSize = isDesktop ? 360.0 : 260.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: areaSize,
            height: areaSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated stars
                ..._buildStars(isDesktop),

                // Spinning white arc ring
                AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinController.value * 2 * pi,
                      child: CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _ArcPainter(),
                      ),
                    );
                  },
                ),

                // Fox face center
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + _pulseController.value * 0.05;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: SvgPicture.asset(
                    'assets/images/components/nimora_face.svg',
                    width: centerSize,
                    height: centerSize,
                  ),
                ),
              ],
            ),
          ),


          // "Get Ready..." text
          Text(
            widget.message,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isDesktop ? 40 : 24,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(bool isDesktop) {
    final scale = isDesktop ? 1.0 : 0.7;
    return List.generate(_stars.length, (i) {
      final star = _stars[i];
      return AnimatedBuilder(
        animation: _starController,
        builder: (context, child) {
          // Each star twinkles at its own phase
          final twinkle = sin(_starController.value * 2 * pi + i * 1.3);
          final opacity = (star.alpha + twinkle * 0.3).clamp(0.1, 1.0);
          final starScale = (1.0 + twinkle * 0.15) * scale;

          final rad = star.angle * pi / 180;
          final dist = star.dist * scale;
          final dx = cos(rad) * dist;
          final dy = sin(rad) * dist;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: starScale,
              child: Opacity(
                opacity: opacity,
                child: SvgPicture.asset(
                  'assets/images/components/star_${star.svg}.svg',
                  width: star.size.toDouble(),
                  height: star.size.toDouble(),
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _StarInfo {
  final double angle;
  final double dist;
  final int svg;
  final int size;
  final double alpha;

  const _StarInfo({
    required this.angle,
    required this.dist,
    required this.svg,
    required this.size,
    required this.alpha,
  });
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Main arc — thick white with fade
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi * 1.5,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.8),
          Colors.white,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, 0, pi * 1.5, false, paint);

    // Subtle second arc — thinner, more transparent
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.15);

    canvas.drawArc(rect, pi * 1.5, pi * 0.5, false, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

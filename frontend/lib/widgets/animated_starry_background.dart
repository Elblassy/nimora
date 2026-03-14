import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A full-screen animated mesh gradient background using a custom fragment
/// shader. 6 physics-based control points drift organically — the exact same
/// algorithm and GLSL blending as the reference HTML/WebGL project.
class AnimatedStarryBackground extends StatefulWidget {
  final Widget child;

  const AnimatedStarryBackground({super.key, required this.child});

  @override
  State<AnimatedStarryBackground> createState() =>
      _AnimatedStarryBackgroundState();
}

class _AnimatedStarryBackgroundState extends State<AnimatedStarryBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _MeshGradientSimulation _simulation;
  ui.FragmentShader? _shader;
  bool _shaderFailed = false;

  @override
  void initState() {
    super.initState();
    _simulation = _MeshGradientSimulation();
    _loadShader();
    _ticker = createTicker((_) {
      _simulation.step();
      setState(() {});
    })..start();
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/mesh_gradient.frag');
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      debugPrint('Shader load failed: $e');
      setState(() => _shaderFailed = true);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: (_shader != null)
              ? CustomPaint(
                  painter: _ShaderPainter(
                    shader: _shader!,
                    simulation: _simulation,
                  ),
                  willChange: true,
                )
              : _shaderFailed
                  ? _FallbackGradient(simulation: _simulation)
                  : const ColoredBox(color: Color(0xFF1F1843)),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

// ─── Shader painter ───────────────────────────────────────────────────────────

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final _MeshGradientSimulation simulation;

  _ShaderPainter({required this.shader, required this.simulation});

  @override
  void paint(Canvas canvas, Size size) {
    // u_res (vec2) → floats 0,1
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // 6 points: u_p0..u_p5 (each vec2 → 2 floats)
    int idx = 2;
    for (final p in simulation.points) {
      shader.setFloat(idx++, p.x);
      shader.setFloat(idx++, p.y);
    }

    // 6 colours: u_c0..u_c5 (each vec3 → 3 floats)
    for (final p in simulation.points) {
      shader.setFloat(idx++, p.rn);
      shader.setFloat(idx++, p.gn);
      shader.setFloat(idx++, p.bn);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_ShaderPainter old) => true;
}

// ─── Fallback (no shader support) ─────────────────────────────────────────────

class _FallbackGradient extends StatelessWidget {
  final _MeshGradientSimulation simulation;
  const _FallbackGradient({required this.simulation});

  @override
  Widget build(BuildContext context) {
    // Stack radial gradients as a rough approximation
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFF1F1843)),
        ),
        for (final p in simulation.points)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    (p.x - 0.5) * 2.0,
                    (p.y - 0.5) * 2.0,
                  ),
                  radius: 1.2,
                  colors: [
                    Color.fromARGB(180, (p.rn * 255).round(), (p.gn * 255).round(), (p.bn * 255).round()),
                    Color.fromARGB(0, (p.rn * 255).round(), (p.gn * 255).round(), (p.bn * 255).round()),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Physics simulation ───────────────────────────────────────────────────────

class _ControlPoint {
  double x, y, vx, vy;
  final double rn, gn, bn; // normalised 0..1 colour for shader

  _ControlPoint({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required Color color,
  })  : rn = color.r,
        gn = color.g,
        bn = color.b;
}

class _MeshGradientSimulation {
  static const double _minDist = 0.392;
  static const double _repelForce = 0.00015;
  static const double _maxSpeed = 0.0006;
  static const double _minSpeed = 0.0003;
  static const double _returnForce = 0.00002;

  static const _color1 = Color(0xFF3778AC); // blue
  static const _color2 = Color(0xFF693C72); // purple
  static const _color3 = Color(0xFF1F1843); // deep navy

  late final List<_ControlPoint> points;

  _MeshGradientSimulation() {
    final rng = Random();
    final colors = [_color1, _color1, _color2, _color2, _color3, _color3];

    points = [];
    for (int i = 0; i < 6; i++) {
      double x, y;
      bool tooClose;
      do {
        x = 0.1 + rng.nextDouble() * 0.8;
        y = 0.1 + rng.nextDouble() * 0.8;
        tooClose = false;
        for (final p in points) {
          if (_dist(x, y, p.x, p.y) < 0.3) {
            tooClose = true;
            break;
          }
        }
      } while (tooClose);

      final angle = rng.nextDouble() * 2 * pi;
      final speed = _minSpeed + rng.nextDouble() * (_maxSpeed - _minSpeed);
      points.add(_ControlPoint(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: colors[i],
      ));
    }
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }

  void step() {
    final rng = Random();

    // Repulsion between points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final a = points[i];
        final b = points[j];
        final d = _dist(a.x, a.y, b.x, b.y);
        if (d < _minDist && d > 0.0001) {
          final overlap = _minDist - d;
          final force = overlap * _repelForce;
          final dx = (a.x - b.x) / d;
          final dy = (a.y - b.y) / d;
          a.vx += dx * force;
          a.vy += dy * force;
          b.vx -= dx * force;
          b.vy -= dy * force;
        }
      }
    }

    for (final p in points) {
      // Hard boundary return
      if (p.x < 0) p.vx += (-p.x) * _returnForce * 10;
      if (p.x > 1) p.vx -= (p.x - 1) * _returnForce * 10;
      if (p.y < 0) p.vy += (-p.y) * _returnForce * 10;
      if (p.y > 1) p.vy -= (p.y - 1) * _returnForce * 10;

      // Soft pull toward centre zone (0.1–0.9)
      if (p.x < 0.1) p.vx += (0.1 - p.x) * _returnForce;
      if (p.x > 0.9) p.vx -= (p.x - 0.9) * _returnForce;
      if (p.y < 0.1) p.vy += (0.1 - p.y) * _returnForce;
      if (p.y > 0.9) p.vy -= (p.y - 0.9) * _returnForce;

      // Speed normalization
      final speed = sqrt(p.vx * p.vx + p.vy * p.vy);
      if (speed > _maxSpeed) {
        p.vx = p.vx / speed * _maxSpeed;
        p.vy = p.vy / speed * _maxSpeed;
      } else if (speed < _minSpeed) {
        if (speed > 0.00001) {
          p.vx = p.vx / speed * _minSpeed;
          p.vy = p.vy / speed * _minSpeed;
        } else {
          final angle = rng.nextDouble() * 2 * pi;
          p.vx = cos(angle) * _minSpeed;
          p.vy = sin(angle) * _minSpeed;
        }
      }

      p.x += p.vx;
      p.y += p.vy;
    }
  }
}

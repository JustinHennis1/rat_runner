import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  double maxHealth;
  double currentHealth;

  late SlantedHealthBarShape shape;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    required Vector2 size,
    Vector2? position,
  }) {
    this.size = size;
    this.position = position ?? Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    shape = SlantedHealthBarShape(
      size: size,
      percent: (currentHealth / maxHealth).clamp(0.0, 1.0),
      fillColor: Colors.green,
      backgroundColor: Colors.black.withOpacity(0.55),
      borderColor: const Color(0xFF2B2B2B),
    );
    add(shape);
  }

  void setHealth(double value) {
    currentHealth = value.clamp(0, maxHealth);
    final percent = (currentHealth / maxHealth).clamp(0.0, 1.0);
    shape.percent = percent;

    if (percent > 0.6) {
      shape.fillColor = Colors.green;
    } else if (percent > 0.3) {
      shape.fillColor = Colors.orange;
    } else {
      shape.fillColor = Colors.red;
    }
  }

  void setMaxHealth(double newMax) {
    maxHealth = newMax;
    currentHealth = currentHealth.clamp(0, maxHealth);
    shape.percent = (currentHealth / maxHealth).clamp(0.0, 1.0);
  }
}

class SlantedHealthBarShape extends PositionComponent {
  double percent;
  Color fillColor;
  final Color backgroundColor;
  final Color borderColor;

  SlantedHealthBarShape({
    required Vector2 size,
    required this.percent,
    required this.fillColor,
    required this.backgroundColor,
    required this.borderColor,
  }) {
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // How “slanted” the right end is (tweak this to match your art)
    final bevel = (h * 0.9).clamp(6.0, h); // px

    // Outer bar polygon (background + border)
    final outer = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - bevel, h)
      ..lineTo(0, h)
      ..close();

    // Draw background
    canvas.drawPath(outer, Paint()..color = backgroundColor);

    // Draw fill with a *matching slanted tip*
    final fillW = (w * percent).clamp(0.0, w);

    if (fillW > 0) {
      final fillPath = _fillPath(fillW, h, bevel);

      canvas.drawPath(fillPath, Paint()..color = fillColor);

      // Optional: small highlight near the right like your screenshot
      if (percent > 0.12) {
        final hiW = (h * 1.2).clamp(10.0, w);
        final highlight = Path()
          ..moveTo((fillW - hiW).clamp(0.0, fillW), 0)
          ..lineTo(fillW, 0)
          ..lineTo((fillW - bevel).clamp(0.0, fillW), h)
          ..lineTo((fillW - hiW - bevel).clamp(0.0, fillW), h)
          ..close();

        canvas.drawPath(
          highlight,
          Paint()..color = Colors.white.withOpacity(0.18),
        );
      }
    }

    // Border stroke (dark outline)
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = borderColor,
    );

    // Thin inner stroke like the “double line” look
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.25),
    );
  }

  /// Builds the filled polygon so the right edge stays slanted.
  Path _fillPath(double fillW, double h, double bevel) {
    // If fill is long enough to include the slanted end:
    if (fillW >= bevel) {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(fillW, 0)
        ..lineTo(fillW - bevel, h)
        ..lineTo(0, h)
        ..close();
    }

    // If fill is very small, we can only draw a partial wedge.
    // Make a smaller similar trapezoid.
    final localBevel = fillW; // bevel cannot exceed fill width
    return Path()
      ..moveTo(0, 0)
      ..lineTo(fillW, 0)
      ..lineTo((fillW - localBevel).clamp(0.0, fillW), h)
      ..lineTo(0, h)
      ..close();
  }
}

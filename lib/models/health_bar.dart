import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  final double maxHealth;
  double currentHealth;

  late RectangleComponent background;
  late RectangleComponent foreground;

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
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.6),
    );

    foreground = RectangleComponent(
      size: Vector2(size.x * (currentHealth / maxHealth), size.y),
      paint: Paint()..color = Colors.green,
    );

    add(background);
    add(foreground);
  }

  void setHealth(double value) {
    currentHealth = value.clamp(0, maxHealth);
    final percent = currentHealth / maxHealth;

    foreground.size.x = size.x * percent;

    // Optional color change
    if (percent > 0.6) {
      foreground.paint.color = Colors.green;
    } else if (percent > 0.3) {
      foreground.paint.color = Colors.orange;
    } else {
      foreground.paint.color = Colors.red;
    }
  }
}

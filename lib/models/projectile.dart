import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Projectile extends CircleComponent {
  final double speed = 400.0;

  Projectile({required Vector2 position})
    : super(
        position: position,
        radius: 8,
        paint: Paint()..color = Colors.yellow,
      );

  @override
  void update(double dt) {
    super.update(dt);
    // Move projectile to the right
    position.x += speed * dt;
  }
}

class EnemyProjectile extends SpriteComponent {
  final double speed;

  EnemyProjectile({
    required Vector2 position,
    required Sprite spriteImage,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(120, 120),
         sprite: spriteImage,
         anchor: Anchor.center,
       );

  @override
  void update(double dt) {
    super.update(dt);
    // Move projectile to the right
    position.x -= speed * dt;
  }
}

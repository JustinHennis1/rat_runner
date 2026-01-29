import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PowerUp extends SpriteAnimationComponent {
  final String type;

  PowerUp({
    required Vector2 position,
    required SpriteAnimation animation,
    required this.type,
  }) : super(
         position: position,
         size: Vector2(64, 64),
         animation: animation,
         anchor: Anchor.center,
       );
}

class HealthPowerUp extends PowerUp {
  HealthPowerUp({
    required Vector2 position,
    required SpriteAnimation animation,
  }) : super(
         position: position,
         animation: animation,
         type: 'health',
       );
}


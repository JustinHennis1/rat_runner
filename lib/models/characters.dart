import 'package:flame/components.dart';

class Player extends SpriteAnimationComponent {
  Player({required Vector2 position, required SpriteAnimation animation})
    : super(
        position: position,
        size: Vector2(100, 100),
        animation: animation,
        anchor: Anchor.bottomLeft,
      );
}

class Enemy extends SpriteAnimationComponent {
  Enemy({required Vector2 position, required SpriteAnimation animation})
    : super(
        position: position,
        size: Vector2(100, 100),
        animation: animation,
        anchor: Anchor.bottomRight,
      );
}

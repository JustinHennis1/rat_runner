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
  final int enemyLevel;
  bool isAttacking = false;

  Enemy({
    required this.enemyLevel,
    required Vector2 position,
    required SpriteAnimation animation,
  }) : super(
          position: position,
          size: Vector2(100, 100),
          animation: animation,
          anchor: Anchor.bottomRight,
        );

  void setAttacking(bool attacking) {
    isAttacking = attacking;
  }
  bool getAttacking() {
    return isAttacking;
  }
}

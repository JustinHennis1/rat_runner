import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/projectile.dart';

class CollisionHelper {
  static bool projectileHitsEnemy(
    Projectile projectile,
    SpriteAnimationComponent target,
  ) {
    final projectileRect = projectile.toRect();

    final targetRect = Rect.fromLTWH(
      target.position.x + target.size.x * 0.2,
      target.position.y - 70,
      target.size.x * 0.6,
      target.size.y * 0.6,
    );

    return projectileRect.overlaps(targetRect);
  }

  static bool enemyHitsPlayer(
    EnemyProjectile projectile,
    SpriteAnimationComponent target,
  ) {
    final enemyRect = Rect.fromLTWH(
      projectile.position.x - 35,
      projectile.position.y - 10,
      projectile.size.x * 0.4,
      projectile.size.y * 0.4,
    );

    final targetRect = Rect.fromLTWH(
      target.position.x + target.size.x * 0.25,
      target.position.y - 70,
      target.size.x * 0.5,
      target.size.y * 0.6,
    );

    return enemyRect.overlaps(targetRect);
  }
}

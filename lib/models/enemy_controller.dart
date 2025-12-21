import 'package:flame/components.dart';
import 'package:jumpnthrow/models/animations.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/projectile.dart';

class EnemyController {
  static Enemy spawnEnemy(
    Vector2 size,
    int ratX,
    int ratY,
    int level,
  ) {
    SpriteAnimation animation = Animations.enemyFireball;

    switch (level) {
      case 2:
        animation = Animations.enemyFireball2;
        break;
      case 3:
        animation = Animations.enemyPoisonball;
        break;
    }

    final rat = Enemy(
      animation: animation,
      position: Vector2(size.x - ratX.toDouble(), size.y - ratY),
    );

    rat.flipHorizontallyAroundCenter();
    return rat;
  }

  static EnemyProjectile createProjectile(
    Sprite sprite,
    Vector2 position,
    double speed,
  ) {
    final projectile = EnemyProjectile(
      spriteImage: sprite,
      position: position,
      speed: speed,
    );

    projectile.flipHorizontallyAroundCenter();
    return projectile;
  }
}

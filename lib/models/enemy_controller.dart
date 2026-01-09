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
    SpriteAnimation animation = Animations.blueFireRat;

    // Enemy not set to attack yet
    switch (level) {
      case 2:
        animation = Animations.redFireRat;
        break;
      case 3:
        animation = Animations.purplePoisonRat;
        break;
      case 4:
        animation = Animations.cheeseKnightRat;
        break;
      case 5:
        animation = Animations.clockworkRat;
        break;
    }

    final rat = Enemy(
      animation: animation,
      position: Vector2(size.x - ratX.toDouble(), size.y - ratY),
      enemyLevel: level,
    );
    rat.flipHorizontallyAroundCenter();
    return rat;
  }

  static SpriteAnimation getAttackAnimation(int level) {
    SpriteAnimation attackAnimation = Animations.blueFireRatAttacking;

    switch (level) {
      case 2:
        attackAnimation = Animations.redFireRatAttacking;
        break;
      case 3:
        attackAnimation = Animations.purplePoisonRatAttacking;
        break;
      case 4:
        attackAnimation = Animations.cheeseKnightRatAttacking;
        break;
      case 5:
        attackAnimation = Animations.clockworkRatAttacking;
        break;
    }
    return attackAnimation;
  }

  static SpriteAnimation resetEnemyAnimation(int level) {
    SpriteAnimation resetAnimation = Animations.blueFireRat;

    switch (level) {
      case 2:
        resetAnimation = Animations.redFireRat;
        break;
      case 3:
        resetAnimation = Animations.purplePoisonRat;
        break;
      case 4:
        resetAnimation = Animations.cheeseKnightRat;
        break;
      case 5:
        resetAnimation = Animations.clockworkRat;
        break;
    }
    return resetAnimation;
  }

  static Sprite getProjectileSprite(int level) {
    Sprite projectileSprite;

    switch (level) {
      case 1:
        projectileSprite = Animations.blueFireball; //firing animation
        break;
      case 2:
        projectileSprite = Animations.redFireball;
        break;
      case 3:
        projectileSprite = Animations.poisonball;
        break;
      case 4:
        projectileSprite = Animations.swordSlash;
        break;
      case 5:
        projectileSprite = Animations.clockworkGear;
        break;
      default:
        projectileSprite = Animations.blueFireball;
    }
    return projectileSprite;
    
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

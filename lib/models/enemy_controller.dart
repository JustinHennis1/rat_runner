import 'dart:math';
import 'package:flame/components.dart';
import 'package:cityrun/models/animations.dart';
import 'package:cityrun/models/characters.dart';
import 'package:cityrun/models/projectile.dart';

class EnemyController {
  static final Random _rng = Random();

  // Choose the next enemy "type" (level) randomly.
  // Example: if playerLevel==4, can spawn 1..4.
  static int pickRandomEnemyLevel(int playerLevel, {bool avoidRepeats = true, int? lastLevel}) {
    final maxType = playerLevel.clamp(1, 5);
    final choices = List<int>.generate(maxType, (i) => i + 1);

    if (avoidRepeats && lastLevel != null && choices.length > 1) {
      choices.remove(lastLevel);
    }

    return choices[_rng.nextInt(choices.length)];
  }

  static Enemy spawnEnemy(
    Vector2 size,
    int ratX,
    int ratY,
    int chosenLevel,
  ) {
    final animation = resetEnemyAnimation(chosenLevel);

    final rat = Enemy(
      animation: animation,
      position: Vector2(size.x - ratX.toDouble(), size.y - ratY),
      enemyLevel: chosenLevel,
    );

    rat.flipHorizontallyAroundCenter();
    return rat;
  }

  static SpriteAnimation getAttackAnimation(int level) {
    switch (level) {
      case 2: return Animations.redFireRatAttacking;
      case 3: return Animations.purplePoisonRatAttacking;
      case 4: return Animations.cheeseKnightRatAttacking;
      case 5: return Animations.clockworkRatAttacking;
      case 1:
      default: return Animations.blueFireRatAttacking;
    }
  }

  static SpriteAnimation resetEnemyAnimation(int level) {
    switch (level) {
      case 2: return Animations.redFireRat;
      case 3: return Animations.purplePoisonRat;
      case 4: return Animations.cheeseKnightRat;
      case 5: return Animations.clockworkRat;
      case 1:
      default: return Animations.blueFireRat;
    }
  }

  static Sprite getProjectileSprite(int level) {
    switch (level) {
      case 2: return Animations.redFireball;
      case 3: return Animations.poisonball;
      case 4: return Animations.swordSlash;
      case 5: return Animations.clockworkGear;
      case 1:
      default: return Animations.blueFireball;
    }
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

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'package:jumpnthrow/models/animations.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/collision.dart';
import 'package:jumpnthrow/models/enemy_controller.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';
import 'package:jumpnthrow/models/game_state.dart';
import 'package:jumpnthrow/models/player_controller.dart';
import 'package:jumpnthrow/views/settings.dart';

class StickmanRunner extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final void Function(int) onGameEnd;
  StickmanRunner({required this.onGameEnd});

  // Core components
  late ParallaxComponent parallaxBackground;
  late SpriteAnimationComponent boy;
  late SpriteAnimationComponent rat;

  // Game constants (unchanged)
  final double gameSpeed = 180.0;
  final double gravity = 980.0;
  final double jumpForce = -500.0;
  final double lungeForce = 400.0;

  final int boy_y = 210;
  final int boy_x = 10;
  final int rat_y = 210;
  final int rat_x = 10;

  // UI
  late SpriteComponent scoreBackdrop;
  late TextComponent scoreText;
  late TextComponent healthText;
  late TextComponent rathealthText;

  // Gameplay values
  double speed = 100;
  double projectileSpeed = 240;

  // Centralized state
  final GameState state = GameState();

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallax(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(gameSpeed, 0),
      velocityMultiplierDelta: Vector2(1, 1),
    );

    parallaxBackground = ParallaxComponent(parallax: parallax)
      ..scale = Vector2(2, 2)
      ..position = Vector2(0, -900);

    add(parallaxBackground);

    scoreBackdrop = SpriteComponent(
      sprite: await loadSprite('pgdesign.png'),
      anchor: Anchor.center,
      position: Vector2(size.x/2, 50),
      size: Vector2(size.x, 120), // backdrop height
    );

    scoreText = TextComponent(
      text: '0',
      position: Vector2(size.x/2, 80),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer'
        ),
      ),
    );

    healthText = TextComponent(
      text: 'Health: 100',
      position: Vector2(boy_x.toDouble(), boy_y + 500),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    rathealthText = TextComponent(
      text: 'Health: 100',
      position: Vector2(rat_x.toDouble() + 270, rat_y.toDouble() + 500),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreBackdrop);
    add(scoreText);
    add(healthText);
    add(rathealthText);

    await Animations.load();

    boy = Player(
      animation: Animations.run,
      position: Vector2(boy_x.toDouble(), size.y - boy_y),
    );

    rat = EnemyController.spawnEnemy(
      size,
      rat_x,
      rat_y,
      state.level,
    );

    add(boy);
    add(rat);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Distance / score
    state.distance += speed * dt;
    scoreText.text = '${state.distance.toInt()}';

    // Enemy shooting
    state.enemyShootTimer += dt;
    if (state.enemyShootTimer >= state.enemyShootInterval) {
      setAttacked(state.level);
      state.enemyShootTimer = 0;
      state.enemyShootInterval =
          1.5 + state.random.nextDouble() * 1.5;
    }

    // Jump physics
    if (state.isJumping || boy.position.y < size.y - 150) {
      state.velocityY += gravity * dt;
      boy.position.y += state.velocityY * dt;

      if (boy.position.y >= size.y - boy_y) {
        boy.position.y = size.y - boy_y;
        state.velocityY = 0;
        state.isJumping = false;
      }
    }

    // Lunge physics
    if (state.isLunging || boy.position.x < size.x - 150) {
      state.velocityX -= gravity * dt;
      boy.position.x += state.velocityX * dt;

      if (boy.position.x <= boy_x) {
        boy.position.x = boy_x.toDouble();
        state.velocityX = 0;
        state.isLunging = false;
      }
    }

    if (!state.isJumping &&
        !state.isLunging &&
        !state.isShooting) {
      PlayerController.setRun(boy);
    }

    // Cleanup projectiles
    state.projectiles.removeWhere((p) {
      if (p.position.x > size.x) {
        p.removeFromParent();
        return true;
      }
      return false;
    });

    // Player projectiles → enemy
    for (final projectile in List.from(state.projectiles)) {
      if (rat.isMounted &&
          CollisionHelper.projectileHitsEnemy(
              projectile, rat)) {
        projectile.removeFromParent();
        state.projectiles.remove(projectile);
        state.ratHealth -= 20;
        rathealthText.text = 'Health: ${state.ratHealth}';
      }
    }

    // Enemy projectiles → player
    for (final projectile in List.from(state.enemyProjectiles)) {
      if (CollisionHelper.enemyHitsPlayer(projectile, boy)) {
        projectile.removeFromParent();
        state.enemyProjectiles.remove(projectile);
        state.health -= 20;
        healthText.text = 'Health: ${state.health}';
      }
    }

    // End conditions
    if (state.health <= 0) {
      onGameEnd(state.distance.toInt());
      pauseEngine();
    } else if (state.ratHealth <= 0) {
      if (rat.isMounted) {
        remove(rat);
      }
      spawn();
      state.distance *= 1.5;
    }
  }

  Future<void> setAttacked(int level) async {
    if (!rat.isMounted) return;

    final ratsheet = images.fromCache('rats.png');
    final spriteSize = Vector2(380, 380);

    Sprite projectileSprite;
    if (level <= 3) {
      projectileSprite = Sprite(
        ratsheet,
        srcPosition: Vector2(380 * 3, level * 320 - 320),
        srcSize: spriteSize,
      );
    } else {
      projectileSprite = Sprite(
        ratsheet,
        srcPosition: Vector2(380 * 3, 0),
        srcSize: spriteSize,
      );
    }

    final projectile = EnemyController.createProjectile(
      projectileSprite,
      Vector2(rat.position.x - 30, rat.position.y - 50),
      projectileSpeed,
    );

    add(projectile);
    state.enemyProjectiles.add(projectile);
  }

  void jump() {
    if (!state.isJumping && boy.position.y >= size.y - 250) {
      state.isJumping = true;
      PlayerController.setJump(boy);
      state.velocityY = jumpForce;

      Future.delayed(const Duration(milliseconds: 300), () {
        state.isJumping = false;
      });
    }
  }

  void lunge() {
    if (!state.isLunging && boy.position.x <= boy_x + 10) {
      state.isLunging = true;
      state.velocityX = lungeForce;
    }
  }

  void shoot() {
    if (state.isShooting) return;

    final projectile = PlayerController.shoot(boy.position);
    state.isShooting = true;
    PlayerController.setAttack(boy);

    add(projectile);
    state.projectiles.add(projectile);

    Future.delayed(const Duration(milliseconds: 200), () {
      state.isShooting = false;
    });
  }

  void spawn() {
    if (rat.isMounted) return;

    state.level += 1;
    state.ratHealth = 100;
    rathealthText.text = 'Health: ${state.ratHealth}';

    rat = EnemyController.spawnEnemy(
      size,
      rat_x,
      rat_y,
      state.level,
    );

    add(rat);
    rat.position.y = size.y - 200;
    rat.position.x = size.x - 100;
  }
}


// Main widget to run the game
class MyGameWidget extends StatelessWidget {
  const MyGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StickmanRunner game = StickmanRunner(
      onGameEnd: (score) {
        Navigator.pop(context, score);
      },

      
    );

  final GameSettings settings = GameSettings();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              bottom: 20,
                left: GameSettingsModel.leftHanded ? 20 : null,
                right: GameSettingsModel.leftHanded ? null : 20,
              child: SizedBox(
                height: GameSettingsModel.buttonSize,
                width: GameSettingsModel.buttonSize,
                child: FloatingActionButton(
                  onPressed: () {
                    game.shoot(); // Changed to shoot projectiles
                  },
                  heroTag: "attack",
                  child: Icon(Icons.flash_on),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
                left: GameSettingsModel.leftHanded ? null : 20,
                right: GameSettingsModel.leftHanded ? 20 : null,
              child: SizedBox(
                height: GameSettingsModel.buttonSize,
                width: GameSettingsModel.buttonSize,
                child: FloatingActionButton(
                  onPressed: () {
                    game.jump();
                  },
                  heroTag: "jump",
                  child: Icon(Icons.arrow_upward, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

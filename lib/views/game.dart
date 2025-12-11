import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/animations.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/projectile.dart';
import 'dart:math';

class StickmanRunner extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final void Function(int) onGameEnd;
  StickmanRunner({required this.onGameEnd});

  late ParallaxComponent parallaxBackground;
  late SpriteAnimationComponent boy;
  late SpriteAnimationComponent rat;
  final double gameSpeed = 180.0;
  bool isJumping = false;
  bool isLunging = false;
  bool isShooting = false;
  double velocityY = 0;
  double velocityX = 0;
  final double gravity = 980.0;
  final double jumpForce = -500.0;
  final double lungeForce = 400.0;
  final int boy_y = 210;
  final int boy_x = 10;
  final int rat_y = 210;
  final int rat_x = 10;
  late TextComponent scoreText;
  late TextComponent healthText;
  late TextComponent rathealthText;
  double health = 100;
  double rathealth = 100;
  double distance = 0; // Distance ran
  double speed = 100; // pixels per second
  double projectileSpeed = 240;
  int level = 1;

  // Projectile management
  final List<Projectile> projectiles = [];
  final List<EnemyProjectile> enemyProjectiles = [];

  // Enemy shooting variables
  double enemyShootTimer = 0;
  double enemyShootInterval = 2.0;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Create seamless scrolling background using Parallax
    final parallax = await loadParallax(
      [ParallaxImageData('background.jpg')],
      baseVelocity: Vector2(gameSpeed, 0),
      velocityMultiplierDelta: Vector2(1, 1),
    );

    parallaxBackground = ParallaxComponent(parallax: parallax);
    parallaxBackground.scale = Vector2(2, 2);
    parallaxBackground.position = Vector2(0, -900);
    add(parallaxBackground);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

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
    add(healthText);

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
    add(rathealthText);

    await Animations.load();

    boy = Player(
      animation: Animations.run,
      position: Vector2(boy_x.toDouble(), size.y - boy_y),
    );

    rat = Enemy(
      animation: Animations.enemyFireball,
      position: Vector2(size.x - rat_x.toDouble(), size.y - rat_y),
    );

    // Flip the rat horizontally to face left (toward the player)
    rat.flipHorizontallyAroundCenter();

    // Add characters to the game
    add(boy);
    add(rat);
  }

  @override
  void update(double dt) {
    super.update(dt);

    distance += speed * dt;
    scoreText.text = 'Score: ${distance.toInt()}';

    // Enemy shooting logic - shoot at random intervals
    enemyShootTimer += dt;
    if (enemyShootTimer >= enemyShootInterval) {
      setAttacked(level);
      enemyShootTimer = 0;
      // Randomize next shot interval between 1.5 and 3 seconds
      enemyShootInterval = 1.5 + random.nextDouble() * 1.5;
    }

    // Apply gravity and update vertical position
    if (isJumping || boy.position.y < size.y - 150) {
      velocityY += gravity * dt;
      boy.position.y += velocityY * dt;

      // Ground collision check
      if (boy.position.y >= size.y - boy_y) {
        boy.position.y = size.y - boy_y;
        velocityY = 0;
        isJumping = false;
      }
    }

    // Return to original x position after attack
    // made for luge action if used
    if (isLunging || boy.position.x < size.x - 150) {
      velocityX -= gravity * dt;
      boy.position.x += velocityX * dt;

      if (boy.position.x <= boy_x) {
        boy.position.x = boy_x.toDouble();
        velocityX = 0;
        isLunging = false;
      }
    }

    if (!isJumping && !isLunging && !isShooting) {
      boy.animation = Animations.run;
    }

    // Remove projectiles that are off-screen
    projectiles.removeWhere((projectile) {
      if (projectile.position.x > size.x) {
        projectile.removeFromParent();
        return true;
      }
      return false;
    });

    // Check collision between projectiles and rat
    for (var projectile in List.from(projectiles)) {
      if (rat.isMounted && _checkCollision(projectile, rat)) {
        projectile.removeFromParent();
        projectiles.remove(projectile);
        rathealth -= 20;
        rathealthText.text = 'Health: $rathealth';
        //print("Hit the rat!");
      }
    }

    // Check collision between enemy projectiles and player
    for (var projectile in List.from(enemyProjectiles)) {
      if (_checkEnemyCollision(projectile, boy)) {
        projectile.removeFromParent();
        enemyProjectiles.remove(projectile);
        //print("Hit the player!");
        health -= 20;
        healthText.text = 'Health: $health';
      }
    }

    if (health <= 0) {
      //print("You Lost");
      onGameEnd(distance.toInt());
      pauseEngine(); // Stop the game
    } else if (rathealth <= 0) {
      if (rat.isMounted) {
        remove(rat);
      }
      spawn();
      print("Double Score");
      distance = distance * 2;
    }
  }

  // Simple collision detection with reduced hitbox
  bool _checkCollision(Projectile projectile, SpriteAnimationComponent target) {
    final projectileRect = projectile.toRect();

    // Create a smaller hitbox for the rat (adjust percentages as needed)
    final targetRect = Rect.fromLTWH(
      target.position.x + target.size.x * 0.2, // Offset from left
      target.position.y - 70, // Offset from top
      target.size.x * 0.6, // 60% of original width
      target.size.y * 0.6, // 60% of original height
    );

    return projectileRect.overlaps(targetRect);
  }

  bool _checkEnemyCollision(
    EnemyProjectile projectile,
    SpriteAnimationComponent target,
  ) {
    // Custom hitbox made for enemy projectile
    final enemyRect = Rect.fromLTWH(
      projectile.position.x - 35,
      projectile.position.y - 10,
      projectile.size.x * 0.4,
      projectile.size.y * 0.4,
    );

    // Create a smaller hitbox for the stickman (adjust percentages as needed)
    final targetRect = Rect.fromLTWH(
      target.position.x + target.size.x * 0.25, // Offset from left
      target.position.y - 70, // Offset from top (important for jumping)
      target.size.x * 0.5, // 50% of original width
      target.size.y * 0.6, // 60% of original height
    );

    return enemyRect.overlaps(targetRect);
  }

  Future<void> setAttacked(int level) async {
    if (rat.isMounted) {
      // Load the sprite sheet and extract the 4th frame
      final ratsheet = images.fromCache('rats.png'); // Use cached image
      final spriteSize = Vector2(380, 380);
      Sprite projectileSprite;
      if (level <= 3) {
        projectileSprite = Sprite(
          ratsheet,
          srcPosition: Vector2(
            380 * 3,
            level * 320 - 320,
          ), // 4th frame: y = 380 * 3
          srcSize: spriteSize,
        );
      } else {
        projectileSprite = Sprite(
          ratsheet,
          srcPosition: Vector2(380 * 3, 0), // 4th frame: y = 380 * 3
          srcSize: spriteSize,
        );
      }
      final projectile = EnemyProjectile(
        spriteImage: projectileSprite,
        position: Vector2(rat.position.x - 30, rat.position.y - 50),
        speed: projectileSpeed,
      );
      projectile.flipHorizontallyAroundCenter();
      add(projectile);
      enemyProjectiles.add(projectile);
    }
  }

  void jump() {
    if (!isJumping && boy.position.y >= size.y - 250) {
      isJumping = true;
      boy.animation = Animations.jump;
      velocityY = jumpForce;

      Future.delayed(Duration(milliseconds: 300), () {
        isJumping = false;
      });
    }
  }

  void lunge() {
    if (!isLunging && boy.position.x <= boy_x + 10) {
      isLunging = true;
      velocityX = lungeForce;
    }
  }

  void shoot() {
    if (!isShooting) {
      // Prevent shooting while already shooting
      // Create projectile at stickman's position
      final projectile = Projectile(
        position: Vector2(boy.position.x + 50, boy.position.y - 50),
      );
      isShooting = true;
      boy.animation = Animations.attack;

      add(projectile);
      projectiles.add(projectile);

      // Reset after animation duration (adjust time as needed)
      Future.delayed(Duration(milliseconds: 200), () {
        isShooting = false;
      });
    }
  }

  void spawn() {
    if (!rat.isMounted) {
      level += 1;

      // Reset rat health
      rathealth = 100;
      rathealthText.text = 'Health: $rathealth';

      // Choose attack pattern based on level
      SpriteAnimation attackPattern = Animations.enemyFireball;
      switch (level) {
        case 2:
          attackPattern = Animations.enemyFireball2;
          break;
        case 3:
          attackPattern = Animations.enemyPoisonball;
          break;
        default:
          attackPattern = Animations.enemyFireball;
          break;
      }

      // Create new rat
      rat = Enemy(
        position: Vector2(size.x - rat_x.toDouble(), size.y - rat_y),
        animation: attackPattern,
      );

      // Flip horizontally to face the player
      rat.flipHorizontallyAroundCenter();

      // Add the new rat to the game
      add(rat);
    }
  }

  //
  //
  // For Hitbox Visualization
  //
  //
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw hitboxes for debugging
    _drawHitboxes(canvas);
  }

  void _drawHitboxes(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw stickman hitbox
    final stickmanHitbox = Rect.fromLTWH(
      boy.position.x + boy.size.x * 0.25,
      boy.position.y - 70,
      boy.size.x * 0.5,
      boy.size.y * 0.6,
    );
    canvas.drawRect(stickmanHitbox, fillPaint);
    canvas.drawRect(stickmanHitbox, paint);

    // Draw rat hitbox
    final ratPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final ratFillPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final ratHitbox = Rect.fromLTWH(
      rat.position.x + rat.size.x * 0.2,
      rat.position.y - 70,
      rat.size.x * 0.6,
      rat.size.y * 0.6,
    );
    canvas.drawRect(ratHitbox, ratFillPaint);
    canvas.drawRect(ratHitbox, ratPaint);

    // Draw projectile hitboxes
    final projectilePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var projectile in projectiles) {
      canvas.drawRect(projectile.toRect(), projectilePaint);
    }

    // Draw enemy projectile hitboxes
    final enemyProjectilePaint = Paint()
      ..color = Colors.orange.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var projectile in enemyProjectiles) {
      final enemyRect = Rect.fromLTWH(
        projectile.position.x - 35,
        projectile.position.y - 10,
        projectile.size.x * 0.4,
        projectile.size.y * 0.4,
      );
      canvas.drawRect(enemyRect, enemyProjectilePaint);
    }
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                height: 80,
                width: 80,
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
              left: 20,
              child: SizedBox(
                height: 80,
                width: 80,
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
      title: "Action Runner",
    );
  }
}

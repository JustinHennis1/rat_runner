import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'package:jumpnthrow/models/achievement_manager.dart';
import 'package:jumpnthrow/models/animations.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/collision.dart';
import 'package:jumpnthrow/models/enemy_controller.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';
import 'package:jumpnthrow/models/game_state.dart';
import 'package:jumpnthrow/models/health_bar.dart';
import 'package:jumpnthrow/models/player_controller.dart';
import 'package:jumpnthrow/views/settings.dart';

class StickmanRunner extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final void Function(int) onGameEnd;
  StickmanRunner({required this.onGameEnd});

  // Core components
  late ParallaxComponent parallaxBackground;
  late RadialGradientOverlay gradientOverlay;
  late SpriteAnimationComponent boy;
  late Enemy rat;
  late PositionComponent hud;

  // Game constants (unchanged)
  final double gameSpeed = 250.0;
  final double gravity = 980.0;
  final double jumpForce = -500.0;
  final double lungeForce = 400.0;

  int boy_y = 180; //80
  int boy_x = 10; //120
  int rat_y = 180; //80
  int rat_x = 100; //210

  // UI
  late SpriteComponent scoreBackdrop;
  late TextComponent scoreText;
  late HealthBar playerHealthBar;
  late HealthBar enemyHealthBar;

  // Gameplay values
  double speed = 100;
  double projectileSpeed = 240;

  // Centralized state
  final GameState state = GameState();

  // Track previous size for orientation changes
  Vector2? _previousSize;
  bool isLandscape = false;
  int currentBackgroundIndex = 0;
  double timeSinceLastTransition = 0.0;
  double timeBetweenTransitions = 30.0; // Switch every 30 seconds
  
  // Transition state
  bool isTransitioning = false;
  double transitionElapsed = 0.0;
  double transitionDuration = 1.5; // 1.5 second fade

  final backgrounds = [
    'background_day.png',
    'background_dawn.png',
    'background_night.png',
    'background_sunset.png',
  ];
  
  // Preloaded parallax objects for instant switching
  final Map<String, Parallax> _preloadedParallax = {};
  
  @override
  Future<void> onLoad() async {

    hud = PositionComponent()
      ..priority = 1000; // always on top

    camera.viewport.add(hud);

    // Preload ALL backgrounds at startup
    for (final bg in backgrounds) {
      _preloadedParallax[bg] = await loadParallax(
        [ParallaxImageData(bg)],
        baseVelocity: Vector2(gameSpeed, 0),
        velocityMultiplierDelta: Vector2(1, 1),
      );
    }

    // Set initial background
    parallaxBackground = ParallaxComponent(
      parallax: _preloadedParallax[backgrounds[currentBackgroundIndex]]!,
    )
      ..scale = Vector2(1, 1)
      ..position = Vector2(0, 0)
      ..priority = -100;

    add(parallaxBackground);

    // Add gradient overlay
    gradientOverlay = RadialGradientOverlay();
    add(gradientOverlay);

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
        style: TextStyle(
          color: Colors.black,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer'
        ),
      ),
    );

    playerHealthBar = HealthBar(
      maxHealth: 100,
      currentHealth: state.health.toDouble(),
      size: Vector2(100, 18),
      position: Vector2(20, size.y - 140),
    );

    enemyHealthBar = HealthBar(
      maxHealth: 100,
      currentHealth: state.ratHealth.toDouble(),
      size: Vector2(100, 18),
      position: Vector2(size.x - 20, size.y - 140),
    );

    hud.add(playerHealthBar);
    hud.add(enemyHealthBar);
    //add(scoreBackdrop);
    add(scoreText);
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

    _previousSize = size.clone();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    
    isLandscape = newSize.x > newSize.y;

    if (_previousSize != null) {
      _handleOrientationChange(newSize);
    }
    _previousSize = newSize.clone();
  }

  void _handleOrientationChange(Vector2 newSize) {

    if(isLandscape){
        boy_y = 80;
        boy_x = 120;
        rat_y = 80;
        rat_x = 210;
    } else {
      boy_y = 180;
      boy_x = 10;
      rat_y = 180;
      rat_x = 100;
    }

    // Update boy position - accounting for bottomLeft anchor
    // With bottomLeft anchor, position.y represents the bottom of the sprite
    boy.position.y = newSize.y - boy_y;
    
    // Keep boy x position relative if not at base position
    if (state.isLunging || boy.position.x > boy_x) {
      // Maintain relative position during lunge
      final relativeX = boy.position.x / _previousSize!.x;
      boy.position.x = relativeX * newSize.x;
    } else {
      boy.position.x = boy_x.toDouble();
    }

    // Update rat position if mounted
    if (rat.isMounted) {
      // Rat has bottomRight anchor, so position represents bottom-right corner
      // Position it on the right side of screen
      rat.position.x = newSize.x - rat_x;
      rat.position.y = newSize.y - rat_y;

      // Adjust for knight scaling and offset
      if(rat.animation == Animations.cheeseKnightRat || rat.animation == Animations.clockworkRat){
        rat.position.x -= 70;
        rat.position.y += 30;
      }
    }

    // Update UI elements
    scoreBackdrop.position = Vector2(newSize.x/2, 50);
    scoreBackdrop.size = Vector2(newSize.x, 120);
    scoreText.position = Vector2(newSize.x/2, 80);
    
    // Position health text relative to screen bottom
    playerHealthBar.position = Vector2(boy_x.toDouble(), newSize.y - 150);
    enemyHealthBar.position = Vector2(newSize.x - rat_x - 20, newSize.y - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Distance
    state.distance += speed * dt;
    final distanceInt = state.distance.toInt();

    // Save every 25 meters (tweakable)
    if (distanceInt - state.lastSavedDistance >= 25) {
      state.lastSavedDistance = distanceInt;

      AchievementManager.setProgress('distance_100', distanceInt);
      AchievementManager.setProgress('distance_1000', distanceInt);
      AchievementManager.setProgress('distance_10000', distanceInt);
      AchievementManager.setProgress('distance_50000', distanceInt);
      AchievementManager.setProgress('distance_100000', distanceInt);
      AchievementManager.setProgress('distance_200000', distanceInt);
    }

    // No-damage distance
    if (state.health == 100) {
      state.noDamageDistance += speed * dt;
      final noDamageInt = state.noDamageDistance.toInt();

      if (noDamageInt - state.lastSavedNoDamageDistance >= 25) {
        state.lastSavedNoDamageDistance = noDamageInt;

        AchievementManager.setProgress('no_damage_100', noDamageInt);
        AchievementManager.setProgress('no_damage_1000', noDamageInt);
        AchievementManager.setProgress('no_damage_10000', noDamageInt);
        AchievementManager.setProgress('no_damage_50000', noDamageInt);
        AchievementManager.setProgress('no_damage_100000', noDamageInt);
        AchievementManager.setProgress('no_damage_200000', noDamageInt);
      }
    } else {
      state.noDamageDistance = 0;
      state.lastSavedNoDamageDistance = 0;
    }

    // Safely convert to int for display
    try {
      scoreText.text = '${state.distance.toInt()}';
    } catch (e) {
      scoreText.text = '999999';
      state.distance = 999999;
    }

    // Time-based background transitions
    if (!isTransitioning) {
      timeSinceLastTransition += dt;
      if (timeSinceLastTransition >= timeBetweenTransitions) {
        _startTransition();
        timeSinceLastTransition = 0.0;
      }
    }

    // Update transition animation
    if (isTransitioning) {
      _updateTransition(dt);
    }

    // Enemy shooting
    state.enemyShootTimer += dt;

    if (state.enemyShootTimer >= state.enemyShootInterval &&
        !rat.getAttacking()) {

      rat.setAttacking(true);

      final idleAnimation = rat.animation;

      rat.animation =
          EnemyController.getAttackAnimation(rat.enemyLevel);

      // onComplete MUST be set on the ticker
      rat.animationTicker?.onComplete = () {
        rat.animation = idleAnimation;
        rat.setAttacking(false);
      };

      setAttacked(state.level);

      state.enemyShootTimer = 0;
      state.enemyShootInterval =
          1.5 + state.random.nextDouble() * 1.5;
    }

    // Jump physics
    if (state.isJumping || boy.position.y < size.y - boy_y) {
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
        enemyHealthBar.setHealth(state.ratHealth.toDouble());
      }
    }

    // Enemy projectiles → player
    for (final projectile in List.from(state.enemyProjectiles)) {
      if (CollisionHelper.enemyHitsPlayer(projectile, boy)) {
        projectile.removeFromParent();
        state.enemyProjectiles.remove(projectile);
        state.health -= 20;
        playerHealthBar.setHealth(state.health.toDouble());
      }
    }

    // End conditions
    if (state.health <= 0) {
      AchievementManager.incrementProgress('first_death', 1);
      AchievementManager.incrementProgress('first_run', 1);

      AchievementManager.incrementProgress('runs_5', 1);
      AchievementManager.incrementProgress('runs_10', 1);
      AchievementManager.incrementProgress('runs_50', 1);
      AchievementManager.incrementProgress('runs_100', 1);
      AchievementManager.incrementProgress('runs_200', 1);
      try {
        onGameEnd(state.distance.toInt());
      } catch (e) {
        onGameEnd(999999);
      }
      pauseEngine();
    } else if (state.ratHealth <= 0) {
      AchievementManager.incrementProgress('first_kill', 1);
      AchievementManager.incrementProgress('boss_kills_10', 1);
      AchievementManager.incrementProgress('boss_kills_25', 1);
      AchievementManager.incrementProgress('boss_kills_75', 1);
      AchievementManager.incrementProgress('boss_kills_100', 1);
      AchievementManager.incrementProgress('boss_kills_150', 1);
      if (rat.isMounted) {
        remove(rat);
      }
      spawn();
      // Add bonus distance instead of multiplying
      state.distance += 1000 + (state.level * 100);
    }
  }

  void _startTransition() {
    isTransitioning = true;
    transitionElapsed = 0.0;
    gradientOverlay.gradientColor = Colors.black;
  }

  void _updateTransition(double dt) {
    transitionElapsed += dt;
    final progress = (transitionElapsed / transitionDuration).clamp(0.0, 1.0);

    if (progress < 0.5) {
      // First half: fade to black
      final fadeProgress = progress * 2.0; // 0.0 to 1.0
      gradientOverlay.opacity = fadeProgress;
    } else {
      // Midpoint: switch background
      if (progress >= 0.5 && progress < 0.52) {
        _switchBackground();
      }
      
      // Second half: fade from black
      final fadeProgress = (progress - 0.5) * 2.0; // 0.0 to 1.0
      gradientOverlay.opacity = 1.0 - fadeProgress;
    }

    // Complete transition
    if (progress >= 1.0) {
      gradientOverlay.opacity = 0.0;
      isTransitioning = false;
      transitionElapsed = 0.0;
    }
  }

  void _switchBackground() {
    // Remove old background
    parallaxBackground.removeFromParent();
    
    // Move to next background
    currentBackgroundIndex = (currentBackgroundIndex + 1) % backgrounds.length;
    
    if(currentBackgroundIndex == 0){
      scoreText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer'
        ),
      );
    } else if (currentBackgroundIndex == 2){
      scoreText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer'
        ),
      );
    }
    

    // Create new background from preloaded parallax
    parallaxBackground = ParallaxComponent(
      parallax: _preloadedParallax[backgrounds[currentBackgroundIndex]]!,
    )
      ..scale = Vector2(1, 1)
      ..position = Vector2(0, 0)
      ..priority = -100;
    
    add(parallaxBackground);
  }

  Future<void> setAttacked(int level) async {
    if (!rat.isMounted) return;

    Sprite projectileSprite;

    projectileSprite = EnemyController.getProjectileSprite(level);
    

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
      AchievementManager.incrementProgress('first_jump', 1);
      state.isJumping = true;
      PlayerController.setJump(boy);
      state.velocityY = jumpForce;

      Future.delayed(const Duration(milliseconds: 200), () {
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

    AchievementManager.incrementProgress('first_shot', 1);

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
    enemyHealthBar.setHealth(100);

    rat = EnemyController.spawnEnemy(
      size,
      rat_x,
      rat_y,
      state.level,
    );

    add(rat);
    rat.position.y = size.y - rat_y;
    rat.position.x = size.x - rat_x;
    if(rat.animation == Animations.cheeseKnightRat || rat.animation == Animations.clockworkRat){
      rat.scale = Vector2.all(1.5);
      rat.position.x -= 70;
      rat.position.y += 30;
      rat.flipHorizontally();
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

    final GameSettings settings = GameSettings(
      buttonSize: GameSettingsModel.buttonSize, 
      leftHanded: GameSettingsModel.leftHanded, 
      selectedCharacterSheet: GameSettingsModel.selectedCharacterSheet
    );

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
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    game.shoot();
                  },
                  heroTag: "attack",
                  child: Image.asset('assets/images/shoot_btn.png', width: 70, height: 70,),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: GameSettingsModel.leftHanded ? null : 120,
              right: GameSettingsModel.leftHanded ? 20 : null,
              child: SizedBox(
                height: GameSettingsModel.buttonSize,
                width: GameSettingsModel.buttonSize,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    game.lunge();
                  },
                  heroTag: "lunge",
                  child: Image.asset('assets/images/lunge_btn.png', width: 70, height: 70,),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: GameSettingsModel.leftHanded ? null : 20,
              right: GameSettingsModel.leftHanded ? 120 : null,
              child: SizedBox(
                height: GameSettingsModel.buttonSize,
                width: GameSettingsModel.buttonSize,
                child: FloatingActionButton(
                  
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    game.jump();
                  },
                  heroTag: "jump",
                  child: Image.asset('assets/images/jmp_btn.png', width: 70, height: 70,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
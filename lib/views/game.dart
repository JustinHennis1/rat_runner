import 'dart:async';
import 'dart:async' as dart_async;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:cityrun/models/achievement_manager.dart';
import 'package:cityrun/models/animations.dart';
import 'package:cityrun/models/characters.dart';
import 'package:cityrun/models/collision.dart';
import 'package:cityrun/models/enemy_controller.dart';
import 'package:cityrun/models/game_settings_model.dart';
import 'package:cityrun/models/game_state.dart';
import 'package:cityrun/models/health_bar.dart';
import 'package:cityrun/models/player_controller.dart';
import 'package:cityrun/models/powerups.dart';
import 'package:cityrun/views/settings.dart';
import 'package:cityrun/models/attack_pattern.dart';
import 'package:cityrun/models/attack_patterns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StickmanRunner extends FlameGame with HasCollisionDetection, TapCallbacks {
  final void Function(GameResult) onGameEnd;
  StickmanRunner({required this.onGameEnd});

  // Core components
  late ParallaxComponent parallaxBackground;
  late RadialGradientOverlay gradientOverlay;
  late SpriteAnimationComponent boy;
  late Enemy rat;
  late PositionComponent hud;

  // Game constants
  final double gameSpeed = 250.0;
  final double gravity = 980.0;
  final double jumpForce = -500.0;
  final double lungeForce = 400.0;

  int boy_y = 180;
  int boy_x = 10;
  int rat_y = 180;
  int rat_x = 100;

  // UI
  late TextComponent scoreText;

  // No-damage HUD (combo-style)
  late PositionComponent noDamageHud;
  late RectangleComponent noDamageHudBg;
  late TextComponent noDamageLabelText;
  late TextComponent noDamageValueText;

  late HealthBar playerHealthBar;
  late HealthBar enemyHealthBar;

  // No-damage UI state
  int _lastNoDamageShown = -1;
  int _noDamageTier = 0;
  dart_async.Timer? _pbLabelTimer;

  // Gameplay values
  double speed = 100;
  double projectileSpeed = 240;

  // Centralized state
  final GameState state = GameState();
  int highScore = 0;
  int currentMaxDistance = 0;

  // Track previous size for orientation changes
  Vector2? _previousSize;
  bool isLandscape = false;
  int currentBackgroundIndex = 0;
  double timeSinceLastTransition = 0.0;
  double timeBetweenTransitions = 30.0;

  // Attack Patterns
  late AttackPatternRunner _attackRunner;
  int _activePatternStage = -1;

  // Transition state
  bool isTransitioning = false;
  double transitionElapsed = 0.0;
  double transitionDuration = 1.5;
  bool isIntroFadingIn = true;
  double introElapsed = 0.0;
  double introDuration = 1.2;
  double _musicTargetVolume = 0.7;
  double _musicFadeInDuration = 1.5;
  double _musicFadeElapsed = 0.0;
  bool _musicFadingIn = false;
  bool _didSwitchBgThisTransition = false;

  int numberOfJumps = 0;
  static const int maxJumps = 2;
  bool _wasGrounded = true;
  bool _handlingRatDeath = false;
  bool _showHealthPowerup = false;

  double get groundY => size.y - boy_y;
  bool get isGrounded => boy.position.y >= groundY - 0.5;

  final backgrounds = [
    'background_night.png',
    'background_sunset.png',
    'background_day.png',
    'background_dawn.png',
  ];

  // Preloaded parallax objects for instant switching
  final Map<String, Parallax> _preloadedParallax = {};

  @override
  Future<void> onLoad() async {
    await _loadStats();

    gradientOverlay = RadialGradientOverlay()
      ..gradientColor = Colors.black
      ..opacity = 1.0
      ..priority = 999;
    add(gradientOverlay);

    hud = PositionComponent()..priority = 1000;
    camera.viewport.add(hud);

    // Preload backgrounds
    for (final bg in backgrounds) {
      _preloadedParallax[bg] = await loadParallax(
        [ParallaxImageData(bg)],
        baseVelocity: Vector2(gameSpeed, 0),
        velocityMultiplierDelta: Vector2(1, 1),
      );
    }

    // Initial background
    parallaxBackground = ParallaxComponent(
      parallax: _preloadedParallax[backgrounds[currentBackgroundIndex]]!,
    )
      ..scale = Vector2(1, 1)
      ..position = Vector2(0, 0)
      ..priority = -100;
    add(parallaxBackground);

    scoreText = TextComponent(
      text: '0',
      position: Vector2(size.x / 2, 80),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer',
        ),
      ),
    );

    // No-damage combo HUD (pill + label + value)
    noDamageHud = PositionComponent()
      ..position = Vector2(size.x / 2, 150)
      ..anchor = Anchor.center;

    noDamageHudBg = RectangleComponent(
      size: Vector2(190, 42),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0.35),
    );

    noDamageLabelText = TextComponent(
      text: 'PERFECT',
      position: Vector2(-70, 0),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 24,
          fontFamily: 'Gamer',
          fontWeight: FontWeight.normal,
          letterSpacing: 1.0,
        ),
      ),
    );

    noDamageValueText = TextComponent(
      text: '0m',
      position: Vector2(80, 0),
      anchor: Anchor.centerRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 24,
          fontFamily: 'Gamer',
          fontWeight: FontWeight.normal,
        ),
      ),
    );

    noDamageHud.add(noDamageHudBg);
    noDamageHud.add(noDamageLabelText);
    noDamageHud.add(noDamageValueText);

    playerHealthBar = HealthBar(
      maxHealth: 100,
      currentHealth: state.health.toDouble(),
      size: Vector2(100, 9),
      position: Vector2(20, size.y - 140),
    );

    enemyHealthBar = HealthBar(
      maxHealth: 100,
      currentHealth: state.ratHealth.toDouble(),
      size: Vector2(100, 9),
      position: Vector2(size.x - 20, size.y - 140),
    );

    hud.add(playerHealthBar);
    hud.add(enemyHealthBar);

    add(scoreText);
    add(noDamageHud);

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

    rat.startBounceByType();

    _attackRunner =
        AttackPatternRunner(AttackPatterns.forStage(state.level), rng: state.random);
    _activePatternStage = state.level;

    _previousSize = size.clone();

    await initAudio();

    isIntroFadingIn = true;
    introElapsed = 0.0;

    // Ensure streak UI starts correctly
    _noDamageTier = 0;
    _lastNoDamageShown = 0;
    _applyTierStyle(_noDamageTier);
    noDamageValueText.text = '0m';
  }

  @override
  void onRemove() {
    _pbLabelTimer?.cancel();
    super.onRemove();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    currentMaxDistance = prefs.getInt('maxNoDamageDistance') ?? 0;
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

  Future<void> initAudio() async {
    if (GameSettingsModel.musicOff) return;

    await FlameAudio.audioCache.load('ratrun_audio.m4a');
    FlameAudio.bgm.play('ratrun_audio.m4a', volume: 0.0);

    _musicFadeElapsed = 0.0;
    _musicFadingIn = true;
  }

  void _handleOrientationChange(Vector2 newSize) {
    if (isLandscape) {
      boy_y = 80;
      boy_x = 210;
      rat_y = 80;
      rat_x = 210;
    } else {
      boy_y = 180;
      boy_x = 10;
      rat_y = 180;
      rat_x = 100;
    }

    boy.position.y = newSize.y - boy_y;

    if (state.isLunging || boy.position.x > boy_x) {
      final relativeX = boy.position.x / _previousSize!.x;
      boy.position.x = relativeX * newSize.x;
    } else {
      boy.position.x = boy_x.toDouble();
    }

    if (rat.isMounted) {
      rat.position.x = newSize.x - rat_x;
      rat.position.y = newSize.y - rat_y;

      if (rat.animation == Animations.cheeseKnightRat ||
          rat.animation == Animations.clockworkRat) {
        rat.position.x -= 70;
        rat.position.y += 30;
      }
    }

    scoreText.position = Vector2(newSize.x / 2, 80);
    noDamageHud.position = Vector2(newSize.x / 2, 150);

    playerHealthBar.position =
        Vector2(boy_x.toDouble(), newSize.y - boy_y.toDouble() + 20);
    enemyHealthBar.position =
        Vector2(newSize.x - rat_x - 20, newSize.y - rat_y.toDouble() + 20);
  }

  int _tierFor(int meters) {
    if (meters >= 1000) return 3;
    if (meters >= 500) return 2;
    if (meters >= 200) return 1;
    return 0;
  }

  void _applyTierStyle(int tier) {
    final Color valueColor = switch (tier) {
      3 => Colors.amberAccent,
      2 => Colors.orangeAccent,
      1 => Colors.yellowAccent,
      _ => Colors.redAccent,
    };

    noDamageValueText.textRenderer = TextPaint(
      style: TextStyle(
        color: valueColor,
        fontSize: 24,
        fontFamily: 'Gamer',
        fontWeight: FontWeight.normal,
        shadows: [
          Shadow(
            color: valueColor.withOpacity(0.75),
            blurRadius: tier == 0 ? 4 : 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );

    final bgOpacity = switch (tier) {
      3 => 0.55,
      2 => 0.45,
      1 => 0.40,
      _ => 0.35,
    };

    noDamageHudBg.paint = Paint()..color = Colors.black.withOpacity(bgOpacity);
  }

void _pulseNoDamageHud() {
  // Pulse: scale up then back down once
  noDamageHud.add(
    ScaleEffect.to(
      Vector2.all(1.08),
      EffectController(
        duration: 0.10,
        alternate: true,     // goes back to start scale
        repeatCount: 2,      // forward + back
      ),
    ),
  );
}


void _breakNoDamageHud() {
  noDamageHud.add(
    MoveByEffect(
      Vector2(10, 0),
      EffectController(duration: 0.04, alternate: true, repeatCount: 4),
    ),
  );

  noDamageHud.add(
    ScaleEffect.to(
      Vector2.all(0.92),
      EffectController(duration: 0.08, alternate: true, repeatCount: 2),
    ),
  );
}

  void _flashNewPbLabel() {
    _pbLabelTimer?.cancel();
    noDamageLabelText.text = 'NEW PB!';
    noDamageLabelText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 24,
        fontFamily: 'Gamer',
        letterSpacing: 1.0,
      ),
    );
    _pulseNoDamageHud();

    _pbLabelTimer = dart_async.Timer(const Duration(milliseconds: 650), () {
      if (!noDamageLabelText.isMounted) return;
      noDamageLabelText.text = 'PERFECT';
      noDamageLabelText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 24,
          fontFamily: 'Gamer',
          letterSpacing: 1.0,
        ),
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Intro fade-in
    if (isIntroFadingIn) {
      introElapsed += dt;
      final p = (introElapsed / introDuration).clamp(0.0, 1.0);
      gradientOverlay.opacity = 1.0 - p;
      if (p >= 1.0) {
        gradientOverlay.opacity = 0.0;
        isIntroFadingIn = false;
      }
    }

    if (_musicFadingIn && !GameSettingsModel.musicOff) {
      _musicFadeElapsed += dt;
      final p = (_musicFadeElapsed / _musicFadeInDuration).clamp(0.0, 1.0);
      FlameAudio.bgm.audioPlayer.setVolume(_musicTargetVolume * p);
      if (p >= 1.0) _musicFadingIn = false;
    }

    // Distance
    state.distance += speed * dt;
    final distanceInt = state.distance.toInt();

    if (distanceInt - state.lastSavedDistance >= 25) {
      state.lastSavedDistance = distanceInt;
      _updateDistanceAchievements(distanceInt);
    }

    // No-damage streak tracking (current streak, best streak for this run)
    if (state.health == 100) {
      state.currentNoDamageStreak += speed * dt;

      if (state.currentNoDamageStreak > state.distance) {
        state.currentNoDamageStreak = state.distance;
      }

      if (state.currentNoDamageStreak > state.bestNoDamageStreak) {
        state.bestNoDamageStreak = state.currentNoDamageStreak;
      }

      final streakInt = state.currentNoDamageStreak.toInt();

      if (streakInt != _lastNoDamageShown) {
        _lastNoDamageShown = streakInt;
        noDamageValueText.text = '${streakInt}m';

        final newTier = _tierFor(streakInt);
        if (newTier != _noDamageTier) {
          _noDamageTier = newTier;
          _applyTierStyle(_noDamageTier);
          _pulseNoDamageHud();
        }
      }

      final bestInt = state.bestNoDamageStreak.toInt();
      if (bestInt - state.lastSavedNoDamageDistance >= 25) {
        state.lastSavedNoDamageDistance = bestInt;
        _updateNoDamageAchievements(bestInt);
      }
    } else {
      if (state.currentNoDamageStreak > 0) {
        _breakNoDamageHud();
      }
      state.currentNoDamageStreak = 0;
      _lastNoDamageShown = 0;
      _noDamageTier = 0;
      _applyTierStyle(_noDamageTier);
      noDamageValueText.text = '0m';
    }

    if (!state.distance.isFinite) {
      state.distance = 0;
    }

    scoreText.text = '${state.distance.toInt()}';

    // Background transitions
    if (!isTransitioning) {
      timeSinceLastTransition += dt;
      if (timeSinceLastTransition >= timeBetweenTransitions) {
        _startTransition();
        timeSinceLastTransition = 0.0;
      }
    }

    if (isTransitioning) {
      _updateTransition(dt);
    }

    // Enemy shooting (pattern-driven)
    if (rat.isMounted) {
      if (state.level != _activePatternStage) {
        _attackRunner =
            AttackPatternRunner(AttackPatterns.forStage(state.level), rng: state.random);
        _activePatternStage = state.level;
      }

      if (!rat.getAttacking()) {
        final shotsToFire = _attackRunner.tick(dt);

        if (shotsToFire > 0) {
          rat.setAttacking(true);
          final idleAnimation = rat.animation;
          rat.animation = EnemyController.getAttackAnimation(rat.enemyLevel);

          rat.animationTicker?.onComplete = () {
            rat.animation = idleAnimation;
            rat.setAttacking(false);
          };

          for (int i = 0; i < shotsToFire; i++) {
            setAttacked(rat.enemyLevel);
          }
        }
      } else {
        _attackRunner.tick(dt);
      }
    }

    // Jump physics
    final double groundYNow = size.y - boy_y;

    if (state.isJumping || boy.position.y < groundYNow) {
      state.velocityY += gravity * dt;
      boy.position.y += state.velocityY * dt;

      if (boy.position.y >= groundYNow) {
        boy.position.y = groundYNow;
        state.velocityY = 0;
      }
    }

    final bool groundedNow = boy.position.y >= groundYNow - 0.5;

    if (groundedNow && !_wasGrounded) {
      numberOfJumps = 0;
      state.isJumping = false;
    }
    _wasGrounded = groundedNow;

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

    if (isGrounded && !state.isLunging && !state.isShooting) {
      PlayerController.setRun(boy);
    }

    // Health Power Ups -> Player
    for (int i = state.healthPowerUps.length - 1; i >= 0; i--) {
      final powerUp = state.healthPowerUps[i];
      if (powerUp.isMounted && CollisionHelper.playerHitsPowerUp(boy, powerUp)) {
        powerUp.removeFromParent();
        state.healthPowerUps.removeAt(i);
        heal();
        _showHealthPowerup = false;
        AchievementManager.incrementProgress('first_heal', 1);
      }
    }

    // Player projectiles -> Enemy
    for (int i = state.projectiles.length - 1; i >= 0; i--) {
      final projectile = state.projectiles[i];
      if (rat.isMounted && CollisionHelper.projectileHitsEnemy(projectile, rat)) {
        projectile.removeFromParent();
        state.projectiles.removeAt(i);

        state.ratHealth -= 20;
        enemyHealthBar.setHealth(state.ratHealth.toDouble());
        rat.onHit();
      }
    }

    // Enemy projectiles -> Player
    for (int i = state.enemyProjectiles.length - 1; i >= 0; i--) {
      final projectile = state.enemyProjectiles[i];
      if (CollisionHelper.enemyHitsPlayer(projectile, boy)) {
        projectile.removeFromParent();
        state.enemyProjectiles.removeAt(i);

        state.health -= 20;
        playerHealthBar.setHealth(state.health.toDouble());
      }
    }

    // Cleanup PLAYER projectiles
    state.projectiles.removeWhere((p) {
      if (p.position.x > size.x + 100) {
        p.removeFromParent();
        return true;
      }
      return false;
    });

    // Cleanup ENEMY projectiles
    state.enemyProjectiles.removeWhere((p) {
      final offRight = p.position.x > size.x + 100;
      final offLeft = p.position.x < -100;
      if (offRight || offLeft) {
        p.removeFromParent();
        return true;
      }
      return false;
    });

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
        final result = GameResult(
          score: state.distance.toInt(),
          noDamageDistance: state.bestNoDamageStreak.toInt(),
        );
        onGameEnd(result);
      } catch (e) {
        onGameEnd(GameResult(score: 999999, noDamageDistance: 0));
      }
      pauseEngine();
    } else if (state.ratHealth <= 0) {
      if (_handlingRatDeath) return;
      _handlingRatDeath = true;

      AchievementManager.incrementProgress('first_kill', 1);
      AchievementManager.incrementProgress('boss_kills_10', 1);
      AchievementManager.incrementProgress('boss_kills_25', 1);
      AchievementManager.incrementProgress('boss_kills_75', 1);
      AchievementManager.incrementProgress('boss_kills_100', 1);
      AchievementManager.incrementProgress('boss_kills_150', 1);

      if (rat.isMounted) {
        remove(rat);
      }

      // Drop health power-up
      final num = state.random.nextInt(100);
      if (num < 25 && !_showHealthPowerup) {
        _showHealthPowerup = true;
        drophealthPowerUp(Vector2(boy.position.x + 130, boy.position.y - 50));
      }

      spawn();

      // Distance multiplier
      final bonus = (state.distance - ((state.level - 1) * 1000));
      state.distance += bonus;

      if (state.health == 100) {
        state.currentNoDamageStreak += bonus;

        if (state.currentNoDamageStreak > state.distance) {
          state.currentNoDamageStreak = state.distance;
        }

        if (state.currentNoDamageStreak > state.bestNoDamageStreak) {
          state.bestNoDamageStreak = state.currentNoDamageStreak;
        }

        // Update HUD immediately after bonus
        final streakInt = state.currentNoDamageStreak.toInt();
        _lastNoDamageShown = streakInt;
        noDamageValueText.text = '${streakInt}m';
      }

      _handlingRatDeath = false;
    }
  }

  void _startTransition() {
    isTransitioning = true;
    transitionElapsed = 0.0;
    _didSwitchBgThisTransition = false;
    gradientOverlay.gradientColor = Colors.black;
  }

  void _updateTransition(double dt) {
    transitionElapsed += dt;
    final progress = (transitionElapsed / transitionDuration).clamp(0.0, 1.0);

    if (progress < 0.5) {
      gradientOverlay.opacity = progress * 2.0;
    } else {
      if (!_didSwitchBgThisTransition) {
        _switchBackground();
        _didSwitchBgThisTransition = true;
      }
      gradientOverlay.opacity = 1.0 - ((progress - 0.5) * 2.0);
    }

    if (progress >= 1.0) {
      gradientOverlay.opacity = 0.0;
      isTransitioning = false;
      transitionElapsed = 0.0;
    }
  }

  void _updateDistanceAchievements(int distance) {
    if (distance > highScore) {
      highScore = distance;
      AchievementManager.setProgress('distance_100', distance);
      AchievementManager.setProgress('distance_1000', distance);
      AchievementManager.setProgress('distance_10000', distance);
      AchievementManager.setProgress('distance_50000', distance);
      AchievementManager.setProgress('distance_100000', distance);
      AchievementManager.setProgress('distance_200000', distance);
    }
  }

  void _updateNoDamageAchievements(int distance) {
    if (distance > currentMaxDistance) {
      currentMaxDistance = distance;

      AchievementManager.setProgress('no_damage_100', distance);
      AchievementManager.setProgress('no_damage_1000', distance);
      AchievementManager.setProgress('no_damage_10000', distance);
      AchievementManager.setProgress('no_damage_50000', distance);
      AchievementManager.setProgress('no_damage_100000', distance);
      AchievementManager.setProgress('no_damage_200000', distance);

      _flashNewPbLabel();
    }
  }

  void _switchBackground() {
    parallaxBackground.removeFromParent();

    currentBackgroundIndex = (currentBackgroundIndex + 1) % backgrounds.length;

    if (currentBackgroundIndex == 3) {
      scoreText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer',
        ),
      );
    } else if (currentBackgroundIndex == 1) {
      scoreText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 48,
          fontWeight: FontWeight.normal,
          fontFamily: 'Gamer',
        ),
      );
    }

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

    final projectileSprite = EnemyController.getProjectileSprite(level);

    final projectile = EnemyController.createProjectile(
      projectileSprite,
      Vector2(rat.position.x - 30, rat.position.y - 50),
      projectileSpeed,
    );

    add(projectile);
    state.enemyProjectiles.add(projectile);
  }

  void drophealthPowerUp(Vector2 position) {
    final powerUp = HealthPowerUp(
      position: position,
      animation: Animations.spinningHeart,
    );
    powerUp.scale = Vector2.all(0.8);
    add(powerUp);
    state.healthPowerUps.add(powerUp);
  }

  void heal() {
    state.health += 50;
    if (state.health > 100) {
      state.health = 100;
    }
    playerHealthBar.setHealth(state.health.toDouble());
  }

  void jump() {
    if (numberOfJumps >= maxJumps) return;
    if (numberOfJumps == 0 && !isGrounded) return;

    AchievementManager.incrementProgress('first_jump', 1);

    numberOfJumps += 1;
    state.isJumping = true;
    state.velocityY = jumpForce;

    PlayerController.setJump(boy);
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
    final character = GameSettingsModel.selectedCharacterSheet;

    final projectile = PlayerController.shoot(boy.position, character);
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
    final newMaxHp = 100 + (state.level * 50);
    state.ratHealth = newMaxHp.toDouble();

    _attackRunner =
        AttackPatternRunner(AttackPatterns.forStage(state.level), rng: state.random);
    _activePatternStage = state.level;

    enemyHealthBar.setMaxHealth(newMaxHp.toDouble());
    enemyHealthBar.setHealth(state.ratHealth.toDouble());

    final nextLevel = EnemyController.pickRandomEnemyLevel(
      state.level,
      avoidRepeats: true,
      lastLevel: state.lastEnemyLevel,
    );

    rat = EnemyController.spawnEnemy(
      size,
      rat_x,
      rat_y,
      nextLevel,
    );

    add(rat);
    rat.position.y = size.y - rat_y;
    rat.position.x = size.x - rat_x;

    if (rat.animation == Animations.cheeseKnightRat ||
        rat.animation == Animations.clockworkRat) {
      rat.scale = Vector2.all(1.5);
      rat.position.x -= 70;
      rat.position.y += 30;
      rat.flipHorizontally();
    }

    rat.startBounceByType();
    state.lastEnemyLevel = nextLevel;
  }
}

// Main widget to run the game
class MyGameWidget extends StatelessWidget {
  const MyGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StickmanRunner game = StickmanRunner(
      onGameEnd: (res) {
        Navigator.pop(context, res);
      },
    );

    final GameSettings settings = GameSettings(
      buttonSize: GameSettingsModel.buttonSize,
      leftHanded: GameSettingsModel.leftHanded,
      musicOff: GameSettingsModel.musicOff,
      selectedCharacterSheet: GameSettingsModel.selectedCharacterSheet,
      selectedActionSheet: GameSettingsModel.selectedActionSheet,
    );

    // ignore: unused_local_variable
    final _ = settings;

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
                  onPressed: () => game.shoot(),
                  heroTag: "attack",
                  child: Image.asset(
                    'assets/images/shoot_btn.png',
                    width: 70,
                    height: 70,
                  ),
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
                  onPressed: () => game.lunge(),
                  heroTag: "lunge",
                  child: Image.asset(
                    'assets/images/lunge_btn.png',
                    width: 70,
                    height: 70,
                  ),
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
                  onPressed: () => game.jump(),
                  heroTag: "jump",
                  child: Image.asset(
                    'assets/images/jmp_btn.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

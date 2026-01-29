import 'package:flame/components.dart';
import 'dart:ui';
import 'dart:math' as math;

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

  // ===== Hit FX state =====
  double _flashTimer = 0.0;
  double _flashDuration = 0.10;

  double _shakeTimer = 0.0;
  double _shakeDuration = 0.12;
  double _shakeMagnitude = 4.0; // pixels

  // Track and remove shake offset so the enemy never "drifts"
  Vector2 _currentShakeOffset = Vector2.zero();
  double _shakePhase = 0.0;

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

  void setAttacking(bool attacking) => isAttacking = attacking;
  bool getAttacking() => isAttacking;

  /// ✅ Call this when the enemy takes damage
  void onHit() {
    _flashTimer = _flashDuration;
    _shakeTimer = _shakeDuration;
    _shakePhase = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Flash countdown
    if (_flashTimer > 0) _flashTimer -= dt;

    // Remove previous shake offset first (prevents permanent movement)
    if (_currentShakeOffset.length2 != 0) {
      position -= _currentShakeOffset;
      _currentShakeOffset.setZero();
    }

    // Apply shake (temporary)
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      _shakePhase += dt * 60.0; // shake speed

      final x = math.sin(_shakePhase) * _shakeMagnitude;
      final y = math.cos(_shakePhase * 0.9) * (_shakeMagnitude * 0.35);

      _currentShakeOffset = Vector2(x, y);
      position += _currentShakeOffset;
    } else {
      _shakeTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw normally first
    super.render(canvas);

    // Strong white flash overlay by drawing again with additive blend
    if (_flashTimer > 0) {
      final t = (_flashTimer / _flashDuration).clamp(0.0, 1.0);

      final oldPaint = paint;
      paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.85 * t)
        ..blendMode = BlendMode.plus; // additive = very visible

      super.render(canvas);

      paint = oldPaint;
    }
  }
}

class Character {
  final String id;
  final String image;
  final String spriteSheetLocation;
  final String actionSheetLocation;
  final bool unlocked;

  const Character({
    required this.id,
    required this.image,
    required this.spriteSheetLocation,
    required this.actionSheetLocation,
    required this.unlocked,
  });
}

class GameCharacters {
  static const List<Character> all = [
    Character(
      id: '1',
      image: 'assets/characters/boy_.png',
      spriteSheetLocation: 'boy.png',
      actionSheetLocation: 'boy_actions.png',
      unlocked: true),
    Character(
      id: '2', 
      image: 'assets/characters/thugboy_.png', 
      spriteSheetLocation: 'thugboy.png',
      actionSheetLocation: 'thugboy_actions.png',
      unlocked: false),
    Character(
      id: '3', 
      image: 'assets/characters/dripjacket_.png', 
      spriteSheetLocation: 'dripjacket.png',
      actionSheetLocation: 'dripjacket_actions.png',
      unlocked: false),
    Character(
      id: '4', 
      image: 'assets/characters/exterminator_.png', 
      spriteSheetLocation: 'exterminator.png',
      actionSheetLocation: 'exterminator_actions.png',
      unlocked: false),
    Character(
      id: '5', 
      image: 'assets/characters/scientist_.png', 
      spriteSheetLocation: 'scientist.png',
      actionSheetLocation: 'scientist_actions.png',
      unlocked: false),
    Character(
      id: '6', 
      image: 'assets/characters/chef_.png', 
      spriteSheetLocation: 'chef.png',
      actionSheetLocation: 'chef_actions.png',
      unlocked: false),
      Character(
      id: '7', 
      image: 'assets/characters/samurai_.png', 
      spriteSheetLocation: 'samurai.png',
      actionSheetLocation: 'samurai_actions.png',
      unlocked: false),
      Character(
      id: '8', 
      image: 'assets/characters/toxic_.png', 
      spriteSheetLocation: 'toxic.png',
      actionSheetLocation: 'toxic_actions.png',
      unlocked: false),
      Character(
      id: '9', 
      image: 'assets/characters/assassin_.png', 
      spriteSheetLocation: 'assassin.png',
      actionSheetLocation: 'assassin_actions.png',
      unlocked: false),
      Character(
      id: '10', 
      image: 'assets/characters/ronin_.png', 
      spriteSheetLocation: 'ronin.png',
      actionSheetLocation: 'ronin_actions.png',
      unlocked: false),
  ];
}


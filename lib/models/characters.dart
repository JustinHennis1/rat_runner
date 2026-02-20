import 'package:cityrun/models/animations.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

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

  double _flashTimer = 0.0;
  final double _flashDuration = 0.10;

  double _shakeTimer = 0.0;
  final double _shakeDuration = 0.12;
  final double _shakeMagnitude = 4.0;

  double _shakePhase = 0.0;
  Vector2 _shakeOffset = Vector2.zero();

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

  void onHit() {
    _flashTimer = _flashDuration;
    _shakeTimer = _shakeDuration;
    _shakePhase = 0.0;
  }

  void startBounce({
    double distance = 140,
    double verticalOffset = 0,
    double seconds = 0.45,
  }) {
    // Remove existing effects
    children.whereType<Effect>().forEach((e) => e.removeFromParent());

    final start = position.clone();

    // Decide direction based on facing
    final bool facingLeft = scale.x < 0 || isFlippedHorizontally;

    final Vector2 offset =
        facingLeft ? Vector2(-distance, verticalOffset) : Vector2(distance, verticalOffset);

    add(
      MoveEffect.to(
        start + offset,
        EffectController(
          duration: seconds,
          curve: Curves.easeInOut,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  void startBounceByType() {
    double distance = 140;
    double verticalOffset = 0;
    double speed = 0.45;

    if (animation == Animations.cheeseKnightRat ||
        animation == Animations.clockworkRat) {
      distance = 90;   // heavy enemies
      speed = 0.7;
    } else if (animation == Animations.purplePoisonRat) {
      distance = 0;
      speed = 0.35;
      verticalOffset = -20;
    } else if (animation == Animations.redFireRat) {
      distance = 0;
      verticalOffset = -40;
      speed = 0.5;
    } else if (animation == Animations.blueFireRat) {
      distance = -20;
      verticalOffset = -30;
      speed = 0.6;
    }

    startBounce(distance: distance,verticalOffset: verticalOffset, seconds: speed);
  }

  @override
  void update(double dt) {
    super.update(dt); // ✅ allows effects to tick

    if (_flashTimer > 0) _flashTimer -= dt;

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      _shakePhase += dt * 60.0;

      final x = math.sin(_shakePhase) * _shakeMagnitude;
      final y = math.cos(_shakePhase * 0.9) * (_shakeMagnitude * 0.35);
      _shakeOffset = Vector2(x, y);
    } else {
      _shakeTimer = 0;
      _shakeOffset.setZero();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(_shakeOffset.x, _shakeOffset.y);

    super.render(canvas);

    if (_flashTimer > 0) {
      final t = (_flashTimer / _flashDuration).clamp(0.0, 1.0);
      final oldPaint = paint;

      paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.85 * t)
        ..blendMode = BlendMode.plus;

      super.render(canvas);
      paint = oldPaint;
    }

    canvas.restore();
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


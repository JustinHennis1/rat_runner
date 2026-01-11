import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';

class Animations {
  // Boy animation storage
  static late SpriteAnimation run;
  static late SpriteAnimation attack;
  static late SpriteAnimation block;
  static late SpriteAnimation jump;
  static late SpriteAnimation blueFireRat;
  static late SpriteAnimation redFireRat;
  static late SpriteAnimation purplePoisonRat;
  static late SpriteAnimation cheeseKnightRat;
  static late SpriteAnimation clockworkRat;
  static late SpriteAnimation blueFireRatAttacking;
  static late SpriteAnimation redFireRatAttacking;
  static late SpriteAnimation purplePoisonRatAttacking;
  static late SpriteAnimation cheeseKnightRatAttacking;
  static late SpriteAnimation clockworkRatAttacking;
  static late Sprite blueFireball;
  static late Sprite redFireball;
  static late Sprite poisonball;
  static late Sprite swordSlash;
  static late Sprite cheeseShockwave;
  static late Sprite clockworkGear;


  // Preload everything
  static Future<void> load() async {
    String character = GameSettingsModel.selectedCharacterSheet;
    // Load sheets once
    final boySheet = await Flame.images.load(character);
    final actionSheet = await Flame.images.load('boy_actions.png');
    final ratsheet = await Flame.images.load('rats.png');
    final knightSheet = await Flame.images.load('cheese_knight.png');
    final clockworkSheet = await Flame.images.load('clockwork_rat.png');
    final projectileSheet = await Flame.images.load('projectiles.png');
    final ratsize = Vector2(376, 368); // frame 1
    final ratsize2 = Vector2(376, 328); // frame 2+3
    final knightSize = Vector2(153.7, 136);
    final spriteSize = Vector2(500, 540);
    final projectileSize = Vector2(380, 380);
    final cheeseKnightSpriteSheet = SpriteSheet(
      image: knightSheet,
      srcSize: knightSize,
    );
    final clockworkSpriteSheet = SpriteSheet(
      image: clockworkSheet,
      srcSize: knightSize,
    );

    // RUN animation
    run = SpriteAnimation.fromFrameData(
      boySheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.10,
        textureSize: spriteSize,
        amountPerRow: 2,
        loop: true,
      ),
    );

    // Boy Attack Position
    attack = SpriteAnimation.fromFrameData(
      actionSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.10,
        textureSize: spriteSize,
        texturePosition: Vector2(500 * 2, 0),
        loop: false,
      ),
    );

    // Boy Block Position animation
    block = SpriteAnimation.fromFrameData(
      actionSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.10,
        textureSize: spriteSize,
        texturePosition: Vector2(0, 540),
        loop: false,
      ),
    );

    // Boy Jump Position animation
    jump = SpriteAnimation.fromFrameData(
      actionSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.10,
        textureSize: spriteSize,
        texturePosition: Vector2(500, 0),
        loop: false,
      ),
    );

    //Rat firing Position animation
    blueFireRat = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .10,
        textureSize: ratsize,
        texturePosition: Vector2(0, 0),
        loop: false,
      ),
    );

    blueFireRatAttacking = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: .10,
        textureSize: ratsize,
        texturePosition: Vector2(376, 0),
        loop: false,
      ),
    );

    //Rat firing Position animation
    redFireRat = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(0, 370),
        loop: false,
      ),
    );

    redFireRatAttacking = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(380, 370),
        loop: false,
      ),
    );

    //Rat firing Position animation
    purplePoisonRat = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(0, 368 + 328),
        loop: false,
      ),
    );

    purplePoisonRatAttacking = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(380, 368 + 328),
        loop: false,
      ),
    );

    // KNIGHT animation
    cheeseKnightRat = cheeseKnightSpriteSheet.createAnimation(
      row: 0,            // start row
      from: 0,           // start column
      to: 2,             // end frame
      stepTime: 0.50,
      loop: true,
    );
    cheeseKnightRatAttacking = cheeseKnightSpriteSheet.createAnimation(
      row: 0,            // start row
      from: 2,           // start column
      to: 4,             // end frame
      stepTime: 0.30,
      loop: false,
    );
    // CLOCKWORK RAT animation
    clockworkRat = clockworkSpriteSheet.createAnimation(
      row: 0,            // start row
      from: 0,           // start column
      to: 1,             // end frame
      stepTime: 0.30,
      loop: true,
    );
    clockworkRatAttacking = clockworkSpriteSheet.createAnimation(
      row: 0,            // start row
      from: 1,           // start column
      to: 3,             // end frame
      stepTime: 0.30,
      loop: false,
    );

    // Projectile Sprites
    blueFireball = Sprite(
        ratsheet,
        srcPosition: Vector2(380 * 3, 0),
        srcSize: projectileSize,
      );

    redFireball = Sprite(
        ratsheet,
        srcPosition: Vector2(380 * 3, 320 * 1),
        srcSize: projectileSize,
      );

    poisonball = Sprite(
        ratsheet,
        srcPosition: Vector2(380 * 3, 320 * 2),
        srcSize: projectileSize,
      );

    swordSlash = Sprite(
        projectileSheet,
        srcPosition: Vector2(153.7 * 0, 0),
        srcSize: knightSize,
      );

    clockworkGear = Sprite(
        clockworkSheet,
        srcPosition: Vector2(153.7 * 2, 136),
        srcSize: knightSize,
      );

    cheeseShockwave = Sprite(
        knightSheet,
        srcPosition: Vector2(153.7 * 3, 136 * 2),
        srcSize: knightSize,
      );

  }
}

// Radial gradient overlay that fades in/out
class RadialGradientOverlay extends PositionComponent {
  double opacity = 0.0;
  Color gradientColor = Colors.black;

  RadialGradientOverlay() {
    priority = -90; // Above background, below game elements
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;

    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x > size.y ? size.x : size.y;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        gradientColor.withOpacity(0),
        gradientColor.withOpacity(opacity * 0.7),
      ],
      stops: const [0.3, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}
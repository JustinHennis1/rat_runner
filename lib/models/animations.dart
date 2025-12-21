import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Animations {
  // Boy animation storage
  static late SpriteAnimation run;
  static late SpriteAnimation attack;
  static late SpriteAnimation block;
  static late SpriteAnimation jump;
  static late SpriteAnimation enemyFireball;
  static late SpriteAnimation enemyFireball2;
  static late SpriteAnimation enemyPoisonball;

  // Preload everything
  static Future<void> load() async {
    // Load sheets once
    final boySheet = await Flame.images.load('boy.png');
    final actionSheet = await Flame.images.load('boy_actions.png');
    final ratsheet = await Flame.images.load('rats.png');
    final ratsize = Vector2(376, 368); // frame 1
    final ratsize2 = Vector2(376, 328); // frame 2+3
    final spriteSize = Vector2(500, 540);

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

    // ATTACK animation
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

    // BLOCK animation
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

    // JUMP animation
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

    //FIREBALL animation
    enemyFireball = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: .10,
        textureSize: ratsize,
        texturePosition: Vector2(0, 0),
      ),
    );

    //FIREBALL animation
    enemyFireball2 = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(0, 368),
      ),
    );

    //FIREBALL animation
    enemyPoisonball = SpriteAnimation.fromFrameData(
      ratsheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: .10,
        textureSize: ratsize2,
        texturePosition: Vector2(0, 700),
      ),
    );
  }
}

import 'package:flame/components.dart';
import 'package:jumpnthrow/models/animations.dart';
import 'package:jumpnthrow/models/projectile.dart';

class PlayerController {
  static Projectile shoot(Vector2 position) {
    return Projectile(
      position: Vector2(position.x + 50, position.y - 50),
    );
  }

  static void setRun(SpriteAnimationComponent boy) {
    boy.animation = Animations.run;
  }

  static void setJump(SpriteAnimationComponent boy) {
    boy.animation = Animations.jump;
  }

  static void setAttack(SpriteAnimationComponent boy) {
    boy.animation = Animations.attack;
  }
}

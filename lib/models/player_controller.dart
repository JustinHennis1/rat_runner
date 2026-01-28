import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ratrunner/models/animations.dart';
import 'package:ratrunner/models/projectile.dart';

class PlayerController {
  static Projectile shoot(Vector2 position, String character) {

    switch (character) {
      case 'boy.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.yellow
        );
      case 'thugboy.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.red
        );
      case 'dripjacket.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.deepOrange
        );
      case 'exterminator.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.lime
        );
      case 'chef.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.white
        );
      case 'scientist.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.greenAccent
        );
      case 'samurai.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.blueGrey
        );
      case 'toxic.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.green
        );
      case 'assassin.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.amberAccent
        );
      case 'ronin.png':
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.teal
        );
      default:
        return Projectile(
          position: Vector2(position.x + 50, position.y - 50),
          color: Colors.yellow
        );
    }
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

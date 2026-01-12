import 'package:flame/components.dart';

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

  void setAttacking(bool attacking) {
    isAttacking = attacking;
  }
  bool getAttacking() {
    return isAttacking;
  }
}

class Character {
  final String id;
  final String image;
  final String spriteSheetLocation;
  final bool unlocked;

  const Character({
    required this.id,
    required this.image,
    required this.spriteSheetLocation,
    required this.unlocked,
  });
}

class GameCharacters {
  static const List<Character> all = [
    Character(
      id: '1',
      image: 'assets/characters/boy_.png',
      spriteSheetLocation: 'boy.png',
      unlocked: true),
    Character(
      id: '2', 
      image: 'assets/characters/thugboy_.png', 
      spriteSheetLocation: 'thugboy.png',
      unlocked: false),
    Character(
      id: '3', 
      image: 'assets/characters/dripjacket_.png', 
      spriteSheetLocation: 'dripjacket.png',
      unlocked: false),
  ];
}


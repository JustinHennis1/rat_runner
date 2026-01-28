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
      unlocked: true),
    Character(
      id: '3', 
      image: 'assets/characters/dripjacket_.png', 
      spriteSheetLocation: 'dripjacket.png',
      actionSheetLocation: 'dripjacket_actions.png',
      unlocked: true),
    Character(
      id: '4', 
      image: 'assets/characters/exterminator_.png', 
      spriteSheetLocation: 'exterminator.png',
      actionSheetLocation: 'exterminator_actions.png',
      unlocked: true),
    Character(
      id: '5', 
      image: 'assets/characters/scientist_.png', 
      spriteSheetLocation: 'scientist.png',
      actionSheetLocation: 'scientist_actions.png',
      unlocked: true),
    Character(
      id: '6', 
      image: 'assets/characters/chef_.png', 
      spriteSheetLocation: 'chef.png',
      actionSheetLocation: 'chef_actions.png',
      unlocked: true),
      Character(
      id: '7', 
      image: 'assets/characters/samurai_.png', 
      spriteSheetLocation: 'samurai.png',
      actionSheetLocation: 'samurai_actions.png',
      unlocked: true),
      Character(
      id: '8', 
      image: 'assets/characters/toxic_.png', 
      spriteSheetLocation: 'toxic.png',
      actionSheetLocation: 'toxic_actions.png',
      unlocked: true),
      Character(
      id: '9', 
      image: 'assets/characters/assassin_.png', 
      spriteSheetLocation: 'assassin.png',
      actionSheetLocation: 'assassin_actions.png',
      unlocked: true),
      Character(
      id: '10', 
      image: 'assets/characters/ronin_.png', 
      spriteSheetLocation: 'ronin.png',
      actionSheetLocation: 'ronin_actions.png',
      unlocked: true),
  ];
}


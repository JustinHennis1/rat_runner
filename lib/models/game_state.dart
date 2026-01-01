import 'dart:math';
import 'package:jumpnthrow/models/projectile.dart';

class GameState {
  // Player
  bool isJumping = false;
  bool isLunging = false;
  bool isShooting = false;

  double velocityY = 0;
  double velocityX = 0;

  double health = 100;
  double ratHealth = 100;

  // Progress
  int lastSavedDistance = 0;
  int lastSavedNoDamageDistance = 0;

  double distance = 0;
  double noDamageDistance = 0;
  int level = 1;

  // Enemy shooting
  double enemyShootTimer = 0;
  double enemyShootInterval = 2.0;
  final Random random = Random();

  // Projectiles
  final List<Projectile> projectiles = [];
  final List<EnemyProjectile> enemyProjectiles = [];
}

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:cityrun/models/projectile.dart';

class CollisionHelper {
  // Fast AABB overlap (no Rect allocations)
  static bool _aabbOverlap(
    double ax, double ay, double aw, double ah,
    double bx, double by, double bw, double bh,
  ) {
    return ax < bx + bw &&
        ax + aw > bx &&
        ay < by + bh &&
        ay + ah > by;
  }

  // Optional cheap early-out: if centers too far apart, skip AABB
  static bool _quickReject(
    double ax, double ay, double aw, double ah,
    double bx, double by, double bw, double bh,
    double padding,
  ) {
    final acx = ax + aw * 0.5;
    final acy = ay + ah * 0.5;
    final bcx = bx + bw * 0.5;
    final bcy = by + bh * 0.5;

    final dx = acx - bcx;
    final dy = acy - bcy;

    // squared distance compare (no sqrt)
    final maxD = (aw + bw) * 0.5 + padding;
    return (dx * dx + dy * dy) > (maxD * maxD);
  }

  static bool projectileHitsEnemy(
    Projectile projectile,
    SpriteAnimationComponent target,
  ) {
    // projectile bounds
    final px = projectile.position.x;
    final py = projectile.position.y;
    final pw = projectile.size.x;
    final ph = projectile.size.y;

    // target bounds (your tuned hitbox)
    final tx = target.position.x + target.size.x * 0.2;
    final ty = target.position.y - 70;
    final tw = target.size.x * 0.6;
    final th = target.size.y * 0.6;

    // Quick reject reduces overlap checks when far away
    if (_quickReject(px, py, pw, ph, tx, ty, tw, th, 80)) return false;

    return _aabbOverlap(px, py, pw, ph, tx, ty, tw, th);
  }

static bool playerHitsPowerUp(
  SpriteAnimationComponent player,
  SpriteAnimationComponent target,
) {
  // Convert "position" to top-left using anchor
  final ex = player.position.x - player.size.x * player.anchor.x;
  final ey = player.position.y - player.size.y * player.anchor.y;
  final ew = player.size.x;
  final eh = player.size.y;

  final tx0 = target.position.x - target.size.x * target.anchor.x;
  final ty0 = target.position.y - target.size.y * target.anchor.y;

  // Your tuned target hitbox (relative to its top-left)
  final tx = tx0 + target.size.x * 0.2;
  final ty = ty0;
  final tw = target.size.x * 0.6;
  final th = target.size.y * 0.6;

  return ex < tx + tw &&
      ex + ew > tx &&
      ey < ty + th &&
      ey + eh > ty;
}

  static bool enemyHitsPlayer(
    EnemyProjectile projectile,
    SpriteAnimationComponent target,
  ) {
    // enemy projectile hitbox (your tuned hitbox)
    final ex = projectile.position.x - 35;
    final ey = projectile.position.y - 10;
    final ew = projectile.size.x * 0.4;
    final eh = projectile.size.y * 0.4;

    // player hitbox (your tuned hitbox)
    final tx = target.position.x + target.size.x * 0.25;
    final ty = target.position.y - 70;
    final tw = target.size.x * 0.5;
    final th = target.size.y * 0.6;

    if (_quickReject(ex, ey, ew, eh, tx, ty, tw, th, 80)) return false;

    return _aabbOverlap(ex, ey, ew, eh, tx, ty, tw, th);
  }
}

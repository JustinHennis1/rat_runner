import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/characters.dart';

enum AchievementRewardType {
  unlockCharacter,
  unlockAnimation,
  unlockSkin,
  unlockProjectile,
  currency,
}

class AchievementReward {
  final AchievementRewardType type;
  final String id; // characterId, animationId, etc.
  final int amount; // used for currency, optional for others

  const AchievementReward({
    required this.type,
    required this.id,
    this.amount = 0,
  });
}




class AchievementRewardPreview extends StatelessWidget {
  final AchievementReward reward;
  final bool unlocked;

  const AchievementRewardPreview({
    super.key,
    required this.reward,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? Colors.amber : Colors.grey.shade600;

    // 🧍 CHARACTER PORTRAIT REWARD
    if (reward.type == AchievementRewardType.unlockCharacter) {
      final character = GameCharacters.all.firstWhere(
        (c) => c.id == reward.id,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: ColorFiltered(
              colorFilter: unlocked
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    )
                  : ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  character.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Character',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // 🔁 FALLBACK FOR OTHER REWARD TYPES
    IconData icon;
    String label;

    switch (reward.type) {
      case AchievementRewardType.unlockSkin:
        icon = Icons.brush;
        label = 'Skin';
        break;
      case AchievementRewardType.unlockAnimation:
        icon = Icons.movie;
        label = 'Anim';
        break;
      case AchievementRewardType.unlockProjectile:
        icon = Icons.flash_on;
        label = 'Projectile';
        break;
      case AchievementRewardType.currency:
        icon = Icons.monetization_on;
        label = '${reward.amount}';
        break;
      default:
        icon = Icons.card_giftcard;
        label = '';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

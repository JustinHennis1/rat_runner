import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/characters.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final bool selected;
  final VoidCallback onTap;

  const CharacterTile({
    super.key,
    required this.character,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.amber : Colors.white24,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: character.unlocked
                  // ✅ Unlocked: no filter at all
                  ? Image.asset(
                      character.image,
                      fit: BoxFit.cover,
                    )
                  // 🔒 Locked: grayscale ONLY
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: Image.asset(
                        character.image,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),

          // 🔒 Lock overlay
          if (!character.unlocked)
            const Icon(
              Icons.lock,
              color: Colors.white,
              size: 28,
            ),
        ],
      ),
    );
  }
}

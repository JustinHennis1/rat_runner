import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/character_tile.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';
import 'package:jumpnthrow/views/settings.dart';

class PlayerCustomizationPage extends StatefulWidget {
  const PlayerCustomizationPage({super.key});

  @override
  State<PlayerCustomizationPage> createState() =>
      _PlayerCustomizationPageState();
}

class _PlayerCustomizationPageState extends State<PlayerCustomizationPage> {
  final List<Character> characters = [
    Character(
      id: '1',
      image: 'assets/characters/boy_.png',
      spriteSheetLocation: 'boy.png',
      unlocked: true),
    Character(
      id: '2', 
      image: 'assets/characters/thugboy_.png', 
      spriteSheetLocation: 'thugboy.png',
      unlocked: true),
    Character(
      id: '3', 
      image: 'assets/characters/dripjacket_.png', 
      spriteSheetLocation: 'dripjacket.png',
      unlocked: true),
    Character(
      id: '4', 
      image: 'assets/characters/char4.png', 
      spriteSheetLocation: 'char4.png',
      unlocked: true),
  ];

  late Character selectedCharacter;

  @override
  void initState() {
    super.initState();
    
    selectedCharacter =   characters.firstWhere(
      (character) => character.spriteSheetLocation == GameSettingsModel.selectedCharacterSheet,
      orElse: () => characters[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Player'),
        backgroundColor: Colors.black,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌌 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_night.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🎮 UI
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70),

                // 🧍 MAIN CHARACTER DISPLAY
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        selectedCharacter.image,
                        key: ValueKey(selectedCharacter.id),
                        height: 260,
                      ),
                    ),
                  ),
                ),

                // 🧩 CHARACTER SELECTOR
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: characters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        final isSelected =
                            character.id == selectedCharacter.id;

                        return CharacterTile(
                          character: character,
                          selected: isSelected,
                          onTap: () {
                            if (!character.unlocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Unlock this character first!'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              selectedCharacter = character;
                              GameSettingsModel.selectedCharacterSheet = character.spriteSheetLocation;
                            });
                            GameSettingsService.saveCharacter(
                              GameSettings(
                                buttonSize: GameSettingsModel.buttonSize,
                                leftHanded: GameSettingsModel.leftHanded,
                                selectedCharacterSheet: character.spriteSheetLocation,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

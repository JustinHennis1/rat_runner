import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:jumpnthrow/models/character_tile.dart';
import 'package:jumpnthrow/models/character_manager.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';
import 'package:jumpnthrow/views/settings.dart';

class PlayerCustomizationPage extends StatefulWidget {
  const PlayerCustomizationPage({super.key});

  @override
  State<PlayerCustomizationPage> createState() =>
      _PlayerCustomizationPageState();
}

class _PlayerCustomizationPageState extends State<PlayerCustomizationPage> {
  Character? selectedCharacter;

  @override
  void initState() {
    super.initState();

    // Load unlocks once
    CharacterManager().loadUnlockedCharacters().then((_) {
      final characters = CharacterManager().characters;

      setState(() {
        selectedCharacter = characters.firstWhere(
          (c) =>
              c.spriteSheetLocation ==
              GameSettingsModel.selectedCharacterSheet,
          orElse: () => characters.first,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CharacterManager(),
      builder: (context, _) {
        final characters = CharacterManager().characters;

        // Ensure selected character stays in sync
        if (selectedCharacter == null && characters.isNotEmpty) {
          selectedCharacter = characters.first;
        }

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

                    // DEBUG UNLOCK BUTTON
                    ElevatedButton(
                      onPressed: () {
                        CharacterManager().unlockCharacter('2');
                      },
                      child: const Text('Unlock Character 2'),
                    ),

                    // 🧍 MAIN CHARACTER DISPLAY
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: selectedCharacter == null
                              ? const CircularProgressIndicator()
                              : Image.asset(
                                  selectedCharacter!.image,
                                  key: ValueKey(selectedCharacter!.id),
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
                          padding: const EdgeInsets.all(16),
                          itemCount: characters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final character = characters[index];
                            final isSelected =
                                selectedCharacter?.id == character.id;

                            return CharacterTile(
                              character: character,
                              selected: isSelected,
                              onTap: () {
                                if (!character.unlocked) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Unlock this character first!'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  selectedCharacter = character;
                                  GameSettingsModel
                                          .selectedCharacterSheet =
                                      character.spriteSheetLocation;
                                });

                                GameSettingsService.saveCharacter(
                                  GameSettings(
                                    buttonSize:
                                        GameSettingsModel.buttonSize,
                                    leftHanded:
                                        GameSettingsModel.leftHanded,
                                    selectedCharacterSheet:
                                        character.spriteSheetLocation,
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
      },
    );
  }
}

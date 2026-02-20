import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:cityrun/models/game_settings_model.dart';

class SettingsPage extends StatefulWidget {
  final double buttonSize;
  final bool leftHanded;
  final bool musicOff;
  final String selectedCharacterSheet;
  final String selectedActionSheet;
  SettingsPage({super.key, 
                required this.buttonSize, 
                required this.leftHanded, 
                required this.musicOff,
                required this.selectedCharacterSheet, 
                required this.selectedActionSheet
                });

  @override
  _GameSettingsState createState() => _GameSettingsState();
}

class _GameSettingsState extends State<SettingsPage> {
  double buttonSize = GameSettingsModel.buttonSize;
  bool leftHanded = GameSettingsModel.leftHanded;
  bool musicOff = GameSettingsModel.musicOff;

  Future<void> shutOffMusic() async {
    if (!GameSettingsModel.musicOff) return;

    await FlameAudio.audioCache.load('ratrun_audio.m4a');

    FlameAudio.bgm.stop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_night.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Button Size: ${buttonSize.toInt()}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Slider(
                              value: buttonSize,
                              min: 60,
                              max: 120,
                              onChanged: (value) {
                                setState(() => buttonSize = value);
                              },
                            ),
                            const SizedBox(height: 40),
                            SwitchListTile(
                              title: const Text(
                                "Left-Handed Mode",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              value: leftHanded,
                              onChanged: (value) {
                                setState(() => leftHanded = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 40),
                            SwitchListTile(
                              title: const Text(
                                "Music Off",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              value: musicOff,
                              onChanged: (value) {
                                setState(() => musicOff = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll<Color>(Colors.white),
                          padding: WidgetStatePropertyAll<EdgeInsets>(
                            const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 22.5),
                          ),
                        ),
                        onPressed: () async{
                          GameSettingsModel.buttonSize = buttonSize;
                          GameSettingsModel.leftHanded = leftHanded;
                          GameSettingsModel.musicOff = musicOff;

                          await GameSettingsService.saveSettings(
                            GameSettings(
                              buttonSize: buttonSize,
                              leftHanded: leftHanded,
                              musicOff: musicOff,
                              selectedCharacterSheet: widget.selectedCharacterSheet,
                              selectedActionSheet: widget.selectedActionSheet,
                            ),
                          );

                          if (musicOff) {
                            await shutOffMusic();
                          }
                          
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ],
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

class GameSettings {
  final double buttonSize;
  final bool leftHanded;
  final bool musicOff;
  final String selectedCharacterSheet;
  final String selectedActionSheet;

  GameSettings({
    required this.buttonSize,
    required this.leftHanded,
    required this.musicOff,
    required this.selectedCharacterSheet,
    required this.selectedActionSheet,
  });

  GameSettings copyWith({
    double? buttonSize,
    bool? leftHanded,
    bool? musicOff,
    String? selectedCharacterSheet,
    String? selectedActionSheet,
  }) {
    return GameSettings(
      buttonSize: buttonSize ?? this.buttonSize,
      leftHanded: leftHanded ?? this.leftHanded,
      musicOff: musicOff ?? this.musicOff,
      selectedCharacterSheet:
          selectedCharacterSheet ?? this.selectedCharacterSheet,
      selectedActionSheet:
          selectedActionSheet ?? this.selectedActionSheet
    );
  }
}

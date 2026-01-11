import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';

class SettingsPage extends StatefulWidget {
  final double buttonSize;
  final bool leftHanded;
  final String selectedCharacterSheet;
  SettingsPage({super.key, required this.buttonSize, required this.leftHanded, required this.selectedCharacterSheet});

  @override
  _GameSettingsState createState() => _GameSettingsState();
}

class _GameSettingsState extends State<SettingsPage> {
  double buttonSize = GameSettingsModel.buttonSize;
  bool leftHanded = GameSettingsModel.leftHanded;

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
                        ],
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

                          await GameSettingsService.saveSettings(
                            GameSettings(
                              buttonSize: buttonSize,
                              leftHanded: leftHanded,
                              selectedCharacterSheet: widget.selectedCharacterSheet,
                            ),
                          );
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
  final String selectedCharacterSheet;

  GameSettings({
    required this.buttonSize,
    required this.leftHanded,
    required this.selectedCharacterSheet,
  });

  GameSettings copyWith({
    double? buttonSize,
    bool? leftHanded,
    String? selectedCharacterSheet,
  }) {
    return GameSettings(
      buttonSize: buttonSize ?? this.buttonSize,
      leftHanded: leftHanded ?? this.leftHanded,
      selectedCharacterSheet:
          selectedCharacterSheet ?? this.selectedCharacterSheet,
    );
  }
}

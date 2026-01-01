import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';

class GameSettings extends StatefulWidget {
  const GameSettings({super.key});

  @override
  _GameSettingsState createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 32, color: Colors.red),
                        onPressed: () {
                          GameSettingsModel.buttonSize = buttonSize;
                          GameSettingsModel.leftHanded = leftHanded;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
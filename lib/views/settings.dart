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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 32, color: Colors.red),
          onPressed: () {
            // Save on exit
            GameSettingsModel.buttonSize = buttonSize;
            GameSettingsModel.leftHanded = leftHanded;
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("Button Size: ${buttonSize.toInt()}"),
                Slider(
                  value: buttonSize,
                  min: 60,
                  max: 120,
                  onChanged: (value) {
                    setState(() => buttonSize = value);
                  },
                ),
                SwitchListTile(
                  title: const Text("Left-Handed Mode"),
                  value: leftHanded,
                  onChanged: (value) {
                    setState(() => leftHanded = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

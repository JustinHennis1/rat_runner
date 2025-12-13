import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends StatefulWidget {
  const GameSettings({super.key});

  @override
  _GameSettingsState createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 32, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

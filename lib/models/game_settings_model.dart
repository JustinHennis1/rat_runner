import 'package:ratrunner/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettingsModel {
  static double buttonSize = 80;
  static bool leftHanded = false;
  static bool musicOff = false;
  static String selectedCharacterSheet = 'boy.png';
  static String selectedActionSheet = 'boy_actions.png';
}

class GameSettingsService {
  static const _buttonSizeKey = 'buttonSize';
  static const _leftHandedKey = 'leftHanded';
  static const _characterKey = 'characterSheet';
  static const _actionKey = 'actionSheet';

  static Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return GameSettings(
      buttonSize: prefs.getDouble(_buttonSizeKey) ?? 80,
      leftHanded: prefs.getBool(_leftHandedKey) ?? false,
      musicOff: prefs.getBool('musicOff') ?? false,
      selectedCharacterSheet:
          prefs.getString(_characterKey) ?? 'boy.png',
      selectedActionSheet:
          prefs.getString(_actionKey) ?? 'boy_actions.png',
    );
  }

  static Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_buttonSizeKey, settings.buttonSize);
    await prefs.setBool(_leftHandedKey, settings.leftHanded);
    await prefs.setBool('musicOff', settings.musicOff);
  }

  static Future<void> saveCharacter(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_characterKey, settings.selectedCharacterSheet);
    await prefs.setString(_actionKey, settings.selectedActionSheet);
  }
}
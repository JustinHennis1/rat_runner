import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/characters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterManager extends ChangeNotifier {
  static final CharacterManager _instance = CharacterManager._internal();
  factory CharacterManager() => _instance;
  CharacterManager._internal();

  static const String _unlockedCharactersKey = 'unlocked_characters';

  final List<Character> _characters =
      GameCharacters.all.map((c) => c).toList();

  List<Character> get characters => List.unmodifiable(_characters);

  /// ----------------------------
  /// LOAD UNLOCKED CHARACTERS
  /// ----------------------------
  Future<void> loadUnlockedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList(_unlockedCharactersKey) ?? [];

    bool changed = false;

    for (int i = 0; i < _characters.length; i++) {
      if (unlocked.contains(_characters[i].id) &&
          !_characters[i].unlocked) {
        final c = _characters[i];
        _characters[i] = Character(
          id: c.id,
          image: c.image,
          spriteSheetLocation: c.spriteSheetLocation,
          unlocked: true,
        );
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  /// ----------------------------
  /// UNLOCK CHARACTER
  /// ----------------------------
  Future<void> unlockCharacter(String id) async {
    final index = _characters.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final c = _characters[index];
    if (c.unlocked) return; // prevent double work

    _characters[index] = Character(
      id: c.id,
      image: c.image,
      spriteSheetLocation: c.spriteSheetLocation,
      unlocked: true,
    );

    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList(_unlockedCharactersKey) ?? [];
    if (!unlocked.contains(id)) {
      unlocked.add(id);
      await prefs.setStringList(_unlockedCharactersKey, unlocked);
    }

    notifyListeners(); // 🔥 THIS triggers UI updates
  }
}

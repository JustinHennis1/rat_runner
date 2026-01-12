import 'package:shared_preferences/shared_preferences.dart';

class DebugTools {
  static Future<void> resetAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:jumpnthrow/models/achievements.dart';

class AchievementManager {
  static const String _progressPrefix = 'achievement_progress_';
  static const String _unlockedKey = 'unlocked_achievements';

  /// ----------------------------
  /// LOADERS
  /// ----------------------------

  /// Returns map of achievementId -> current progress
  static Future<Map<String, int>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> progress = {};

    for (final achievement in Achievements.all) {
      progress[achievement.id] =
          prefs.getInt('$_progressPrefix${achievement.id}') ?? 0;
    }

    return progress;
  }

  /// Returns set of unlocked achievement IDs
  static Future<Set<String>> loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unlockedKey) ?? [];
    return list.toSet();
  }

  /// ----------------------------
  /// UPDATERS
  /// ----------------------------

  /// Increment progress safely (distance, runs, kills, etc.)
  static Future<void> incrementProgress(
    String achievementId,
    int amount,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final achievement =
        Achievements.all.firstWhere((a) => a.id == achievementId);

    final key = '$_progressPrefix$achievementId';
    final current = prefs.getInt(key) ?? 0;

    final updated = (current + amount).clamp(0, achievement.goal);
    await prefs.setInt(key, updated);

    if (updated >= achievement.goal) {
      await _unlockAchievement(achievementId);
    }
  }

  /// Set progress directly (useful for distance tracking)
  static Future<void> setProgress(
    String achievementId,
    int value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final achievement =
        Achievements.all.firstWhere((a) => a.id == achievementId);

    final clamped = value.clamp(0, achievement.goal);
    await prefs.setInt(
      '$_progressPrefix$achievementId',
      clamped,
    );

    if (clamped >= achievement.goal) {
      await _unlockAchievement(achievementId);
    }
  }

  /// ----------------------------
  /// UNLOCK LOGIC
  /// ----------------------------

  static Future<void> _unlockAchievement(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final unlocked = prefs.getStringList(_unlockedKey) ?? [];

    if (!unlocked.contains(id)) {
      unlocked.add(id);
      await prefs.setStringList(_unlockedKey, unlocked);
    }
  }

  /// ----------------------------
  /// HELPERS
  /// ----------------------------

  static Future<bool> isUnlocked(String id) async {
    final unlocked = await loadUnlockedAchievements();
    return unlocked.contains(id);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();

    for (final achievement in Achievements.all) {
      await prefs.remove('$_progressPrefix${achievement.id}');
    }

    await prefs.remove(_unlockedKey);
  }
}

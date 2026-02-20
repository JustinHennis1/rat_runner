import 'dart:async' as dart_async;

import 'package:cityrun/models/achievement_reward.dart';
import 'package:cityrun/models/character_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cityrun/models/achievements.dart';

class AchievementManager {
  static const String _progressPrefix = 'achievement_progress_';
  static const String _unlockedKey = 'unlocked_achievements';

  /// ----------------------------
  /// IN-MEMORY CACHE (prevents lag)
  /// ----------------------------
  static bool _initialized = false;
  static SharedPreferences? _prefs;

  // Cached progress values (achievementId -> progress)
  static final Map<String, int> _progressCache = {};

  // Cached unlocked set
  static final Set<String> _unlockedCache = {};

  // Dirty keys that need to be written to prefs
  static final Set<String> _dirtyProgress = {};
  static bool _dirtyUnlocked = false;

  // Debounce writes so spam input won't stutter
  static dart_async.Timer? _flushTimer;

  static const _flushDelay = Duration(milliseconds: 350);

  /// Call this once early (MainMenu.initState is perfect),
  /// OR it will auto-init on first use.
  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    // load unlocked
    final list = _prefs!.getStringList(_unlockedKey) ?? [];
    _unlockedCache
      ..clear()
      ..addAll(list);

    // load progress for all achievements
    _progressCache.clear();
    for (final a in Achievements.all) {
      _progressCache[a.id] = _prefs!.getInt('$_progressPrefix${a.id}') ?? 0;
    }

    _initialized = true;
  }

  static Future<void> _ensureInit() async {
    if (!_initialized) {
      await init();
    }
  }

  static void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = dart_async.Timer(_flushDelay, () {
      flush(); // fire and forget
    });
  }

  /// Force-write any pending cached changes to SharedPreferences.
  /// Call this on game end (best), app pause, etc.
  static Future<void> flush() async {
    await _ensureInit();
    final prefs = _prefs!;

    // Write progress
    for (final id in _dirtyProgress) {
      final key = '$_progressPrefix$id';
      final val = _progressCache[id] ?? 0;
      await prefs.setInt(key, val);
    }
    _dirtyProgress.clear();

    // Write unlocked
    if (_dirtyUnlocked) {
      await prefs.setStringList(_unlockedKey, _unlockedCache.toList());
      _dirtyUnlocked = false;
    }
  }

  /// ----------------------------
  /// LOADERS (read from cache)
  /// ----------------------------

  static Future<Map<String, int>> loadProgress() async {
    await _ensureInit();
    return Map<String, int>.from(_progressCache);
  }

  static Future<Set<String>> loadUnlockedAchievements() async {
    await _ensureInit();
    return Set<String>.from(_unlockedCache);
  }

  /// ----------------------------
  /// UPDATERS (update cache, not disk)
  /// ----------------------------

  static Future<void> incrementProgress(String achievementId, int amount) async {
    await _ensureInit();

    final achievement = Achievements.all.firstWhere((a) => a.id == achievementId);

    final current = _progressCache[achievementId] ?? 0;
    final updated = (current + amount).clamp(0, achievement.goal);

    if (updated == current) return;

    _progressCache[achievementId] = updated;
    _dirtyProgress.add(achievementId);
    _scheduleFlush();

    if (updated >= achievement.goal) {
      await _unlockAchievement(achievementId);
    }
  }

  static Future<void> setProgress(String achievementId, int value) async {
    await _ensureInit();

    final achievement = Achievements.all.firstWhere((a) => a.id == achievementId);
    final clamped = value.clamp(0, achievement.goal);

    final current = _progressCache[achievementId] ?? 0;
    if (clamped == current) return;

    _progressCache[achievementId] = clamped;
    _dirtyProgress.add(achievementId);
    _scheduleFlush();

    if (clamped >= achievement.goal) {
      await _unlockAchievement(achievementId);
    }
  }

  /// ----------------------------
  /// UNLOCK LOGIC (cached)
  /// ----------------------------

  static Future<void> _unlockAchievement(String id) async {
    await _ensureInit();

    if (_unlockedCache.contains(id)) return;

    _unlockedCache.add(id);
    _dirtyUnlocked = true;
    _scheduleFlush();

    final ach = Achievements.getById(id);
    onAchievementUnlocked(ach);
  }

  static void onAchievementUnlocked(Achievement achievement) {
    final reward = achievement.reward;
    if (reward == null) return;

    switch (reward.type) {
      case AchievementRewardType.unlockCharacter:
        CharacterManager().unlockCharacter(reward.id);
        break;

      case AchievementRewardType.unlockAnimation:
        break;

      case AchievementRewardType.unlockSkin:
        break;

      case AchievementRewardType.unlockProjectile:
        break;

      case AchievementRewardType.currency:
        break;
    }
  }

  /// ----------------------------
  /// HELPERS
  /// ----------------------------

  static Future<bool> isUnlocked(String id) async {
    await _ensureInit();
    return _unlockedCache.contains(id);
  }

  static Future<void> resetAll() async {
    await _ensureInit();
    final prefs = _prefs!;

    for (final a in Achievements.all) {
      await prefs.remove('$_progressPrefix${a.id}');
    }
    await prefs.remove(_unlockedKey);

    _progressCache.clear();
    _unlockedCache.clear();
    _dirtyProgress.clear();
    _dirtyUnlocked = false;
  }
}

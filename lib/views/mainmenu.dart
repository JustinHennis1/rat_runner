import 'package:flutter/material.dart';
import 'package:ratrunner/models/achievement_manager.dart';
import 'package:ratrunner/models/character_manager.dart';
import 'package:ratrunner/models/game_settings_model.dart';
import 'package:ratrunner/tools/debug.dart';
import 'package:ratrunner/views/achievementsPage.dart';
import 'package:ratrunner/views/game.dart';
import 'package:ratrunner/views/menu.dart';
import 'package:ratrunner/views/playerCustomizationPage.dart';
import 'package:ratrunner/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  int highScore = 0;
  Set<String> unlockedAchievements = {};
  Map<String, int> achievementProgress = {};

  late final AnimationController _startCtrl;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    //DebugTools.resetAllPreferences(); // Uncomment to reset preferences for testing
    _loadStats();
    _loadSettings();

    _startCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await AchievementManager.loadUnlockedAchievements();
    final progress = await AchievementManager.loadProgress();
    await CharacterManager().loadUnlockedCharacters();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
      unlockedAchievements = unlocked;
      achievementProgress = progress;
    });
  }

  Future<void> _loadSettings() async {
    final settings = await GameSettingsService.load();
    setState(() {
      GameSettingsModel.buttonSize = settings.buttonSize;
      GameSettingsModel.leftHanded = settings.leftHanded;
      GameSettingsModel.selectedCharacterSheet = settings.selectedCharacterSheet;
      GameSettingsModel.selectedActionSheet = settings.selectedActionSheet;
    });
  }

  Future<void> _startGame() async {
    if (_starting) return;
    setState(() => _starting = true);

    await _startCtrl.forward();

    // Navigate to the game and wait for the final score
    final score = await Navigator.push<int>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MyGameWidget(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // Reset menu animation when we come back
    _startCtrl.reset();
    if (mounted) setState(() => _starting = false);

    // Save new high score if needed
    if (score != null) {
      final prefs = await SharedPreferences.getInstance();
      final currentHigh = prefs.getInt('highScore') ?? 0;
      if (score > currentHigh) {
        await prefs.setInt('highScore', score);
      }
      _loadStats();
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinueMenu(lastscore: score),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final screenW = MediaQuery.sizeOf(context).width;

    // Curves (feel nicer than linear)
    final t = CurvedAnimation(parent: _startCtrl, curve: Curves.easeInOutCubic);

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

          // Top-left customization button - also fade out when starting (optional)
          Positioned(
            top: 64,
            left: 12,
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(t),
              child: IgnorePointer(
                ignoring: _starting,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlayerCustomizationPage()),
                    );
                  },
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(24),
                      topLeft: Radius.circular(24),
                    ),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                  elevation: 0,
                  highlightElevation: 0,
                  child: const Icon(Icons.person, size: 32, color: Colors.white),
                ),
              ),
            ),
          ),

          SafeArea(
            minimum: isLandscape ? const EdgeInsets.only(right: 32.0) : EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // High score row (leave it visible, or fade it too if you want)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      // kept your icon + score below with a little change for const safety
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.run_circle_outlined, color: Colors.white, size: 42),
                      Text(
                        ' $highScore',
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Title panel
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: Stack(
                      children: [
                        FadeTransition(
                          opacity: Tween<double>(begin: 1, end: 0).animate(t),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/pgdesign.png'),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: t,
                          builder: (context, _) {
                            // Slide Rat left, Run right
                            final ratDx = -screenW * t.value; // off-screen left
                            final runDx = screenW * t.value;  // off-screen right

                            final ratStyle = TextStyle(
                              fontSize: isLandscape ? 60 : 120,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Gamer',
                            );

                            final runStyle = TextStyle(
                              fontSize: isLandscape ? 60 : 120,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Gamer',
                              fontStyle: FontStyle.normal,
                            );

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: isLandscape
                                      ? [
                                          Transform.translate(
                                            offset: Offset(ratDx, 0),
                                            child: Text('Rat', style: ratStyle),
                                          ),
                                        ]
                                      : [
                                          Transform.translate(
                                            offset: Offset(ratDx, 0),
                                            child: Text('Rat', style: ratStyle),
                                          ),
                                          const SizedBox(width: 50),
                                        ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: isLandscape
                                      ? [
                                          Transform.translate(
                                            offset: Offset(runDx, 0),
                                            child: Text('Run', style: runStyle),
                                          ),
                                        ]
                                      : [
                                          const SizedBox(width: 50),
                                          Transform.translate(
                                            offset: Offset(runDx, 0),
                                            child: Text('Run', style: runStyle),
                                          ),
                                        ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom buttons fade away
                FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(t),
                  child: IgnorePointer(
                    ignoring: _starting,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[900]!),
                              shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AchievementsPage(
                                    unlockedAchievements: unlockedAchievements,
                                    progress: achievementProgress,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.add_chart, size: 36, color: Colors.white),
                            ),
                          ),

                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[900]!),
                              shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                            ),
                            onPressed: _startGame, // ✅ play triggers transition
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Play',
                                style: TextStyle(fontSize: 34, color: Colors.white, fontFamily: 'Gamer'),
                              ),
                            ),
                          ),

                          ElevatedButton(
                            style: ButtonStyle(
                              shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(24),
                                    topLeft: Radius.circular(24),
                                  ),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[900]!),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                    buttonSize: GameSettingsModel.buttonSize,
                                    leftHanded: GameSettingsModel.leftHanded,
                                    musicOff: GameSettingsModel.musicOff,
                                    selectedCharacterSheet: GameSettingsModel.selectedCharacterSheet,
                                    selectedActionSheet: GameSettingsModel.selectedActionSheet,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.settings, size: 36, color: Colors.white),
                            ),
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

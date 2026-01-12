import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/achievement_manager.dart';
import 'package:jumpnthrow/models/character_manager.dart';
import 'package:jumpnthrow/models/game_settings_model.dart';
import 'package:jumpnthrow/tools/debug.dart';
import 'package:jumpnthrow/views/achievementsPage.dart';
import 'package:jumpnthrow/views/game.dart';
import 'package:jumpnthrow/views/menu.dart';
import 'package:jumpnthrow/views/playerCustomizationPage.dart';
import 'package:jumpnthrow/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int highScore = 0;
  Set<String> unlockedAchievements = {};
  Map<String, int> achievementProgress = {};

  @override
  void initState() {
    super.initState();
    //DebugTools.resetAllPreferences(); // Uncomment to reset preferences for testing
    _loadStats();
    _loadSettings();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_night.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 64, // adjust to sit under high score
            left: 12,
            child: FloatingActionButton(
              onPressed: () { Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlayerCustomizationPage())); },
              backgroundColor: Colors.grey[900],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
              ),
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          SafeArea(
            minimum: isLandscape
                ? EdgeInsets.only(right: 32.0)
                : EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.run_circle_outlined,color: Colors.white, size: 42,),
                      Text(
                        ' $highScore',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 350),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/pgdesign.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: isLandscape
                                  ? [
                                      Text(
                                        'Rat',
                                        style: TextStyle(
                                          fontSize: 60,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Gamer',
                                        ),
                                      ),
                                    ]
                                  : [
                                      Text(
                                        'Rat',
                                        style: TextStyle(
                                          fontSize: 120,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Gamer',
                                        ),
                                      ),
                                      SizedBox(width: 50),
                                    ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: isLandscape
                                  ? [
                                      Text(
                                        'Run',
                                        style: TextStyle(
                                          fontSize: 60,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Gamer',
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ]
                                  : [
                                      SizedBox(width: 50),
                                      Text(
                                        'Run',
                                        style: TextStyle(
                                          fontSize: 120,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Gamer',
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.grey[900]!),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                topRight: Radius.circular(24)
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.add_chart, size: 36, color: Colors.white,),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.grey[900]!),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all( Radius.circular(12) ),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to the game and wait for the final score
                          final score = await Navigator.push<int>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyGameWidget(),
                            ),
                          );

                          // Save new high score if needed
                          if (score != null) {
                            final prefs = await SharedPreferences.getInstance();
                            int currentHigh = prefs.getInt('highScore') ?? 0;
                            if (score > currentHigh) {
                              await prefs.setInt('highScore', score);
                            }
                            // testing reset highscore
                            //await prefs.setInt('highScore', 0);
                            _loadStats(); // Refresh displayed high score
                          }

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ContinueMenu(lastscore: score),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Play',
                            style: TextStyle(fontSize: 34, color: Colors.white, fontFamily: 'Gamer'),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(24),
                                topLeft: Radius.circular(24),
                              ),
                            ),
                          ),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.grey[900]!),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                buttonSize: GameSettingsModel.buttonSize, 
                                leftHanded: GameSettingsModel.leftHanded, 
                                selectedCharacterSheet: GameSettingsModel.selectedCharacterSheet
                                ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.settings, size: 36, color: Colors.white,),
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

import 'package:flutter/material.dart';
import 'package:jumpnthrow/views/achievementsPage.dart';
import 'package:jumpnthrow/views/game.dart';
import 'package:jumpnthrow/views/menu.dart';
import 'package:jumpnthrow/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final Set<String> unlockedAchievements = {
      'first_jump',
      'first_run',
      'distance_100',
      'runs_5',
      'boss_kills_10',
    };
    final Map<String, int> achievementProgress = {
      // Early game
      'first_jump': 1,
      'first_kill': 0,
      'first_death': 1,
      'first_shot': 1,
      'first_run': 1,
      'first_heal': 0,

      // Distance milestones
      'distance_100': 100,
      'distance_1000': 640,
      'distance_10000': 3200,
      'distance_50000': 12000,
      'distance_100000': 45000,
      'distance_200000': 78000,

      // Runs
      'runs_5': 5,
      'runs_10': 7,
      'runs_50': 23,
      'runs_100': 48,
      'runs_200': 73,

      // Skill — no damage
      'no_damage_100': 100,
      'no_damage_1000': 450,
      'no_damage_10000': 2100,
      'no_damage_50000': 9000,
      'no_damage_100000': 12000,
      'no_damage_200000': 24000,

      // Boss kills
      'boss_kills_10': 10,
      'boss_kills_25': 14,
      'boss_kills_75': 31,
      'boss_kills_100': 48,
      'boss_kills_150': 92,
    };

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background4.png'),
                fit: BoxFit.cover,
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
                          child: Icon(Icons.add_chart, size: 36),
                        ),
                      ),
                      ElevatedButton(
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
                            _loadHighScore(); // Refresh displayed high score
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
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameSettings(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.settings, size: 36),
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

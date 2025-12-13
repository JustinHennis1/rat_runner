import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'High Score: $highScore',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                child: Stack(
                  children: [
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/pgdesign.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Rat',
                              style: TextStyle(
                                fontSize: 130,
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
                          children: [
                            SizedBox(width: 50),
                            const Text(
                              'Run',
                              style: TextStyle(
                                fontSize: 130,
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
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {},
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
                          builder: (context) => ContinueMenu(lastscore: score),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Play', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameSettings()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.settings, size: 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

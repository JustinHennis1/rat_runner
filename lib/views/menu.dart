import 'package:flutter/material.dart';
import 'package:jumpnthrow/views/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContinueMenu extends StatefulWidget {
  final int? lastscore;

  const ContinueMenu({super.key, required this.lastscore});

  @override
  _ContinueMenuState createState() => _ContinueMenuState();
}

class _ContinueMenuState extends State<ContinueMenu> {
  int highScore = 0;
  int prevScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    if (widget.lastscore != null) {
      prevScore = widget.lastscore!;
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 32, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              'Sewer Rat Runner',
              style: TextStyle(
                fontSize: 56,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontFamily: 'Gamer',
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'High Score: $highScore',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Score: ${prevScore}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),

            TextButton(
              onPressed: () async {
                // Navigate to the game and wait for the final score
                final score = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (context) => const MyGameWidget()),
                );

                // Save new high score if needed
                if (score != null) {
                  final prefs = await SharedPreferences.getInstance();
                  int currentHigh = prefs.getInt('highScore') ?? 0;
                  if (score > currentHigh) {
                    await prefs.setInt('highScore', score);
                  }
                  _loadHighScore(); // Refresh displayed high score
                  prevScore = score;
                }
              },
              child: const Text(
                'Play',
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Gamer',
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jumpnthrow/views/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContinueMenu extends StatefulWidget {
  final int? lastscore;

  const ContinueMenu({super.key, required this.lastscore});

  @override
  State<ContinueMenu> createState() => _ContinueMenuState();
}

class _ContinueMenuState extends State<ContinueMenu>
    with SingleTickerProviderStateMixin {
  int highScore = 0;
  int prevScore = 0;
  bool newHighScore = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    if (widget.lastscore != null) {
      prevScore = widget.lastscore!;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedHigh = prefs.getInt('highScore') ?? 0;

    setState(() {
      highScore = storedHigh;
      newHighScore = prevScore >= highScore;
    });

    if (newHighScore) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Center(
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
        
              /// SCORE SECTION
              Container(
                decoration: BoxDecoration(color: Color.fromARGB(122, 0, 0, 0)),
                child: Column(
                  children: [
                    if (newHighScore)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: const Text(
                            '🎉 New High Score! 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.greenAccent,
                              fontFamily: 'Gamer',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                        
                    const SizedBox(height: 20),
                        
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
                          'Your Score: $prevScore',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        
              /// BUTTONS
              Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      final score = await Navigator.push<int>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyGameWidget(),
                        ),
                      );
        
                      if (score != null) {
                        final prefs =
                            await SharedPreferences.getInstance();
                        final currentHigh =
                            prefs.getInt('highScore') ?? 0;
        
                        if (score > currentHigh) {
                          await prefs.setInt('highScore', score);
                        }
        
                        prevScore = score;
                        _loadHighScore();
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
        
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Main Menu',
                      style: TextStyle(
                        fontFamily: 'Gamer',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

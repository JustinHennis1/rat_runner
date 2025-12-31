import 'package:flutter/material.dart';
import 'package:jumpnthrow/models/achievements.dart';

class AchievementsPage extends StatelessWidget {
  final Set<String> unlockedAchievements;
  final Map<String, int> progress; // achievementId -> current value

  const AchievementsPage({
    super.key,
    required this.unlockedAchievements,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: Achievements.all.length,
        itemBuilder: (context, index) {
          final achievement = Achievements.all[index];
          final isUnlocked = unlockedAchievements.contains(achievement.id);

          final currentProgress = progress[achievement.id] ?? 0;
          final percent = (currentProgress / achievement.goal).clamp(0.0, 1.0);

          return AchievementTile(
            achievement: achievement,
            unlocked: isUnlocked,
            progress: percent,
            currentValue: currentProgress,
          );
        },
      ),
    );
  }
}

class AchievementTile extends StatefulWidget {
  final Achievement achievement;
  final bool unlocked;
  final double progress;
  final int currentValue;

  const AchievementTile({
    super.key,
    required this.achievement,
    required this.unlocked,
    required this.progress,
    required this.currentValue,
  });

  @override
  State<AchievementTile> createState() => _AchievementTileState();
}

class _AchievementTileState extends State<AchievementTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    if (widget.unlocked) {
      _controller.value = 1.0; // already unlocked → visible
    }
  }

  @override
  void didUpdateWidget(covariant AchievementTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.unlocked && widget.unlocked) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.unlocked ? Colors.amber : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.unlocked ? 1.0 : 0.65,
        child: Transform.scale(
          scale: widget.unlocked ? _scaleAnim.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
              children: [
                // ICON
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    widget.unlocked ? Icons.emoji_events : Icons.lock,
                    key: ValueKey(widget.unlocked),
                    color: color,
                    size: 36,
                  ),
                ),

                const SizedBox(width: 12),

                // TEXT + PROGRESS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.achievement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.achievement.description,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: widget.unlocked ? 1.0 : widget.progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.unlocked ? Colors.amber : Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.unlocked
                            ? 'Unlocked'
                            : '${widget.currentValue}/${widget.achievement.goal}',
                        style: TextStyle(
                          color: widget.unlocked
                              ? Colors.amber
                              : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

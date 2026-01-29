// attack_patterns.dart
import 'attack_pattern.dart';

class AttackPatterns {
  /// stageLevel = your state.level (1,2,3,...)
  static AttackPattern forStage(int stageLevel) {
    if (stageLevel <= 1) {
      // slow single shots
      return const AttackPattern(
        steps: [AttackStep(delaySeconds: 1.6, shots: 1)],
        jitterSeconds: 0.15,
      );
    }

    if (stageLevel == 2) {
      // two-shot burst, then rest
      return const AttackPattern(
        steps: [
          AttackStep(delaySeconds: 1.2, shots: 3, shotSpacingSeconds: 0.1),
          AttackStep(delaySeconds: 3.6, shots: 1),
        ],
        jitterSeconds: 0.10,
      );
    }

    if (stageLevel == 3) {
      // rhythmic sequence that feels like "pressure"
      return const AttackPattern(
        steps: [
          AttackStep(delaySeconds: 0.5, shots: 4, shotSpacingSeconds: 0.05),
          AttackStep(delaySeconds:  3.6, shots: 1),
        ],
        jitterSeconds: 0.08,
      );
    }

    // 4+ ramp: more bursts
    return const AttackPattern(
      steps: [
        AttackStep(delaySeconds: 0.8, shots: 2, shotSpacingSeconds: 0.12),
        AttackStep(delaySeconds: 1.1, shots: 3, shotSpacingSeconds: 0.10),
        AttackStep(delaySeconds: 1.4, shots: 1),
      ],
      jitterSeconds: 0.06,
    );
  }
}

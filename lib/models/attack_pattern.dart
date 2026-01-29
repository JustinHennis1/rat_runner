// attack_pattern.dart
import 'dart:math';

/// One "step" in a pattern: wait [delaySeconds], then fire [shots] projectiles
/// spaced by [shotSpacingSeconds].
class AttackStep {
  final double delaySeconds;
  final int shots;
  final double shotSpacingSeconds;

  const AttackStep({
    required this.delaySeconds,
    this.shots = 1,
    this.shotSpacingSeconds = 0.12,
  });
}

/// Repeats steps forever. Optional jitter to avoid feeling robotic.
class AttackPattern {
  final List<AttackStep> steps;
  final double jitterSeconds; // +/- added to each step delay
  final bool loop;

  const AttackPattern({
    required this.steps,
    this.jitterSeconds = 0.0,
    this.loop = true,
  });
}

/// Runtime that advances through an AttackPattern and tells you when to fire.
class AttackPatternRunner {
  final AttackPattern pattern;
  final Random _rng;

  int _stepIndex = 0;
  double _timeToNextStep = 0;

  // Burst state inside a step
  int _shotsRemaining = 0;
  double _timeToNextShot = 0;

  AttackPatternRunner(this.pattern, {Random? rng}) : _rng = rng ?? Random() {
    _scheduleCurrentStep(initial: true);
  }

  void reset() {
    _stepIndex = 0;
    _timeToNextStep = 0;
    _shotsRemaining = 0;
    _timeToNextShot = 0;
    _scheduleCurrentStep(initial: true);
  }

  /// Call this every update. Returns how many shots should be fired THIS frame.
  int tick(double dt) {
    int fireCount = 0;

    // If we are in the middle of a burst, handle shots.
    if (_shotsRemaining > 0) {
      _timeToNextShot -= dt;
      while (_shotsRemaining > 0 && _timeToNextShot <= 0) {
        fireCount += 1;
        _shotsRemaining -= 1;
        if (_shotsRemaining > 0) {
          _timeToNextShot += pattern.steps[_stepIndex].shotSpacingSeconds;
        }
      }
      // If burst finished, schedule next step timer.
      if (_shotsRemaining == 0) {
        _scheduleNextStep();
      }
      return fireCount;
    }

    // Otherwise waiting for next step to start.
    _timeToNextStep -= dt;
    if (_timeToNextStep <= 0) {
      final step = pattern.steps[_stepIndex];
      _shotsRemaining = step.shots;
      _timeToNextShot = 0; // fire immediately when step triggers
      // We don't advance step index until burst ends (so spacing uses this step).
    }

    return fireCount;
  }

  void _scheduleCurrentStep({bool initial = false}) {
    final step = pattern.steps[_stepIndex];
    _timeToNextStep = _applyJitter(step.delaySeconds);
    if (initial) return;
  }

  void _scheduleNextStep() {
    _stepIndex += 1;
    if (_stepIndex >= pattern.steps.length) {
      if (!pattern.loop) {
        _stepIndex = pattern.steps.length - 1; // stop on last
      } else {
        _stepIndex = 0;
      }
    }
    _scheduleCurrentStep();
  }

  double _applyJitter(double base) {
    if (pattern.jitterSeconds <= 0) return base;
    final j = ( _rng.nextDouble() * 2 - 1) * pattern.jitterSeconds; // [-jitter, +jitter]
    final v = base + j;
    return v < 0.02 ? 0.02 : v;
  }
}

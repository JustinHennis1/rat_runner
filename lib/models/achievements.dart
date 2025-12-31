enum AchievementCategory { earlyGame, milestone, skill }

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int goal; // numeric target (distance, runs, kills, etc.)

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goal,
  });
}

class Achievements {
  static const List<Achievement> all = [
    // ======================
    // EARLY GAME
    // ======================
    Achievement(
      id: 'first_jump',
      title: 'First Jump',
      description: 'Jump for the first time.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),
    Achievement(
      id: 'first_kill',
      title: 'First Kill',
      description: 'Defeat your first enemy.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),
    Achievement(
      id: 'first_death',
      title: 'First Death',
      description: 'Die for the first time.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),
    Achievement(
      id: 'first_shot',
      title: 'First Shot',
      description: 'Fire your first shot.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),
    Achievement(
      id: 'first_run',
      title: 'First Run',
      description: 'Complete your first run.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),
    Achievement(
      id: 'first_heal',
      title: 'First Heal',
      description: 'Heal for the first time.',
      category: AchievementCategory.earlyGame,
      goal: 1,
    ),

    // ======================
    // DISTANCE MILESTONES
    // ======================
    Achievement(
      id: 'distance_100',
      title: 'Getting Started',
      description: 'Travel 100 meters.',
      category: AchievementCategory.milestone,
      goal: 100,
    ),
    Achievement(
      id: 'distance_1000',
      title: 'On the Move',
      description: 'Travel 1,000 meters.',
      category: AchievementCategory.milestone,
      goal: 1000,
    ),
    Achievement(
      id: 'distance_10000',
      title: 'Long Runner',
      description: 'Travel 10,000 meters.',
      category: AchievementCategory.milestone,
      goal: 10000,
    ),
    Achievement(
      id: 'distance_50000',
      title: 'Endurance',
      description: 'Travel 50,000 meters.',
      category: AchievementCategory.milestone,
      goal: 50000,
    ),
    Achievement(
      id: 'distance_100000',
      title: 'Marathon',
      description: 'Travel 100,000 meters.',
      category: AchievementCategory.milestone,
      goal: 100000,
    ),
    Achievement(
      id: 'distance_200000',
      title: 'Legendary Distance',
      description: 'Travel 200,000 meters.',
      category: AchievementCategory.milestone,
      goal: 200000,
    ),

    // ======================
    // RUN COUNT
    // ======================
    Achievement(
      id: 'runs_5',
      title: 'Just Warming Up',
      description: 'Complete 5 runs.',
      category: AchievementCategory.milestone,
      goal: 5,
    ),
    Achievement(
      id: 'runs_10',
      title: 'Runner',
      description: 'Complete 10 runs.',
      category: AchievementCategory.milestone,
      goal: 10,
    ),
    Achievement(
      id: 'runs_50',
      title: 'Dedicated',
      description: 'Complete 50 runs.',
      category: AchievementCategory.milestone,
      goal: 50,
    ),
    Achievement(
      id: 'runs_100',
      title: 'Veteran',
      description: 'Complete 100 runs.',
      category: AchievementCategory.milestone,
      goal: 100,
    ),
    Achievement(
      id: 'runs_200',
      title: 'Unstoppable',
      description: 'Complete 200 runs.',
      category: AchievementCategory.milestone,
      goal: 200,
    ),

    // ======================
    // SKILL — ZERO DAMAGE DISTANCE
    // ======================
    Achievement(
      id: 'no_damage_100',
      title: 'Untouched',
      description: 'Travel 100 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 100,
    ),
    Achievement(
      id: 'no_damage_1000',
      title: 'Clean Run',
      description: 'Travel 1,000 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 1000,
    ),
    Achievement(
      id: 'no_damage_10000',
      title: 'Perfect Flow',
      description: 'Travel 10,000 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 10000,
    ),
    Achievement(
      id: 'no_damage_50000',
      title: 'Untouchable',
      description: 'Travel 50,000 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 50000,
    ),
    Achievement(
      id: 'no_damage_100000',
      title: 'Master Runner',
      description: 'Travel 100,000 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 100000,
    ),
    Achievement(
      id: 'no_damage_200000',
      title: 'Flawless Legend',
      description: 'Travel 200,000 meters without taking damage.',
      category: AchievementCategory.skill,
      goal: 200000,
    ),

    // ======================
    // BOSS KILLS
    // ======================
    Achievement(
      id: 'boss_kills_10',
      title: 'Boss Hunter',
      description: 'Defeat 10 bosses.',
      category: AchievementCategory.skill,
      goal: 10,
    ),
    Achievement(
      id: 'boss_kills_25',
      title: 'Boss Slayer',
      description: 'Defeat 25 bosses.',
      category: AchievementCategory.skill,
      goal: 25,
    ),
    Achievement(
      id: 'boss_kills_75',
      title: 'Boss Destroyer',
      description: 'Defeat 75 bosses.',
      category: AchievementCategory.skill,
      goal: 75,
    ),
    Achievement(
      id: 'boss_kills_100',
      title: 'Boss Executioner',
      description: 'Defeat 100 bosses.',
      category: AchievementCategory.skill,
      goal: 100,
    ),
    Achievement(
      id: 'boss_kills_150',
      title: 'Boss Nightmare',
      description: 'Defeat 150 bosses.',
      category: AchievementCategory.skill,
      goal: 150,
    ),
  ];
}

enum AchievementId {
  firstLesson,
  perfectLesson,
  perfect5,
  streak3,
  streak7,
  streak30,
  streak100,
  xp100,
  xp500,
  xp2000,
  vocab25,
  vocab100,
  vocab250,
  surahComplete,
  fatihaComplete,
  juzAmmaHalf,
  juzAmmaComplete,
  reviewMaster,
  earlyBird,
  nightOwl,
  dailyGoal7,
  dailyGoal30,
}

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final String emoji;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id.name,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromTemplate(
    AchievementId id, {
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) {
    final t = _templates[id]!;
    return Achievement(
      id: id,
      title: t.title,
      description: t.description,
      emoji: t.emoji,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }
}

class _AchievementTemplate {
  final String title;
  final String description;
  final String emoji;
  const _AchievementTemplate(this.title, this.description, this.emoji);
}

const _templates = <AchievementId, _AchievementTemplate>{
  AchievementId.firstLesson: _AchievementTemplate(
    'First Step',
    'Complete your first lesson',
    '🌱',
  ),
  AchievementId.perfectLesson: _AchievementTemplate(
    'Flawless',
    'Complete a lesson with no mistakes',
    '⭐',
  ),
  AchievementId.perfect5: _AchievementTemplate(
    'On Fire',
    'Complete 5 perfect lessons',
    '🔥',
  ),
  AchievementId.streak3: _AchievementTemplate(
    'Getting Started',
    'Reach a 3-day streak',
    '🗓️',
  ),
  AchievementId.streak7: _AchievementTemplate(
    'Week Warrior',
    'Reach a 7-day streak',
    '💪',
  ),
  AchievementId.streak30: _AchievementTemplate(
    'Devoted Learner',
    'Reach a 30-day streak',
    '🏅',
  ),
  AchievementId.streak100: _AchievementTemplate(
    'Scholar',
    'Reach a 100-day streak',
    '🏆',
  ),
  AchievementId.xp100: _AchievementTemplate(
    'Sparkling',
    'Earn 100 total XP',
    '✨',
  ),
  AchievementId.xp500: _AchievementTemplate(
    'Shining',
    'Earn 500 total XP',
    '💎',
  ),
  AchievementId.xp2000: _AchievementTemplate(
    'Radiant',
    'Earn 2000 total XP',
    '👑',
  ),
  AchievementId.vocab25: _AchievementTemplate(
    'Word Seeker',
    'Learn 25 Arabic words',
    '📖',
  ),
  AchievementId.vocab100: _AchievementTemplate(
    'Linguist',
    'Learn 100 Arabic words',
    '🔤',
  ),
  AchievementId.vocab250: _AchievementTemplate(
    'Quranic Vocabulary',
    'Learn 250 Arabic words',
    '🌟',
  ),
  AchievementId.surahComplete: _AchievementTemplate(
    'Surah Master',
    'Complete all verses of a surah',
    '📜',
  ),
  AchievementId.fatihaComplete: _AchievementTemplate(
    'The Opening',
    'Complete all 7 verses of Al-Fatiha',
    '🕌',
  ),
  AchievementId.juzAmmaHalf: _AchievementTemplate(
    'Halfway There',
    'Complete half of Juz Amma',
    '🌙',
  ),
  AchievementId.juzAmmaComplete: _AchievementTemplate(
    'Juz Amma Complete',
    'Complete all short surahs of the 30th Juz',
    '🌙',
  ),
  AchievementId.reviewMaster: _AchievementTemplate(
    'Review Master',
    'Complete 10 review sessions',
    '🔄',
  ),
  AchievementId.earlyBird: _AchievementTemplate(
    'Fajr Spirit',
    'Study before 6 AM',
    '🌅',
  ),
  AchievementId.nightOwl: _AchievementTemplate(
    'Night Devotion',
    'Study after 11 PM',
    '🌙',
  ),
  AchievementId.dailyGoal7: _AchievementTemplate(
    'Consistent',
    'Hit your daily XP goal 7 days in a row',
    '🎯',
  ),
  AchievementId.dailyGoal30: _AchievementTemplate(
    'Unstoppable',
    'Hit your daily XP goal 30 days in a row',
    '⚡',
  ),
};

List<Achievement> buildAllAchievements(Map<String, dynamic> savedData) {
  return AchievementId.values.map((id) {
    final saved = savedData[id.name] as Map<String, dynamic>?;
    return Achievement.fromTemplate(
      id,
      isUnlocked: saved?['isUnlocked'] as bool? ?? false,
      unlockedAt: saved?['unlockedAt'] != null
          ? DateTime.tryParse(saved!['unlockedAt'] as String)
          : null,
    );
  }).toList();
}

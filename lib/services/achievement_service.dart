import '../models/achievement.dart';
import '../models/user_progress.dart';

class AchievementService {
  // Returns list of newly unlocked achievements after a lesson/review
  static List<Achievement> checkAfterLesson(UserProgress progress) {
    final unlocked = <Achievement>[];
    _check(progress, AchievementId.firstLesson,
        () => progress.totalLessonsCompleted >= 1, unlocked);
    _check(progress, AchievementId.perfectLesson,
        () => progress.totalPerfectLessons >= 1, unlocked);
    _check(progress, AchievementId.perfect5,
        () => progress.totalPerfectLessons >= 5, unlocked);
    _check(progress, AchievementId.streak3,
        () => progress.streak >= 3, unlocked);
    _check(progress, AchievementId.streak7,
        () => progress.streak >= 7, unlocked);
    _check(progress, AchievementId.streak30,
        () => progress.streak >= 30, unlocked);
    _check(progress, AchievementId.streak100,
        () => progress.streak >= 100, unlocked);
    _check(progress, AchievementId.xp100,
        () => progress.totalXP >= 100, unlocked);
    _check(progress, AchievementId.xp500,
        () => progress.totalXP >= 500, unlocked);
    _check(progress, AchievementId.xp2000,
        () => progress.totalXP >= 2000, unlocked);
    _check(progress, AchievementId.vocab25,
        () => progress.vocabularyCount >= 25, unlocked);
    _check(progress, AchievementId.vocab100,
        () => progress.vocabularyCount >= 100, unlocked);
    _check(progress, AchievementId.vocab250,
        () => progress.vocabularyCount >= 250, unlocked);
    _check(progress, AchievementId.dailyGoal7,
        () => progress.consecutiveDailyGoals >= 7, unlocked);
    _check(progress, AchievementId.dailyGoal30,
        () => progress.consecutiveDailyGoals >= 30, unlocked);
    _checkFatiha(progress, unlocked);
    _checkReviewMaster(progress, unlocked);
    _checkTimeOfDay(progress, unlocked);
    return unlocked;
  }

  static void _check(
    UserProgress progress,
    AchievementId id,
    bool Function() condition,
    List<Achievement> unlocked,
  ) {
    final achievement = progress.achievements
        .firstWhere((a) => a.id == id, orElse: () => Achievement.fromTemplate(id));
    if (!achievement.isUnlocked && condition()) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      unlocked.add(achievement);
    }
  }

  static void _checkFatiha(UserProgress progress, List<Achievement> unlocked) {
    final sp = progress.surahProgress[1];
    if (sp == null) return;
    // Al-Fatiha has 7 verses
    final fatihaComplete = List.generate(7, (i) => i)
        .every((i) => sp.completedLessons.contains(i));
    _check(progress, AchievementId.fatihaComplete, () => fatihaComplete, unlocked);
    if (fatihaComplete) {
      _check(progress, AchievementId.surahComplete, () => true, unlocked);
    }
  }

  static void _checkReviewMaster(
      UserProgress progress, List<Achievement> unlocked) {
    _check(progress, AchievementId.reviewMaster,
        () => progress.totalReviewSessions >= 10, unlocked);
  }

  static void _checkTimeOfDay(
      UserProgress progress, List<Achievement> unlocked) {
    final hour = DateTime.now().hour;
    _check(
        progress, AchievementId.earlyBird, () => hour < 6, unlocked);
    _check(
        progress, AchievementId.nightOwl, () => hour >= 23, unlocked);
  }
}

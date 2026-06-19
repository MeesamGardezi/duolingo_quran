import 'achievement.dart';
import 'vocabulary_item.dart';

class UserProgress {
  String userName;
  int totalXP;
  int streak;
  int longestStreak;
  DateTime? lastStudyDate;
  int dailyXPGoal;
  int todayXP;
  int consecutiveDailyGoals; // days in a row you hit your goal
  int totalLessonsCompleted;
  int totalPerfectLessons;
  int totalReviewSessions;

  // Daily challenge
  DateTime? lastDailyChallengeDate;

  // Global hearts (0-5, refill 1 per 4 hours)
  int hearts;
  DateTime? lastHeartLostAt;
  static const int maxHearts = 5;
  static const Duration heartRefillDuration = Duration(hours: 4);

  // Per-surah progress
  Map<int, SurahProgress> surahProgress;

  // Vocabulary bank (word id → item)
  Map<String, VocabularyItem> vocabulary;

  // Achievements (id → saved state)
  List<Achievement> achievements;

  UserProgress({
    this.userName = '',
    this.totalXP = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.dailyXPGoal = 20,
    this.todayXP = 0,
    this.consecutiveDailyGoals = 0,
    this.totalLessonsCompleted = 0,
    this.totalPerfectLessons = 0,
    this.totalReviewSessions = 0,
    this.lastDailyChallengeDate,
    this.hearts = maxHearts,
    this.lastHeartLostAt,
    Map<int, SurahProgress>? surahProgress,
    Map<String, VocabularyItem>? vocabulary,
    List<Achievement>? achievements,
  })  : surahProgress = surahProgress ?? {},
        vocabulary = vocabulary ?? {},
        achievements = achievements ?? _defaultAchievements();

  static List<Achievement> _defaultAchievements() =>
      buildAllAchievements({});

  bool get isDailyChallengeAvailable {
    if (lastDailyChallengeDate == null) return true;
    final now = DateTime.now();
    final last = lastDailyChallengeDate!;
    return !(now.year == last.year && now.month == last.month && now.day == last.day);
  }

  int get level => (totalXP / 500).floor() + 1;
  int get xpInCurrentLevel => totalXP % 500;
  int get xpToNextLevel => 500 - xpInCurrentLevel;
  bool get dailyGoalMet => todayXP >= dailyXPGoal;
  int get vocabularyCount => vocabulary.length;

  // Hearts with auto-refill based on elapsed time
  int get currentHearts {
    if (hearts >= maxHearts) return maxHearts;
    if (lastHeartLostAt == null) return hearts;
    final elapsed = DateTime.now().difference(lastHeartLostAt!);
    final refilled = (elapsed.inMinutes / heartRefillDuration.inMinutes).floor();
    return (hearts + refilled).clamp(0, maxHearts);
  }

  Duration get timeUntilNextHeart {
    if (currentHearts >= maxHearts) return Duration.zero;
    if (lastHeartLostAt == null) return Duration.zero;
    final elapsed = DateTime.now().difference(lastHeartLostAt!);
    final refillMinutes = heartRefillDuration.inMinutes;
    final minutesIntoCurrentCycle = elapsed.inMinutes % refillMinutes;
    return Duration(minutes: refillMinutes - minutesIntoCurrentCycle);
  }

  void loseHeart() {
    final current = currentHearts;
    if (current > 0) {
      hearts = current - 1;
      lastHeartLostAt = DateTime.now();
    }
  }

  void gainHeart() {
    hearts = (currentHearts + 1).clamp(0, maxHearts);
    if (hearts >= maxHearts) lastHeartLostAt = null;
  }

  void syncHearts() {
    // Call this on app open to sync refill
    final refilled = currentHearts;
    if (refilled > hearts) {
      hearts = refilled;
      if (hearts >= maxHearts) lastHeartLostAt = null;
    }
  }

  void addXP(int amount) {
    final wasGoalMet = dailyGoalMet;
    totalXP += amount;
    todayXP += amount;
    _checkAndUpdateStreak();
    if (!wasGoalMet && dailyGoalMet) {
      consecutiveDailyGoals++;
    }
  }

  void _checkAndUpdateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastStudyDate == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(
        lastStudyDate!.year,
        lastStudyDate!.month,
        lastStudyDate!.day,
      );
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
        consecutiveDailyGoals = 0;
      }
    }
    if (streak > longestStreak) longestStreak = streak;
    lastStudyDate = now;
  }

  void resetDailyXPIfNewDay() {
    if (lastStudyDate == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastStudyDate!.year,
      lastStudyDate!.month,
      lastStudyDate!.day,
    );
    if (today.isAfter(lastDay)) {
      todayXP = 0;
    }
  }

  SurahProgress getSurahProgress(int surahNumber) =>
      surahProgress[surahNumber] ??= SurahProgress(surahNumber: surahNumber);

  void addVocabulary(VocabularyItem item) {
    vocabulary.putIfAbsent(item.id, () => item);
  }

  List<VocabularyItem> get dueForReview =>
      vocabulary.values.where((v) => v.isDueForReview).toList()
        ..sort((a, b) =>
            (a.nextReview ?? DateTime.now())
                .compareTo(b.nextReview ?? DateTime.now()));

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'totalXP': totalXP,
        'streak': streak,
        'longestStreak': longestStreak,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'dailyXPGoal': dailyXPGoal,
        'todayXP': todayXP,
        'consecutiveDailyGoals': consecutiveDailyGoals,
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalPerfectLessons': totalPerfectLessons,
        'totalReviewSessions': totalReviewSessions,
        'lastDailyChallengeDate': lastDailyChallengeDate?.toIso8601String(),
        'hearts': hearts,
        'lastHeartLostAt': lastHeartLostAt?.toIso8601String(),
        'surahProgress': surahProgress.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
        'vocabulary': vocabulary.map((k, v) => MapEntry(k, v.toJson())),
        'achievements': {
          for (final a in achievements) a.id.name: a.toJson(),
        },
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final surahMap = <int, SurahProgress>{};
    (json['surahProgress'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      final num = int.tryParse(k);
      if (num != null) {
        surahMap[num] = SurahProgress.fromJson(v as Map<String, dynamic>);
      }
    });

    final vocabMap = <String, VocabularyItem>{};
    (json['vocabulary'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      vocabMap[k] = VocabularyItem.fromJson(v as Map<String, dynamic>);
    });

    final achievementsData =
        json['achievements'] as Map<String, dynamic>? ?? {};
    final achievements = buildAllAchievements(achievementsData);

    return UserProgress(
      userName: json['userName'] as String? ?? '',
      totalXP: json['totalXP'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.tryParse(json['lastStudyDate'] as String)
          : null,
      dailyXPGoal: json['dailyXPGoal'] as int? ?? 20,
      todayXP: json['todayXP'] as int? ?? 0,
      consecutiveDailyGoals: json['consecutiveDailyGoals'] as int? ?? 0,
      totalLessonsCompleted: json['totalLessonsCompleted'] as int? ?? 0,
      totalPerfectLessons: json['totalPerfectLessons'] as int? ?? 0,
      totalReviewSessions: json['totalReviewSessions'] as int? ?? 0,
      lastDailyChallengeDate: json['lastDailyChallengeDate'] != null
          ? DateTime.tryParse(json['lastDailyChallengeDate'] as String)
          : null,
      hearts: json['hearts'] as int? ?? UserProgress.maxHearts,
      lastHeartLostAt: json['lastHeartLostAt'] != null
          ? DateTime.tryParse(json['lastHeartLostAt'] as String)
          : null,
      surahProgress: surahMap,
      vocabulary: vocabMap,
      achievements: achievements,
    );
  }
}

class SurahProgress {
  final int surahNumber;
  Set<int> completedLessons; // lesson indices (verseNumber - 1)
  int totalCorrect;
  int totalAttempts;

  SurahProgress({
    required this.surahNumber,
    Set<int>? completedLessons,
    this.totalCorrect = 0,
    this.totalAttempts = 0,
  }) : completedLessons = completedLessons ?? {};

  bool isLessonUnlocked(int lessonIndex) =>
      lessonIndex == 0 || completedLessons.contains(lessonIndex - 1);

  bool isLessonComplete(int lessonIndex) =>
      completedLessons.contains(lessonIndex);

  void completeLesson(int lessonIndex) => completedLessons.add(lessonIndex);

  double get accuracy =>
      totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'completedLessons': completedLessons.toList(),
        'totalCorrect': totalCorrect,
        'totalAttempts': totalAttempts,
      };

  factory SurahProgress.fromJson(Map<String, dynamic> json) => SurahProgress(
        surahNumber: json['surahNumber'] as int,
        completedLessons: Set<int>.from(
          (json['completedLessons'] as List<dynamic>? ?? []).cast<int>(),
        ),
        totalCorrect: json['totalCorrect'] as int? ?? 0,
        totalAttempts: json['totalAttempts'] as int? ?? 0,
      );
}

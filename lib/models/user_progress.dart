class UserProgress {
  int totalXP;
  int streak;
  DateTime? lastStudyDate;
  int dailyXPGoal;
  int todayXP;
  Map<int, SurahProgress> surahProgress;

  UserProgress({
    this.totalXP = 0,
    this.streak = 0,
    this.lastStudyDate,
    this.dailyXPGoal = 50,
    this.todayXP = 0,
    Map<int, SurahProgress>? surahProgress,
  }) : surahProgress = surahProgress ?? {};

  int get level => (totalXP / 500).floor() + 1;
  int get xpToNextLevel => 500 - (totalXP % 500);
  bool get dailyGoalMet => todayXP >= dailyXPGoal;

  void addXP(int amount) {
    totalXP += amount;
    todayXP += amount;
    _checkAndUpdateStreak();
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
      }
      // diff == 0 means same day, streak unchanged
    }
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

  SurahProgress getSurahProgress(int surahNumber) {
    return surahProgress[surahNumber] ??= SurahProgress(surahNumber: surahNumber);
  }

  Map<String, dynamic> toJson() => {
        'totalXP': totalXP,
        'streak': streak,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'dailyXPGoal': dailyXPGoal,
        'todayXP': todayXP,
        'surahProgress': surahProgress.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final surahMap = <int, SurahProgress>{};
    final raw = json['surahProgress'] as Map<String, dynamic>? ?? {};
    raw.forEach((k, v) {
      final num = int.tryParse(k);
      if (num != null) {
        surahMap[num] = SurahProgress.fromJson(v as Map<String, dynamic>);
      }
    });
    return UserProgress(
      totalXP: json['totalXP'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.tryParse(json['lastStudyDate'] as String)
          : null,
      dailyXPGoal: json['dailyXPGoal'] as int? ?? 50,
      todayXP: json['todayXP'] as int? ?? 0,
      surahProgress: surahMap,
    );
  }
}

class SurahProgress {
  final int surahNumber;
  Set<int> completedLessons;
  int totalCorrect;
  int totalAttempts;

  SurahProgress({
    required this.surahNumber,
    Set<int>? completedLessons,
    this.totalCorrect = 0,
    this.totalAttempts = 0,
  }) : completedLessons = completedLessons ?? {};

  bool isLessonUnlocked(int lessonIndex) {
    if (lessonIndex == 0) return true;
    return completedLessons.contains(lessonIndex - 1);
  }

  bool isLessonComplete(int lessonIndex) {
    return completedLessons.contains(lessonIndex);
  }

  void completeLesson(int lessonIndex) {
    completedLessons.add(lessonIndex);
  }

  double get accuracy =>
      totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'completedLessons': completedLessons.toList(),
        'totalCorrect': totalCorrect,
        'totalAttempts': totalAttempts,
      };

  factory SurahProgress.fromJson(Map<String, dynamic> json) {
    return SurahProgress(
      surahNumber: json['surahNumber'] as int,
      completedLessons: Set<int>.from(
        (json['completedLessons'] as List<dynamic>? ?? []).cast<int>(),
      ),
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
    );
  }
}

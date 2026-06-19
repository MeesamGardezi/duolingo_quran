import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/surah.dart';
import '../models/exercise.dart';
import '../models/achievement.dart';
import '../models/vocabulary_item.dart';
import '../data/quran_repository.dart';
import '../services/progress_service.dart';
import '../services/exercise_generator.dart';
import '../services/achievement_service.dart';

class AppProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress();
  bool _initialized = false;
  List<Achievement> _pendingAchievements = [];
  final ExerciseGenerator _generator = ExerciseGenerator();

  UserProgress get progress => _progress;
  bool get initialized => _initialized;
  List<Achievement> get pendingAchievements => _pendingAchievements;

  Future<void> initialize() async {
    await QuranRepository.instance.initialize();
    _progress = await ProgressService.instance.load();
    _initialized = true;
    notifyListeners();
  }

  void clearPendingAchievements() {
    _pendingAchievements = [];
  }

  // ── Lesson ─────────────────────────────────────────────────────────────────

  List<LessonRef> get orderedLessons =>
      QuranRepository.instance.orderedLessons;

  bool isLessonComplete(LessonRef ref) {
    final sp = _progress.surahProgress[ref.surahNumber];
    return sp?.isLessonComplete(ref.verseNumber - 1) ?? false;
  }

  bool isLessonUnlocked(LessonRef ref) {
    final lessons = orderedLessons;
    final index = lessons.indexOf(ref);
    if (index <= 0) return true;
    return isLessonComplete(lessons[index - 1]);
  }

  LessonRef? get nextLesson {
    for (final ref in orderedLessons) {
      if (!isLessonComplete(ref)) return ref;
    }
    return null;
  }

  int get completedLessonsCount {
    var count = 0;
    for (final ref in orderedLessons) {
      if (isLessonComplete(ref)) count++;
    }
    return count;
  }

  LessonSession? buildLesson(LessonRef ref) {
    final surah = QuranRepository.instance.getSurah(ref.surahNumber);
    if (surah == null) return null;

    final verse = surah.verses.firstWhere(
      (v) => v.number == ref.verseNumber,
      orElse: () => surah.verses.first,
    );

    final exercises =
        _generator.generateForVerse(verse, ref.surahNumber, surah.verses);

    return LessonSession(
      surahNumber: ref.surahNumber,
      lessonIndex: ref.verseNumber - 1,
      exercises: exercises,
      xpReward: _xpForVerse(verse),
    );
  }

  int _xpForVerse(Verse verse) =>
      (10 + verse.words.length * 2).clamp(10, 30);

  Future<void> recordLessonComplete(LessonSession session) async {
    final surah = QuranRepository.instance.getSurah(session.surahNumber);
    final verse = surah?.verses.firstWhere(
      (v) => v.number == session.lessonIndex + 1,
      orElse: () => surah!.verses.first,
    );

    await ProgressService.instance.completeLesson(
      progress: _progress,
      surahNumber: session.surahNumber,
      verseNumber: session.lessonIndex + 1,
      correctCount: session.correctCount,
      totalCount: session.exercises.length,
      xpEarned: session.xpReward,
      isPerfect: session.isPerfect,
      words: verse?.words ?? [],
    );

    _pendingAchievements = AchievementService.checkAfterLesson(_progress);
    await ProgressService.instance.save(_progress);
    notifyListeners();
  }

  // ── Review ─────────────────────────────────────────────────────────────────

  List<VocabularyItem> get dueForReview => _progress.dueForReview;

  int get dueCount => dueForReview.length;

  LessonSession buildReviewSession() {
    final due = dueForReview.take(8).toList();
    final allVerses = QuranRepository.instance.loadedSurahs
        .expand((s) => s.verses)
        .toList();

    final exercises = _generator.generateReviewExercises(due, allVerses);

    return LessonSession(
      surahNumber: 0,
      lessonIndex: -1,
      exercises: exercises,
      xpReward: 5,
    );
  }

  Future<void> recordReviewComplete(
    LessonSession session,
    Map<String, bool> wordResults,
  ) async {
    await ProgressService.instance.completeReview(
      progress: _progress,
      reviewedWordIds: wordResults.keys.toList(),
      results: wordResults,
    );
    _pendingAchievements = AchievementService.checkAfterLesson(_progress);
    notifyListeners();
  }

  // ── Daily Challenge ────────────────────────────────────────────────────────

  bool get isDailyChallengeAvailable => _progress.isDailyChallengeAvailable;

  LessonSession buildDailyChallenge() {
    final allVerses = QuranRepository.instance.loadedSurahs
        .expand((s) => s.verses)
        .toList();

    final completedRefs = orderedLessons.where(isLessonComplete).toList();

    final exercises = _generator.generateDailyChallenge(
      vocabulary: _progress.vocabulary.values.toList(),
      completedRefs: completedRefs,
      allVerses: allVerses,
    );

    return LessonSession(
      surahNumber: 0,
      lessonIndex: -2,
      exercises: exercises.isEmpty
          ? _generator.generateReviewExercises(
              _progress.vocabulary.values.take(5).toList(), allVerses)
          : exercises,
      xpReward: 30,
    );
  }

  Future<void> recordDailyChallengeComplete(LessonSession session) async {
    _progress.lastDailyChallengeDate = DateTime.now();
    _progress.addXP(session.xpReward);
    _pendingAchievements = AchievementService.checkAfterLesson(_progress);
    await ProgressService.instance.save(_progress);
    notifyListeners();
  }

  // ── Hearts ─────────────────────────────────────────────────────────────────

  int get hearts => _progress.currentHearts;

  Future<void> loseHeart() async {
    _progress.loseHeart();
    await ProgressService.instance.save(_progress);
    notifyListeners();
  }

  // ── Vocabulary ─────────────────────────────────────────────────────────────

  List<VocabularyItem> get allVocabulary =>
      _progress.vocabulary.values.toList()
        ..sort((a, b) => b.firstSeen.compareTo(a.firstSeen));

  // ── Surah info ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get surahsSortedByLength =>
      QuranRepository.instance.surahsSortedByLength;

  // ── Settings ───────────────────────────────────────────────────────────────

  Future<void> setDailyGoal(int xp) async {
    _progress.dailyXPGoal = xp;
    await ProgressService.instance.save(_progress);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _progress.userName = name;
    await ProgressService.instance.save(_progress);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await ProgressService.instance.reset();
    _progress = UserProgress();
    notifyListeners();
  }
}

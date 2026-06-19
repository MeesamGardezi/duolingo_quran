import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/surah.dart';
import '../models/exercise.dart';
import '../data/quran_repository.dart';
import '../services/progress_service.dart';
import '../services/exercise_generator.dart';

class AppProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress();
  bool _initialized = false;
  final ExerciseGenerator _generator = ExerciseGenerator();

  UserProgress get progress => _progress;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    await QuranRepository.instance.initialize();
    _progress = await ProgressService.instance.load();
    _initialized = true;
    notifyListeners();
  }

  // Ordered list of all lessons (verse refs sorted by surah length)
  List<LessonRef> get orderedLessons =>
      QuranRepository.instance.orderedLessons;

  // How many total lessons exist (sum of all verses across all surahs)
  int get totalLessons => orderedLessons.length;

  // How many lessons the user has completed
  int get completedLessonsCount {
    var count = 0;
    for (final ref in orderedLessons) {
      final sp = _progress.surahProgress[ref.surahNumber];
      if (sp != null && sp.isLessonComplete(ref.verseNumber - 1)) {
        count++;
      }
    }
    return count;
  }

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

  // Next uncompleted lesson
  LessonRef? get nextLesson {
    for (final ref in orderedLessons) {
      if (!isLessonComplete(ref)) return ref;
    }
    return null;
  }

  LessonSession? buildLesson(LessonRef ref) {
    final surah = QuranRepository.instance.getSurah(ref.surahNumber);
    if (surah == null) return null;

    final verse = surah.verses.firstWhere(
      (v) => v.number == ref.verseNumber,
      orElse: () => surah.verses.first,
    );

    final exercises = _generator.generateForVerse(
      verse,
      ref.surahNumber,
      surah.verses,
    );

    return LessonSession(
      surahNumber: ref.surahNumber,
      lessonIndex: ref.verseNumber - 1,
      exercises: exercises,
      xpReward: _calculateXP(verse),
    );
  }

  int _calculateXP(Verse verse) {
    // More XP for longer verses
    return 10 + (verse.words.length * 2).clamp(0, 20);
  }

  Future<void> recordLessonComplete(LessonSession session) async {
    await ProgressService.instance.completeLesson(
      progress: _progress,
      surahNumber: session.surahNumber,
      verseNumber: session.lessonIndex + 1,
      correctCount: session.correctCount,
      totalCount: session.exercises.length,
      xpEarned: session.xpReward,
    );
    notifyListeners();
  }

  List<Map<String, dynamic>> get surahsSortedByLength =>
      QuranRepository.instance.surahsSortedByLength;
}

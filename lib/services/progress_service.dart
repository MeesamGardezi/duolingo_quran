import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/vocabulary_item.dart';
import '../models/surah.dart';

class ProgressService {
  static const _progressKey = 'user_progress_v2';
  static const _onboardingKey = 'onboarding_complete';
  static ProgressService? _instance;

  ProgressService._();
  static ProgressService get instance => _instance ??= ProgressService._();

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_progressKey);
    if (json == null) return UserProgress();
    try {
      final p =
          UserProgress.fromJson(jsonDecode(json) as Map<String, dynamic>);
      p.resetDailyXPIfNewDay();
      p.syncHearts();
      return p;
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Records a completed lesson and returns newly unlocked achievements
  Future<void> completeLesson({
    required UserProgress progress,
    required int surahNumber,
    required int verseNumber,
    required int correctCount,
    required int totalCount,
    required int xpEarned,
    required bool isPerfect,
    required List<QuranWord> words,
  }) async {
    // XP
    progress.addXP(xpEarned);

    // Surah progress
    final sp = progress.getSurahProgress(surahNumber);
    sp.completeLesson(verseNumber - 1);
    sp.totalCorrect += correctCount;
    sp.totalAttempts += totalCount;

    // Lesson counters
    progress.totalLessonsCompleted++;
    if (isPerfect) progress.totalPerfectLessons++;

    // Vocabulary
    final now = DateTime.now();
    for (final word in words) {
      final item = VocabularyItem(
        arabic: word.arabic,
        transliteration: word.transliteration,
        meaning: word.meaning,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        firstSeen: now,
        nextReview: now.add(const Duration(days: 1)),
      );
      progress.addVocabulary(item);
    }

    await save(progress);
  }

  Future<void> completeReview({
    required UserProgress progress,
    required List<String> reviewedWordIds,
    required Map<String, bool> results,
  }) async {
    progress.totalReviewSessions++;
    for (final id in reviewedWordIds) {
      final item = progress.vocabulary[id];
      if (item == null) continue;
      final correct = results[id] ?? false;
      item.review(correct ? 4 : 1);
      if (correct) progress.gainHeart();
    }
    progress.addXP(5); // small XP for review
    await save(progress);
  }
}

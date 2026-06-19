import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class ProgressService {
  static const _progressKey = 'user_progress';
  static ProgressService? _instance;

  ProgressService._();
  static ProgressService get instance {
    _instance ??= ProgressService._();
    return _instance!;
  }

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_progressKey);
    if (json == null) return UserProgress();
    try {
      final progress = UserProgress.fromJson(jsonDecode(json) as Map<String, dynamic>);
      progress.resetDailyXPIfNewDay();
      return progress;
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> completeLesson({
    required UserProgress progress,
    required int surahNumber,
    required int verseNumber,
    required int correctCount,
    required int totalCount,
    required int xpEarned,
  }) async {
    progress.addXP(xpEarned);
    final sp = progress.getSurahProgress(surahNumber);
    sp.completeLesson(verseNumber - 1); // verse 1 = lesson index 0
    sp.totalCorrect += correctCount;
    sp.totalAttempts += totalCount;
    await save(progress);
  }
}

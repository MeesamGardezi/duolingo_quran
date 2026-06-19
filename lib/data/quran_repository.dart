import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah.dart';

class QuranRepository {
  static QuranRepository? _instance;
  List<Surah> _loadedSurahs = [];
  List<Map<String, dynamic>> _allSurahInfo = [];
  bool _initialized = false;

  QuranRepository._();

  static QuranRepository get instance {
    _instance ??= QuranRepository._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final surahInfoStr = await rootBundle.loadString('assets/data/surah_info.json');
    final surahInfoJson = jsonDecode(surahInfoStr) as Map<String, dynamic>;
    _allSurahInfo = List<Map<String, dynamic>>.from(surahInfoJson['surahs'] as List);

    final quranDataStr = await rootBundle.loadString('assets/data/quran_data.json');
    final quranDataJson = jsonDecode(quranDataStr) as Map<String, dynamic>;
    _loadedSurahs = (quranDataJson['surahs'] as List)
        .map((s) => Surah.fromJson(s as Map<String, dynamic>))
        .toList();

    _initialized = true;
  }

  // All 114 surahs sorted by verse count (shortest first), then by surah number
  List<Map<String, dynamic>> get surahsSortedByLength {
    final sorted = List<Map<String, dynamic>>.from(_allSurahInfo);
    sorted.sort((a, b) {
      final diff = (a['totalVerses'] as int) - (b['totalVerses'] as int);
      if (diff != 0) return diff;
      return (a['number'] as int) - (b['number'] as int);
    });
    return sorted;
  }

  // Returns Surah with full verse data if available, null otherwise
  Surah? getSurah(int number) {
    try {
      return _loadedSurahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  // Returns metadata for any surah (all 114)
  Map<String, dynamic>? getSurahInfo(int number) {
    try {
      return _allSurahInfo.firstWhere((s) => s['number'] == number);
    } catch (_) {
      return null;
    }
  }

  bool hasSurahData(int number) {
    return _loadedSurahs.any((s) => s.number == number);
  }

  // Ordered lesson list: each lesson is one verse, surahs ordered by length
  List<LessonRef> get orderedLessons {
    final lessons = <LessonRef>[];
    for (final info in surahsSortedByLength) {
      final surahNum = info['number'] as int;
      final totalVerses = info['totalVerses'] as int;
      for (var verseNum = 1; verseNum <= totalVerses; verseNum++) {
        lessons.add(LessonRef(surahNumber: surahNum, verseNumber: verseNum));
      }
    }
    return lessons;
  }

  List<Surah> get loadedSurahs => List.unmodifiable(_loadedSurahs);
}

class LessonRef {
  final int surahNumber;
  final int verseNumber;

  const LessonRef({required this.surahNumber, required this.verseNumber});

  @override
  bool operator ==(Object other) =>
      other is LessonRef &&
      other.surahNumber == surahNumber &&
      other.verseNumber == verseNumber;

  @override
  int get hashCode => Object.hash(surahNumber, verseNumber);

  String get id => '${surahNumber}_$verseNumber';
}

class VocabularyItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final int surahNumber;
  final int verseNumber;
  final DateTime firstSeen;

  // Spaced repetition fields (SM-2)
  int repetitions;
  double easeFactor;
  int intervalDays;
  DateTime? nextReview;
  int timesCorrect;
  int timesWrong;

  VocabularyItem({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.surahNumber,
    required this.verseNumber,
    required this.firstSeen,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.nextReview,
    this.timesCorrect = 0,
    this.timesWrong = 0,
  });

  String get id => '${surahNumber}_${verseNumber}_$arabic';

  bool get isDueForReview {
    if (nextReview == null) return false;
    return DateTime.now().isAfter(nextReview!);
  }

  double get masteryLevel {
    final total = timesCorrect + timesWrong;
    if (total == 0) return 0;
    return timesCorrect / total;
  }

  // SM-2 algorithm: quality 0-5 (0-2 = wrong, 3-5 = correct)
  void review(int quality) {
    if (quality >= 3) {
      timesCorrect++;
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easeFactor).round();
      }
      repetitions++;
    } else {
      timesWrong++;
      repetitions = 0;
      intervalDays = 1;
    }
    easeFactor = (easeFactor +
            0.1 -
            (5 - quality) * (0.08 + (5 - quality) * 0.02))
        .clamp(1.3, 4.0);
    nextReview = DateTime.now().add(Duration(days: intervalDays));
  }

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'transliteration': transliteration,
        'meaning': meaning,
        'surahNumber': surahNumber,
        'verseNumber': verseNumber,
        'firstSeen': firstSeen.toIso8601String(),
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReview': nextReview?.toIso8601String(),
        'timesCorrect': timesCorrect,
        'timesWrong': timesWrong,
      };

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      firstSeen: DateTime.parse(json['firstSeen'] as String),
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 1,
      nextReview: json['nextReview'] != null
          ? DateTime.tryParse(json['nextReview'] as String)
          : null,
      timesCorrect: json['timesCorrect'] as int? ?? 0,
      timesWrong: json['timesWrong'] as int? ?? 0,
    );
  }
}

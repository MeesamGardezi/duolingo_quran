class Surah {
  final int number;
  final String name;
  final String arabicName;
  final String meaning;
  final int totalVerses;
  final String revelationType; // 'Meccan' or 'Medinan'
  final List<Verse> verses;

  const Surah({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.meaning,
    required this.totalVerses,
    required this.revelationType,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      arabicName: json['arabicName'] as String,
      meaning: json['meaning'] as String,
      totalVerses: json['totalVerses'] as int,
      revelationType: json['revelationType'] as String,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  // Split verses into lessons of ~5 verses each
  List<List<Verse>> get lessons {
    const lessonSize = 5;
    final result = <List<Verse>>[];
    for (var i = 0; i < verses.length; i += lessonSize) {
      result.add(verses.sublist(
        i,
        (i + lessonSize < verses.length) ? i + lessonSize : verses.length,
      ));
    }
    return result;
  }
}

class Verse {
  final int number;
  final String arabic;
  final String translation;
  final String transliteration;
  final List<QuranWord> words;

  const Verse({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.words,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'] as int,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String,
      transliteration: json['transliteration'] as String,
      words: (json['words'] as List<dynamic>? ?? [])
          .map((w) => QuranWord.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuranWord {
  final String arabic;
  final String transliteration;
  final String meaning;

  const QuranWord({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  factory QuranWord.fromJson(Map<String, dynamic> json) {
    return QuranWord(
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

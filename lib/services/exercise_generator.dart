import 'dart:math';
import '../models/surah.dart';
import '../models/exercise.dart';

class ExerciseGenerator {
  final Random _random = Random();

  List<Exercise> generateForVerse(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final exercises = <Exercise>[];

    // 1. Intro card (always first)
    exercises.add(_introExercise(verse, surahNumber));

    final hasWords = verse.words.length >= 2;

    // 2. Word-match exercises (up to 3, one per word)
    if (hasWords) {
      final wordExs = _wordMatchExercises(verse, surahNumber, allVerses);
      exercises.addAll(wordExs.take(3));
    }

    // 3. Matching pairs (if 3+ words available)
    if (verse.words.length >= 3) {
      final pairs = _matchingPairsExercise(verse, surahNumber);
      if (pairs != null) exercises.add(pairs);
    }

    // 4. Verse translation multiple choice
    exercises.add(_verseTranslationExercise(verse, surahNumber, allVerses));

    // 5. Fill in blank (Arabic)
    if (hasWords) {
      exercises.add(_fillInBlankExercise(verse, surahNumber, allVerses));
    }

    // 6. Word order (arrange meanings)
    if (verse.words.length >= 3) {
      exercises.add(_wordOrderExercise(verse, surahNumber));
    }

    // Shuffle middle exercises, keep intro first
    if (exercises.length > 2) {
      final middle = exercises.sublist(1);
      middle.shuffle(_random);
      return [exercises.first, ...middle];
    }
    return exercises;
  }

  Exercise _introExercise(Verse verse, int surahNumber) => Exercise(
        type: ExerciseType.intro,
        question: 'New verse — read and understand',
        correctAnswer: verse.translation,
        options: const [],
        arabicText: verse.arabic,
        hint: verse.transliteration,
        surahNumber: surahNumber,
        verseNumber: verse.number,
      );

  List<Exercise> _wordMatchExercises(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final exercises = <Exercise>[];
    final words = List<QuranWord>.from(verse.words)..shuffle(_random);

    for (final word in words.take(3)) {
      final distractors = _wordMeaningDistractors(word, allVerses);
      if (distractors.isEmpty) continue;
      final options = [word.meaning, ...distractors.take(3)]..shuffle(_random);

      exercises.add(Exercise(
        type: ExerciseType.translationMatch,
        question: 'What does this Arabic word mean?',
        correctAnswer: word.meaning,
        options: options,
        arabicText: word.arabic,
        hint: word.transliteration,
        surahNumber: surahNumber,
        verseNumber: verse.number,
      ));
    }
    return exercises;
  }

  Exercise? _matchingPairsExercise(Verse verse, int surahNumber) {
    final words = List<QuranWord>.from(verse.words)..shuffle(_random);
    final selected = words.take(4).toList();
    if (selected.length < 3) return null;

    final pairs = selected
        .map((w) => ExercisePair(w.arabic, w.meaning))
        .toList();

    return Exercise(
      type: ExerciseType.matchingPairs,
      question: 'Match each Arabic word with its meaning',
      correctAnswer: '',
      options: const [],
      arabicText: verse.arabic,
      surahNumber: surahNumber,
      verseNumber: verse.number,
      pairs: pairs,
    );
  }

  Exercise _verseTranslationExercise(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final distractors = allVerses
        .where((v) => v.arabic != verse.arabic)
        .map((v) => v.translation)
        .toSet()
        .toList()
      ..shuffle(_random);

    final options = [verse.translation, ...distractors.take(3)]..shuffle(_random);

    return Exercise(
      type: ExerciseType.multipleChoice,
      question: 'Select the correct translation:',
      correctAnswer: verse.translation,
      options: options,
      arabicText: verse.arabic,
      hint: verse.transliteration,
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  Exercise _fillInBlankExercise(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final wordIndex = _random.nextInt(verse.words.length);
    final target = verse.words[wordIndex];
    final blank = verse.arabic.replaceFirst(target.arabic, '______');

    final distractors = _wordArabicDistractors(target, allVerses);
    final options = [target.arabic, ...distractors.take(3)]..shuffle(_random);

    return Exercise(
      type: ExerciseType.fillInBlank,
      question: 'Fill in the missing Arabic word:',
      correctAnswer: target.arabic,
      options: options,
      arabicText: blank,
      hint: 'Meaning: ${target.meaning}',
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  Exercise _wordOrderExercise(Verse verse, int surahNumber) {
    final meanings =
        verse.words.map((w) => w.meaning).where((m) => m.length > 2).toList();
    final shuffled = List<String>.from(meanings)..shuffle(_random);

    return Exercise(
      type: ExerciseType.wordOrder,
      question: 'Arrange word meanings in the correct order:',
      correctAnswer: meanings.join('|'),
      options: shuffled,
      arabicText: verse.arabic,
      hint: verse.transliteration,
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  List<String> _wordMeaningDistractors(QuranWord word, List<Verse> allVerses) {
    final all = allVerses
        .expand((v) => v.words)
        .where((w) => w.arabic != word.arabic && w.meaning != word.meaning)
        .map((w) => w.meaning)
        .toSet()
        .toList()
      ..shuffle(_random);
    return all;
  }

  List<String> _wordArabicDistractors(QuranWord word, List<Verse> allVerses) {
    final all = allVerses
        .expand((v) => v.words)
        .where((w) => w.arabic != word.arabic)
        .map((w) => w.arabic)
        .toSet()
        .toList()
      ..shuffle(_random);
    return all;
  }

  // Generates review exercises from a list of vocabulary items
  List<Exercise> generateReviewExercises(
    List<dynamic> items, // VocabularyItem list
    List<Verse> allVerses,
  ) {
    final exercises = <Exercise>[];
    for (final item in items.take(10)) {
      final distractors = allVerses
          .expand((v) => v.words)
          .where((w) => w.arabic != item.arabic)
          .map((w) => w.meaning as String)
          .toSet()
          .toList()
        ..shuffle(_random);

      final options = [item.meaning as String, ...distractors.take(3)]
        ..shuffle(_random);

      exercises.add(Exercise(
        type: ExerciseType.translationMatch,
        question: 'What does this word mean?',
        correctAnswer: item.meaning as String,
        options: options,
        arabicText: item.arabic as String,
        hint: item.transliteration as String,
        surahNumber: item.surahNumber as int,
        verseNumber: item.verseNumber as int,
      ));
    }
    exercises.shuffle(_random);
    return exercises;
  }
}

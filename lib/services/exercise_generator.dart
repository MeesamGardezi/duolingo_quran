import 'dart:math';
import '../models/surah.dart';
import '../models/exercise.dart';

class ExerciseGenerator {
  final Random _random = Random();

  // Generates a full set of exercises for one verse (1 lesson)
  List<Exercise> generateForVerse(Verse verse, int surahNumber, List<Verse> allVerses) {
    final exercises = <Exercise>[];

    // 1. Always start: see the full verse (translation reveal)
    exercises.add(_introExercise(verse, surahNumber));

    // 2. Word-by-word matching exercises (for each word in the verse)
    if (verse.words.isNotEmpty) {
      final wordExercises = _wordMatchExercises(verse, surahNumber, allVerses);
      exercises.addAll(wordExercises.take(3)); // max 3 word exercises
    }

    // 3. Full verse translation (multiple choice)
    exercises.add(_verseTranslationExercise(verse, surahNumber, allVerses));

    // 4. Word order exercise (arrange English words)
    if (verse.words.length >= 3) {
      exercises.add(_wordOrderExercise(verse, surahNumber));
    }

    // 5. Fill in blank (Arabic verse, one word missing)
    if (verse.words.length >= 2) {
      exercises.add(_fillInBlankExercise(verse, surahNumber, allVerses));
    }

    // Shuffle middle exercises but keep intro first and a recap last
    if (exercises.length > 2) {
      final middle = exercises.sublist(1, exercises.length - 1);
      middle.shuffle(_random);
      return [exercises.first, ...middle, exercises.last];
    }
    return exercises;
  }

  Exercise _introExercise(Verse verse, int surahNumber) {
    return Exercise(
      type: ExerciseType.multipleChoice,
      question: 'Read this verse and its meaning:',
      correctAnswer: verse.translation,
      options: [verse.translation],
      arabicText: verse.arabic,
      hint: verse.transliteration,
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  List<Exercise> _wordMatchExercises(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final exercises = <Exercise>[];
    final wordsToTest = List<QuranWord>.from(verse.words)..shuffle(_random);

    for (final word in wordsToTest.take(3)) {
      final distractors = _getWordDistractors(word, verse, allVerses);
      final options = [word.meaning, ...distractors]..shuffle(_random);

      exercises.add(Exercise(
        type: ExerciseType.translationMatch,
        question: 'What does this word mean?',
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

  Exercise _verseTranslationExercise(
    Verse verse,
    int surahNumber,
    List<Verse> allVerses,
  ) {
    final distractors = _getVerseDistractors(verse, allVerses);
    final options = [verse.translation, ...distractors]..shuffle(_random);

    return Exercise(
      type: ExerciseType.multipleChoice,
      question: 'Select the correct translation:',
      correctAnswer: verse.translation,
      options: options,
      arabicText: verse.arabic,
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  Exercise _wordOrderExercise(Verse verse, int surahNumber) {
    // Take key words from the translation, shuffle them
    final meaningWords = verse.words
        .map((w) => w.meaning)
        .where((m) => m.length > 2)
        .toList();

    final shuffled = List<String>.from(meaningWords)..shuffle(_random);

    return Exercise(
      type: ExerciseType.wordOrder,
      question: 'Arrange the word meanings in order:',
      correctAnswer: meaningWords.join(' | '),
      options: shuffled,
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
    final targetWord = verse.words[wordIndex];

    final arabicWithBlank = verse.arabic.replaceFirst(
      targetWord.arabic,
      '______',
    );

    final distractors = _getWordDistractors(targetWord, verse, allVerses);
    final options = [targetWord.arabic, ...distractors.take(3)]..shuffle(_random);

    return Exercise(
      type: ExerciseType.fillInBlank,
      question: 'Fill in the missing Arabic word:',
      correctAnswer: targetWord.arabic,
      options: options,
      arabicText: arabicWithBlank,
      hint: 'Meaning: ${targetWord.meaning}',
      surahNumber: surahNumber,
      verseNumber: verse.number,
    );
  }

  List<String> _getWordDistractors(
    QuranWord word,
    Verse verse,
    List<Verse> allVerses,
  ) {
    final allWords = <QuranWord>[];
    for (final v in allVerses) {
      allWords.addAll(v.words);
    }

    final candidates = allWords
        .where((w) => w.arabic != word.arabic && w.meaning != word.meaning)
        .map((w) => w.meaning)
        .toSet()
        .toList();

    candidates.shuffle(_random);
    return candidates.take(3).toList();
  }

  List<String> _getVerseDistractors(Verse verse, List<Verse> allVerses) {
    final candidates = allVerses
        .where((v) => v.arabic != verse.arabic)
        .map((v) => v.translation)
        .toList();
    candidates.shuffle(_random);
    return candidates.take(3).toList();
  }
}

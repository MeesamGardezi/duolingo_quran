enum ExerciseType {
  translationMatch,   // Tap the correct translation of an Arabic word
  fillInBlank,        // Fill in the missing word in a verse
  wordOrder,          // Arrange English words to match verse meaning
  multipleChoice,     // Pick the correct translation of a full verse
  tapWhatYouHear,     // (future) Tap the Arabic words you hear
}

class Exercise {
  final ExerciseType type;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String? arabicText;
  final String? hint;
  final int surahNumber;
  final int verseNumber;

  const Exercise({
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.arabicText,
    this.hint,
    required this.surahNumber,
    required this.verseNumber,
  });
}

class LessonSession {
  final int surahNumber;
  final int lessonIndex;
  final List<Exercise> exercises;
  int currentIndex;
  int correctCount;
  int hearts;
  final int xpReward;

  LessonSession({
    required this.surahNumber,
    required this.lessonIndex,
    required this.exercises,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.hearts = 3,
    this.xpReward = 10,
  });

  bool get isComplete => currentIndex >= exercises.length;
  Exercise get currentExercise => exercises[currentIndex];
  double get progress => exercises.isEmpty ? 0 : currentIndex / exercises.length;
  bool get isPerfect => correctCount == exercises.length;

  void advance() => currentIndex++;
  void recordCorrect() => correctCount++;
  void loseHeart() => hearts = (hearts - 1).clamp(0, 3);
}

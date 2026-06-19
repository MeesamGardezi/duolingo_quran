enum ExerciseType {
  intro,           // Show verse + meaning, tap "Got it"
  translationMatch, // Arabic word → pick English meaning
  fillInBlank,      // Verse with one word blanked, pick Arabic word
  wordOrder,        // Arrange English word meanings in order
  multipleChoice,   // Arabic verse → pick correct English translation
  matchingPairs,    // Tap 4 Arabic words + 4 meanings to match them
}

class ExercisePair {
  final String arabic;
  final String meaning;
  const ExercisePair(this.arabic, this.meaning);
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
  final List<ExercisePair>? pairs; // for matchingPairs type

  const Exercise({
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.arabicText,
    this.hint,
    required this.surahNumber,
    required this.verseNumber,
    this.pairs,
  });
}

class LessonSession {
  final int surahNumber;
  final int lessonIndex; // = verseNumber - 1
  final List<Exercise> exercises;
  int currentIndex;
  int correctCount;
  int wrongCount;
  final int xpReward;

  LessonSession({
    required this.surahNumber,
    required this.lessonIndex,
    required this.exercises,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.xpReward = 10,
  });

  bool get isComplete => currentIndex >= exercises.length;
  Exercise get currentExercise => exercises[currentIndex];
  double get progress =>
      exercises.isEmpty ? 0 : currentIndex / exercises.length;
  bool get isPerfect => wrongCount == 0 && exercises.isNotEmpty;

  void advance() => currentIndex++;
  void recordCorrect() => correctCount++;
  void recordWrong() => wrongCount++;
}

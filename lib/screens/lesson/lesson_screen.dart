import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/app_provider.dart';
import '../../data/quran_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_bar.dart';
import '../exercises/exercise_base.dart';
import '../exercises/translation_match.dart';
import '../exercises/multiple_choice.dart';
import '../exercises/fill_in_blank.dart';
import '../exercises/word_order.dart';
import 'lesson_complete_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonRef lessonRef;

  const LessonScreen({super.key, required this.lessonRef});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  LessonSession? _session;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildSession());
  }

  void _buildSession() {
    final provider = context.read<AppProvider>();
    final session = provider.buildLesson(widget.lessonRef);
    setState(() => _session = session);
  }

  void _onAnswer(bool isCorrect) {
    final session = _session!;
    if (isCorrect) session.recordCorrect();
    if (!isCorrect) session.loseHeart();
    session.advance();

    if (session.isComplete) {
      _onLessonComplete();
    } else {
      setState(() {});
    }
  }

  Future<void> _onLessonComplete() async {
    final provider = context.read<AppProvider>();
    await provider.recordLessonComplete(_session!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LessonCompleteScreen(session: _session!),
      ),
    );
  }

  void _onClose() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quit lesson?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Your progress in this lesson will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('KEEP GOING'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'QUIT',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = _session!;

    if (session.isComplete) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final exercise = session.currentExercise;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LessonProgressBar(
              progress: session.progress,
              hearts: session.hearts,
              onClose: _onClose,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(session.currentIndex),
                    child: _buildExercise(exercise),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercise(Exercise exercise) {
    // First exercise in the lesson is always the intro card
    final isIntro = _session!.currentIndex == 0 &&
        exercise.type == ExerciseType.multipleChoice;

    switch (exercise.type) {
      case ExerciseType.translationMatch:
        return TranslationMatchExercise(
          exercise: exercise,
          onAnswer: _onAnswer,
        );
      case ExerciseType.multipleChoice:
        return MultipleChoiceExercise(
          exercise: exercise,
          onAnswer: _onAnswer,
          isIntro: isIntro,
        );
      case ExerciseType.fillInBlank:
        return FillInBlankExercise(
          exercise: exercise,
          onAnswer: _onAnswer,
        );
      case ExerciseType.wordOrder:
        return WordOrderExercise(
          exercise: exercise,
          onAnswer: _onAnswer,
        );
      case ExerciseType.tapWhatYouHear:
        return MultipleChoiceExercise(
          exercise: exercise,
          onAnswer: _onAnswer,
        );
    }
  }
}

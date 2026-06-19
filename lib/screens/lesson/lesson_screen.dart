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
import '../exercises/matching_pairs.dart';
import 'lesson_complete_screen.dart';

class LessonScreen extends StatefulWidget {
  final LessonRef lessonRef;
  final bool isReview;
  final bool isDailyChallenge;

  const LessonScreen({
    super.key,
    required this.lessonRef,
    this.isReview = false,
    this.isDailyChallenge = false,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  LessonSession? _session;
  late int _hearts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildSession());
  }

  void _buildSession() {
    final provider = context.read<AppProvider>();
    _hearts = provider.hearts;

    LessonSession? session;
    if (widget.isDailyChallenge) {
      session = provider.buildDailyChallenge();
    } else if (widget.isReview && widget.lessonRef.surahNumber == 0) {
      session = provider.buildReviewSession();
    } else {
      session = provider.buildLesson(widget.lessonRef);
    }
    setState(() => _session = session);
  }

  Future<void> _onAnswer(bool isCorrect) async {
    final provider = context.read<AppProvider>();
    final session = _session!;

    if (isCorrect) {
      session.recordCorrect();
    } else {
      session.recordWrong();
      if (_hearts > 0) {
        await provider.loseHeart();
        setState(() => _hearts = provider.hearts);
      }
    }

    session.advance();

    if (session.isComplete) {
      await _onLessonComplete();
    } else {
      setState(() {});
    }
  }

  Future<void> _onLessonComplete() async {
    final provider = context.read<AppProvider>();
    if (widget.isDailyChallenge) {
      await provider.recordDailyChallengeComplete(_session!);
    } else if (!widget.isReview) {
      await provider.recordLessonComplete(_session!);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LessonCompleteScreen(
          session: _session!,
          isReview: widget.isReview || widget.isDailyChallenge,
          isDailyChallenge: widget.isDailyChallenge,
        ),
      ),
    );
  }

  void _onClose() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Your progress in this lesson will be lost.'),
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
            child: Text('QUIT',
                style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final session = _session!;
    if (session.isComplete) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final exercise = session.currentExercise;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LessonProgressBar(
              progress: session.progress,
              hearts: _hearts,
              onClose: _onClose,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOut)),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
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
    switch (exercise.type) {
      case ExerciseType.intro:
        return _IntroExercise(exercise: exercise, onContinue: () => _onAnswer(true));
      case ExerciseType.translationMatch:
        return TranslationMatchExercise(
            exercise: exercise, onAnswer: _onAnswer);
      case ExerciseType.multipleChoice:
        return MultipleChoiceExercise(
            exercise: exercise, onAnswer: _onAnswer);
      case ExerciseType.fillInBlank:
        return FillInBlankExercise(exercise: exercise, onAnswer: _onAnswer);
      case ExerciseType.wordOrder:
        return WordOrderExercise(exercise: exercise, onAnswer: _onAnswer);
      case ExerciseType.matchingPairs:
        return MatchingPairsExercise(
            exercise: exercise, onAnswer: _onAnswer);
    }
  }
}

// Inline intro card — no longer inside multiple_choice.dart
class _IntroExercise extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onContinue;

  const _IntroExercise(
      {required this.exercise, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'NEW VERSE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Read and understand',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8F0),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.primaryLight, width: 2),
          ),
          child: Column(
            children: [
              Text(
                exercise.arabicText ?? '',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 26,
                  color: AppColors.arabicGreen,
                  height: 2.0,
                ),
              ),
              const Divider(height: 24, color: AppColors.cardBorder),
              Text(
                exercise.hint ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.correctAnswer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('GOT IT'),
        ),
      ],
    );
  }
}

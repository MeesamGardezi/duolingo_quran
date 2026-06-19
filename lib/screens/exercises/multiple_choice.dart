import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../widgets/arabic_text.dart';
import 'exercise_base.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onAnswer;
  final bool isIntro; // intro card just shows verse + continue

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isIntro = false,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selected;
  bool? _isCorrect;

  void _select(String option) {
    if (_isCorrect != null) return;
    final correct = option == widget.exercise.correctAnswer;
    setState(() {
      _selected = option;
      _isCorrect = correct;
    });
    if (correct) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onAnswer(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    if (widget.isIntro) {
      return _IntroCard(exercise: ex, onContinue: () => widget.onAnswer(true));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(ex.question),
        const SizedBox(height: 24),
        if (ex.arabicText != null)
          ArabicVerseCard(
            arabic: ex.arabicText!,
            transliteration: ex.hint,
          ),
        const SizedBox(height: 24),
        ...ex.options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OptionButton(
                text: opt,
                selected: _selected == opt,
                correct: _isCorrect != null && _selected == opt
                    ? _isCorrect
                    : (_isCorrect == false && opt == ex.correctAnswer
                        ? true
                        : null),
                onTap: () => _select(opt),
              ),
            )),
        if (_isCorrect != null)
          AnswerFeedbackBar(
            isCorrect: _isCorrect,
            correctAnswer: ex.correctAnswer,
            onContinue: () => widget.onAnswer(_isCorrect!),
          ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onContinue;

  const _IntroCard({required this.exercise, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'New Verse',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF58CC02),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Learn its meaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3C3C3C),
          ),
        ),
        const SizedBox(height: 28),
        ArabicVerseCard(
          arabic: exercise.arabicText ?? '',
          transliteration: exercise.hint,
          translation: exercise.correctAnswer,
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('GOT IT'),
        ),
      ],
    );
  }
}

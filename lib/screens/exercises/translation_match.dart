import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../widgets/arabic_text.dart';
import 'exercise_base.dart';

class TranslationMatchExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onAnswer;

  const TranslationMatchExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<TranslationMatchExercise> createState() => _TranslationMatchExerciseState();
}

class _TranslationMatchExerciseState extends State<TranslationMatchExercise> {
  String? _selected;
  bool? _isCorrect;

  void _select(String option) {
    if (_isCorrect != null) return;
    final correct = option == widget.exercise.correctAnswer;
    setState(() {
      _selected = option;
      _isCorrect = correct;
    });
    // Delay before calling onAnswer to show feedback
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _isCorrect == true) {
        widget.onAnswer(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(ex.question),
        const SizedBox(height: 32),
        if (ex.arabicText != null) ...[
          Center(
            child: ArabicText(ex.arabicText!, fontSize: 40),
          ),
          if (ex.hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ex.hint!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
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
        if (_isCorrect != null) ...[
          const SizedBox(height: 8),
          AnswerFeedbackBar(
            isCorrect: _isCorrect,
            correctAnswer: ex.correctAnswer,
            onContinue: () => widget.onAnswer(_isCorrect!),
          ),
        ],
      ],
    );
  }
}

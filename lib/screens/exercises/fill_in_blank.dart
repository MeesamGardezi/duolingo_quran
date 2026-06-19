import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';
import '../../widgets/arabic_text.dart';
import 'exercise_base.dart';

class FillInBlankExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onAnswer;

  const FillInBlankExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<FillInBlankExercise> createState() => _FillInBlankExerciseState();
}

class _FillInBlankExerciseState extends State<FillInBlankExercise> {
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
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onAnswer(true);
      });
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(ex.question),
        const SizedBox(height: 8),
        if (ex.hint != null)
          Text(
            ex.hint!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7FFB8), width: 2),
          ),
          child: ArabicText(
            ex.arabicText ?? '',
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Choose the missing word:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 12),
        ...ex.options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OptionButton(
                text: opt,
                isArabic: true,
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

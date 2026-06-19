import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../widgets/arabic_text.dart';
import 'exercise_base.dart';
import '../../theme/app_theme.dart';

class WordOrderExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onAnswer;

  const WordOrderExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<WordOrderExercise> createState() => _WordOrderExerciseState();
}

class _WordOrderExerciseState extends State<WordOrderExercise> {
  late List<String> _bank;       // words not yet placed
  final List<String> _answer = [];
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _bank = List<String>.from(widget.exercise.options);
  }

  void _addWord(String word) {
    if (_isCorrect != null) return;
    setState(() {
      _bank.remove(word);
      _answer.add(word);
    });
  }

  void _removeWord(String word) {
    if (_isCorrect != null) return;
    setState(() {
      _answer.remove(word);
      _bank.add(word);
    });
  }

  void _checkAnswer() {
    final correct = _answer.join(' | ') == widget.exercise.correctAnswer;
    setState(() => _isCorrect = correct);
    if (correct) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onAnswer(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final canCheck = _answer.isNotEmpty && _bank.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(ex.question),
        const SizedBox(height: 16),
        if (ex.arabicText != null)
          ArabicVerseCard(
            arabic: ex.arabicText!,
            transliteration: ex.hint,
          ),
        const SizedBox(height: 24),

        // Answer zone
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isCorrect == null
                  ? AppColors.cardBorder
                  : (_isCorrect! ? AppColors.primary : AppColors.red),
              width: 2,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _answer
                .map((w) => _Chip(
                      text: w,
                      active: true,
                      onTap: () => _removeWord(w),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Word bank
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _bank
              .map((w) => _Chip(
                    text: w,
                    active: false,
                    onTap: () => _addWord(w),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),

        if (_isCorrect == null && canCheck)
          ElevatedButton(
            onPressed: _checkAnswer,
            child: const Text('CHECK'),
          ),

        if (_isCorrect != null)
          AnswerFeedbackBar(
            isCorrect: _isCorrect,
            correctAnswer: ex.correctAnswer.replaceAll(' | ', ' '),
            onContinue: () => widget.onAnswer(_isCorrect!),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8F7FF) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.blue : AppColors.cardBorder,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.blueDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

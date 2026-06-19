import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';

class ExerciseResult {
  final bool isCorrect;
  ExerciseResult(this.isCorrect);
}

abstract class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final void Function(bool isCorrect) onAnswer;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });
}

// ── Shared UI Pieces ──────────────────────────────────────────────────────────

class QuestionLabel extends StatelessWidget {
  final String text;
  const QuestionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class AnswerFeedbackBar extends StatelessWidget {
  final bool? isCorrect; // null = not answered yet
  final String correctAnswer;
  final VoidCallback onContinue;

  const AnswerFeedbackBar({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    if (isCorrect == null) {
      return const SizedBox.shrink();
    }

    final correct = isCorrect!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: correct ? AppColors.primaryLight : AppColors.redLight,
        border: Border(
          top: BorderSide(
            color: correct ? AppColors.primary : AppColors.red,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: correct ? AppColors.primaryDark : AppColors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  correct ? 'Excellent!' : 'Correct answer:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: correct ? AppColors.primaryDark : AppColors.red,
                  ),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: 4),
              Text(
                correctAnswer,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: correct ? AppColors.primary : AppColors.red,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final bool? correct; // null=unselected, true=correct, false=wrong
  final VoidCallback? onTap;
  final bool isArabic;

  const OptionButton({
    super.key,
    required this.text,
    this.selected = false,
    this.correct,
    this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.cardBorder;
    Color bgColor = AppColors.surface;
    Color textColor = AppColors.textPrimary;

    if (correct == true) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryLight;
      textColor = AppColors.primaryDark;
    } else if (correct == false) {
      borderColor = AppColors.red;
      bgColor = AppColors.redLight;
      textColor = AppColors.red;
    } else if (selected) {
      borderColor = AppColors.blue;
      bgColor = const Color(0xFFE8F7FF);
      textColor = AppColors.blueDark;
    }

    return GestureDetector(
      onTap: correct == null
          ? onTap != null
              ? () {
                  HapticFeedback.selectionClick();
                  onTap!();
                }
              : null
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        child: isArabic
            ? Text(
                text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.8,
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

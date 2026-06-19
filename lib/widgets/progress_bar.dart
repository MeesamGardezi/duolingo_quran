import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LessonProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int hearts;
  final VoidCallback onClose;

  const LessonProgressBar({
    super.key,
    required this.progress,
    required this.hearts,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _HeartsDisplay(hearts: hearts),
        ],
      ),
    );
  }
}

class _HeartsDisplay extends StatelessWidget {
  final int hearts;

  const _HeartsDisplay({required this.hearts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            Icons.favorite,
            size: 22,
            color: i < hearts ? AppColors.heartRed : AppColors.cardBorder,
          ),
        );
      }),
    );
  }
}

class XPProgressBar extends StatelessWidget {
  final int todayXP;
  final int goal;

  const XPProgressBar({super.key, required this.todayXP, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (todayXP / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Goal',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              '$todayXP / $goal XP',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.cardBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        ),
      ],
    );
  }
}

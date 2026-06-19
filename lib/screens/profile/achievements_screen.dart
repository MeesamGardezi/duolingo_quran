import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  final List<Achievement> achievements;
  const AchievementsScreen({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements (${unlocked.length}/${achievements.length})'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unlocked.isNotEmpty) ...[
            const _SectionHeader(title: 'Unlocked', emoji: '🏆'),
            const SizedBox(height: 10),
            ...unlocked.map((a) => _AchievementRow(achievement: a)),
            const SizedBox(height: 20),
          ],
          if (locked.isNotEmpty) ...[
            const _SectionHeader(title: 'Locked', emoji: '🔒'),
            const SizedBox(height: 10),
            ...locked.map((a) => _AchievementRow(achievement: a)),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final Achievement achievement;
  const _AchievementRow({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? AppColors.gold : AppColors.cardBorder,
          width: unlocked ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.gold.withOpacity(0.15)
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 26,
                  color: unlocked ? null : Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: unlocked
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                if (unlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Earned ${_formatDate(achievement.unlockedAt!)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: AppColors.gold, size: 22),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/achievement.dart';
import '../settings/settings_screen.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final p = provider.progress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          _AvatarSection(
              name: p.userName.isEmpty ? 'Learner' : p.userName,
              level: p.level),
          const SizedBox(height: 20),

          // XP level bar
          _LevelCard(
              level: p.level,
              xpInLevel: p.xpInCurrentLevel,
              xpToNext: p.xpToNextLevel,
              totalXP: p.totalXP),
          const SizedBox(height: 16),

          // Streak + hearts row
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                icon: '🔥',
                label: 'Current Streak',
                value: '${p.streak} days',
                color: AppColors.streakOrange,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                icon: '🏆',
                label: 'Best Streak',
                value: '${p.longestStreak} days',
                color: AppColors.gold,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                icon: '📖',
                label: 'Lessons Done',
                value: '${p.totalLessonsCompleted}',
                color: AppColors.blue,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                icon: '⭐',
                label: 'Perfect Lessons',
                value: '${p.totalPerfectLessons}',
                color: AppColors.primary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                icon: '🔤',
                label: 'Words Learned',
                value: '${p.vocabularyCount}',
                color: AppColors.arabicGreen,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                icon: '❤️',
                label: 'Hearts',
                value: '${provider.hearts} / 5',
                color: AppColors.heartRed,
              )),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly streak calendar
          _WeeklyStreakCalendar(lastStudyDate: p.lastStudyDate, streak: p.streak),
          const SizedBox(height: 20),

          // Leaderboard button
          _LeaderboardButton(
            level: p.level,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          const SizedBox(height: 16),

          // Achievements section
          _AchievementsPreview(
            achievements: p.achievements,
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AchievementsScreen(achievements: p.achievements)),
            ),
          ),
          const SizedBox(height: 20),

          // Hearts refill timer
          _HeartsRefillCard(provider: provider),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String name;
  final int level;
  const _AvatarSection({required this.name, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Center(
                child: Text('🕌', style: TextStyle(fontSize: 42)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Lvl $level',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final int xpInLevel;
  final int xpToNext;
  final int totalXP;

  const _LevelCard({
    required this.level,
    required this.xpInLevel,
    required this.xpToNext,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpInLevel / 500;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level $level',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.textPrimary)),
              Text('$totalXP total XP',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.cardBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$xpInLevel XP',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text('$xpToNext XP to Level ${level + 1}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LeaderboardButton extends StatelessWidget {
  final int level;
  final VoidCallback onTap;

  const _LeaderboardButton({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Mirror league tiers from leaderboard_screen.dart
    final tiers = [
      ('Bronze', const Color(0xFFCD7F32)),
      ('Silver', const Color(0xFF9E9E9E)),
      ('Gold', const Color(0xFFFFD700)),
      ('Sapphire', const Color(0xFF1E88E5)),
      ('Ruby', const Color(0xFFE53935)),
      ('Emerald', const Color(0xFF43A047)),
      ('Amethyst', const Color(0xFF8E24AA)),
      ('Pearl', const Color(0xFF26C6DA)),
      ('Obsidian', const Color(0xFF37474F)),
      ('Diamond', const Color(0xFF29B6F6)),
    ];
    final idx = ((level - 1) ~/ 2).clamp(0, tiers.length - 1);
    final tierName = tiers[idx].$1;
    final tierColor = tiers[idx].$2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tierColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tierColor.withOpacity(0.4), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tierName League',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: tierColor,
                    ),
                  ),
                  const Text(
                    'See your weekly ranking',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: tierColor),
          ],
        ),
      ),
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback onSeeAll;

  const _AchievementsPreview(
      {required this.achievements, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements (${unlocked.length}/${achievements.length})',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        unlocked.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: const Text(
                  'Complete your first lesson to earn achievements!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: unlocked
                    .take(6)
                    .map((a) => _AchievementBadge(achievement: a))
                    .toList(),
              ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.title,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
        ),
        child: Center(
          child: Text(achievement.emoji,
              style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

class _WeeklyStreakCalendar extends StatelessWidget {
  final DateTime? lastStudyDate;
  final int streak;

  const _WeeklyStreakCalendar(
      {required this.lastStudyDate, required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build last 7 days
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    // Determine which days had activity based on streak and lastStudyDate
    final studiedDays = <DateTime>{};
    if (lastStudyDate != null && streak > 0) {
      final lastDay = DateTime(
        lastStudyDate!.year,
        lastStudyDate!.month,
        lastStudyDate!.day,
      );
      for (var i = 0; i < streak && i < 7; i++) {
        studiedDays.add(lastDay.subtract(Duration(days: i)));
      }
    }

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final day = entry.value;
              final weekday = (day.weekday - 1) % 7; // 0=Mon
              final label = dayLabels[weekday];
              final isStudied = studiedDays.contains(day);
              final isToday = day == today;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isStudied
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primaryLight
                              : AppColors.background,
                      shape: BoxShape.circle,
                      border: isToday && !isStudied
                          ? Border.all(
                              color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isStudied
                          ? const Text('🔥',
                              style: TextStyle(fontSize: 16))
                          : Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? AppColors.primaryDark
                                    : AppColors.textLight,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isStudied
                          ? AppColors.primary
                          : AppColors.textLight,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HeartsRefillCard extends StatelessWidget {
  final AppProvider provider;
  const _HeartsRefillCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hearts = provider.hearts;
    if (hearts >= 5) return const SizedBox.shrink();

    final timeLeft = provider.progress.timeUntilNextHeart;
    final mins = timeLeft.inMinutes;
    final secs = timeLeft.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.heartRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('❤️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$hearts / 5 hearts',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.heartRed,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Next heart in ${mins}m ${secs}s',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Text(
            'Complete a review to earn hearts faster!',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

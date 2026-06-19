import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/quran_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_bar.dart';
import '../lesson/lesson_screen.dart';
import 'surah_list_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (ctx, provider, _) {
                  if (!provider.initialized) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  return _LessonPath(provider: provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final p = provider.progress;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
                bottom:
                    BorderSide(color: AppColors.cardBorder, width: 1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _StatBadge(
                    icon: Icons.local_fire_department,
                    value: '${p.streak}',
                    color: AppColors.streakOrange,
                  ),
                  const SizedBox(width: 16),
                  _StatBadge(
                    icon: Icons.bolt,
                    value: '${p.totalXP}',
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 16),
                  _HeartsDisplay(hearts: provider.hearts),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SurahListScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primary, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.menu_book,
                                  color: AppColors.primary, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'All Surahs',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: AppColors.textSecondary, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              XPProgressBar(
                  todayXP: p.todayXP, goal: p.dailyXPGoal),
            ],
          ),
        );
      },
    );
  }
}

class _HeartsDisplay extends StatelessWidget {
  final int hearts;
  const _HeartsDisplay({required this.hearts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite,
            color: AppColors.heartRed, size: 18),
        const SizedBox(width: 3),
        Text(
          '$hearts',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.heartRed,
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatBadge(
      {required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color)),
      ],
    );
  }
}

class _LessonPath extends StatelessWidget {
  final AppProvider provider;
  const _LessonPath({required this.provider});

  @override
  Widget build(BuildContext context) {
    final lessons = provider.orderedLessons;
    if (lessons.isEmpty) {
      return const Center(child: Text('No lessons found'));
    }

    final items = <_PathItem>[];
    int? lastSurah;
    for (final ref in lessons) {
      if (ref.surahNumber != lastSurah) {
        items.add(_PathItem.header(ref.surahNumber));
        lastSurah = ref.surahNumber;
      }
      items.add(_PathItem.lesson(ref));
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i == 0) {
                  return Column(
                    children: [
                      _DailyChallengeCard(provider: provider),
                      const SizedBox(height: 8),
                      _WordOfTheDayCard(provider: provider),
                      const SizedBox(height: 4),
                    ],
                  );
                }
                return _buildItem(ctx, items[i - 1]);
              },
              childCount: items.length + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, _PathItem item) {
    if (item.isSurahHeader) {
      return _SurahHeader(surahNumber: item.surahNumber!);
    }

    final ref = item.lessonRef!;
    final isComplete = provider.isLessonComplete(ref);
    final isUnlocked = provider.isLessonUnlocked(ref);
    final isNext = provider.nextLesson == ref;

    return _LessonNode(
      ref: ref,
      isComplete: isComplete,
      isUnlocked: isUnlocked,
      isNext: isNext,
      onTap: isUnlocked
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(lessonRef: ref),
                ),
              )
          : null,
    );
  }
}

class _WordOfTheDayCard extends StatelessWidget {
  final AppProvider provider;
  const _WordOfTheDayCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final word = provider.wordOfTheDay;
    if (word == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📝', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WORD OF THE DAY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: AppColors.arabicGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  word.meaning,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            word.transliteration,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final AppProvider provider;
  const _DailyChallengeCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final available = provider.isDailyChallengeAvailable;
    final hasLessons = provider.completedLessonsCount > 0;

    if (!hasLessons) return const SizedBox.shrink();

    return GestureDetector(
      onTap: available
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    lessonRef: LessonRef(surahNumber: 0, verseNumber: 0),
                    isDailyChallenge: true,
                  ),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: available
                ? [const Color(0xFFFFC800), const Color(0xFFFF9600)]
                : [AppColors.cardBorder, AppColors.cardBorder],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: available
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              available ? '⚡' : '✅',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Challenge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: available ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    available
                        ? 'Earn 30 XP — mixed review!'
                        : 'Completed — come back tomorrow',
                    style: TextStyle(
                      fontSize: 12,
                      color: available
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (available)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF9600),
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PathItem {
  final int? surahNumber;
  final LessonRef? lessonRef;
  _PathItem.header(this.surahNumber) : lessonRef = null;
  _PathItem.lesson(this.lessonRef) : surahNumber = null;
  bool get isSurahHeader => surahNumber != null;
}

class _SurahHeader extends StatelessWidget {
  final int surahNumber;
  const _SurahHeader({required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    final info = QuranRepository.instance.getSurahInfo(surahNumber);
    if (info == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$surahNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      info['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      info['arabicName'] as String,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: AppColors.arabicGreen,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${info['meaning']} · ${info['totalVerses']} verses',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final LessonRef ref;
  final bool isComplete;
  final bool isUnlocked;
  final bool isNext;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.ref,
    required this.isComplete,
    required this.isUnlocked,
    required this.isNext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor, borderColor, iconColor;
    IconData icon;

    if (isComplete) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primaryDark;
      iconColor = Colors.white;
      icon = Icons.check;
    } else if (isNext) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primaryDark;
      iconColor = Colors.white;
      icon = Icons.star;
    } else if (isUnlocked) {
      bgColor = AppColors.surface;
      borderColor = AppColors.primary;
      iconColor = AppColors.primary;
      icon = Icons.menu_book_outlined;
    } else {
      bgColor = AppColors.surface;
      borderColor = AppColors.cardBorder;
      iconColor = AppColors.textLight;
      icon = Icons.lock_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: isNext
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verse ${ref.verseNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isUnlocked
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'START HERE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/quran_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_bar.dart';
import '../lesson/lesson_screen.dart';
import 'surah_list_screen.dart';

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
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _LessonPath(provider: provider);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
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
            border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
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
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SurahListScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.menu_book, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Surahs',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              XPProgressBar(todayXP: p.todayXP, goal: p.dailyXPGoal),
            ],
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatBadge({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
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

    // Group by surah for section headers
    return CustomScrollView(
      slivers: _buildSlivers(context, lessons),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, List<LessonRef> lessons) {
    final slivers = <Widget>[];
    int? lastSurah;

    // We'll build lesson nodes with surah headers
    final items = <_PathItem>[];
    for (final ref in lessons) {
      if (ref.surahNumber != lastSurah) {
        items.add(_PathItem.header(ref.surahNumber));
        lastSurah = ref.surahNumber;
      }
      items.add(_PathItem.lesson(ref));
    }

    slivers.add(
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _buildPathItem(ctx, items[i]),
            childCount: items.length,
          ),
        ),
      ),
    );
    return slivers;
  }

  Widget _buildPathItem(BuildContext context, _PathItem item) {
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
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$surahNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${info['arabicName']} · ${info['meaning']} · ${info['totalVerses']} verses',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
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
    Color bgColor;
    Color borderColor;
    Color iconColor;
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: isNext
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verse ${ref.verseNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textLight,
                    ),
                  ),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'START HERE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home, label: 'Learn', active: true),
              _NavItem(icon: Icons.bar_chart, label: 'Progress', active: false),
              _NavItem(icon: Icons.person, label: 'Profile', active: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textLight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

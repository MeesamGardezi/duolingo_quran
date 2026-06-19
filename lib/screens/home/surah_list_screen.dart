import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/quran_repository.dart';
import '../../theme/app_theme.dart';
import '../lesson/lesson_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allSurahs = provider.surahsSortedByLength;

    final available = allSurahs
        .where((s) => QuranRepository.instance.hasSurahData(s['number'] as int))
        .toList();
    final inProgress = available.where((s) {
      final num = s['number'] as int;
      final total = s['totalVerses'] as int;
      final done = provider.progress.surahProgress[num]?.completedLessons.length ?? 0;
      return done > 0 && done < total;
    }).toList();
    final completed = available.where((s) {
      final num = s['number'] as int;
      final total = s['totalVerses'] as int;
      final done = provider.progress.surahProgress[num]?.completedLessons.length ?? 0;
      return done >= total;
    }).toList();

    final totalAvailableVerses = available.fold<int>(
        0, (sum, s) => sum + (s['totalVerses'] as int));
    final totalDoneVerses = available.fold<int>(0, (sum, s) {
      final num = s['number'] as int;
      return sum + (provider.progress.surahProgress[num]?.completedLessons.length ?? 0);
    });
    final overallProgress =
        totalAvailableVerses == 0 ? 0.0 : totalDoneVerses / totalAvailableVerses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Surahs',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            const Tab(text: 'All'),
            Tab(text: 'Progress (${inProgress.length})'),
            Tab(text: 'Done (${completed.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ProgressHeader(
            availableCount: available.length,
            completedCount: completed.length,
            doneVerses: totalDoneVerses,
            totalVerses: totalAvailableVerses,
            progress: overallProgress,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _SurahListView(surahs: allSurahs),
                inProgress.isEmpty
                    ? _EmptyState(
                        icon: Icons.trending_up,
                        message: 'Complete a verse to start tracking progress')
                    : _SurahListView(surahs: inProgress),
                completed.isEmpty
                    ? _EmptyState(
                        icon: Icons.emoji_events,
                        message: 'Complete an entire surah to see it here')
                    : _SurahListView(surahs: completed, showBadge: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int availableCount;
  final int completedCount;
  final int doneVerses;
  final int totalVerses;
  final double progress;

  const _ProgressHeader({
    required this.availableCount,
    required this.completedCount,
    required this.doneVerses,
    required this.totalVerses,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Quran Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$doneVerses of $totalVerses verses learned',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$availableCount surahs',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).round()}% of available content complete',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahListView extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;
  final bool showBadge;

  const _SurahListView({required this.surahs, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final info = surahs[i];
        final surahNum = info['number'] as int;
        final totalVerses = info['totalVerses'] as int;
        final hasData = QuranRepository.instance.hasSurahData(surahNum);
        final sp = provider.progress.surahProgress[surahNum];
        final completed = sp?.completedLessons.length ?? 0;
        final isSurahDone = completed >= totalVerses && hasData;

        return _SurahCard(
          info: info,
          completed: completed,
          totalVerses: totalVerses,
          hasData: hasData,
          showDoneBadge: showBadge || isSurahDone,
          onTap: hasData
              ? () {
                  final nextVerse = completed >= totalVerses
                      ? 1
                      : (completed + 1).clamp(1, totalVerses);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        lessonRef: LessonRef(
                          surahNumber: surahNum,
                          verseNumber: nextVerse,
                        ),
                      ),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Map<String, dynamic> info;
  final int completed;
  final int totalVerses;
  final bool hasData;
  final bool showDoneBadge;
  final VoidCallback? onTap;

  const _SurahCard({
    required this.info,
    required this.completed,
    required this.totalVerses,
    required this.hasData,
    required this.showDoneBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalVerses == 0 ? 0.0 : completed / totalVerses;
    final isSurahDone = showDoneBadge && completed >= totalVerses && hasData;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSurahDone
                ? AppColors.primary
                : AppColors.cardBorder,
            width: isSurahDone ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasData
                        ? (isSurahDone
                            ? AppColors.primary
                            : AppColors.primaryLight)
                        : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isSurahDone ? '✓' : '${info['number']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isSurahDone ? 18 : 14,
                        color: isSurahDone
                            ? Colors.white
                            : (hasData
                                ? AppColors.primaryDark
                                : AppColors.textLight),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          info['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: hasData
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        info['arabicName'] as String,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: hasData
                              ? AppColors.arabicGreen
                              : AppColors.textLight,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${info['meaning']} · $totalVerses verses',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isSurahDone ? AppColors.primary : AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSurahDone
                          ? 'Complete!'
                          : '$completed / $totalVerses verses',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSurahDone
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                        fontWeight: isSurahDone
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Text(
                        'Coming soon',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasData)
              Icon(
                Icons.chevron_right,
                color: isSurahDone ? AppColors.primary : AppColors.textLight,
              ),
          ],
        ),
      ),
    );
  }
}

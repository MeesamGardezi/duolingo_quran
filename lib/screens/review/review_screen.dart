import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/vocabulary_item.dart';
import '../lesson/lesson_screen.dart';
import '../../data/quran_repository.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final due = provider.dueForReview;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Practice'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Review due card
          _ReviewDueCard(dueCount: due.length, onStart: () {
            if (due.isEmpty) return;
            final allVerses = QuranRepository.instance.loadedSurahs
                .expand((s) => s.verses)
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonScreen(
                  lessonRef: LessonRef(surahNumber: 0, verseNumber: 0),
                  isReview: true,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Practice by surah header
          const Text(
            'Practice a specific surah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Only show surahs where user has completed at least 1 lesson
          ...provider.surahsSortedByLength
              .where((info) {
                final sp = provider.progress
                    .surahProgress[info['number'] as int];
                return sp != null && sp.completedLessons.isNotEmpty;
              })
              .map((info) => _SurahPracticeCard(
                    info: info,
                    provider: provider,
                  )),

          if (provider.surahsSortedByLength
              .every((info) {
                final sp = provider.progress
                    .surahProgress[info['number'] as int];
                return sp == null || sp.completedLessons.isEmpty;
              }))
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: _EmptyState(),
            ),
        ],
      ),
    );
  }
}

class _ReviewDueCard extends StatelessWidget {
  final int dueCount;
  final VoidCallback onStart;

  const _ReviewDueCard({required this.dueCount, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dueCount > 0
              ? [AppColors.primary, AppColors.primaryDark]
              : [AppColors.cardBorder, AppColors.cardBorder],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🔄', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueCount > 0
                      ? '$dueCount words due for review'
                      : 'No words due right now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: dueCount > 0 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                Text(
                  dueCount > 0
                      ? 'Strengthen your memory'
                      : 'Check back later',
                  style: TextStyle(
                    fontSize: 13,
                    color: dueCount > 0
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (dueCount > 0)
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('START',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}

class _SurahPracticeCard extends StatelessWidget {
  final Map<String, dynamic> info;
  final AppProvider provider;

  const _SurahPracticeCard(
      {required this.info, required this.provider});

  @override
  Widget build(BuildContext context) {
    final surahNum = info['number'] as int;
    final sp = provider.progress.surahProgress[surahNum];
    if (sp == null || sp.completedLessons.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedVerse = sp.completedLessons.first + 1;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonScreen(
            lessonRef: LessonRef(
                surahNumber: surahNum, verseNumber: completedVerse),
            isReview: true,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
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
              child: Center(
                child: Text(
                  '${info['number']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.blueDark,
                      fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  Text(
                      '${sp.completedLessons.length} verse(s) learned',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(
              info['arabicName'] as String,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: AppColors.arabicGreen,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('📚', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text(
          'Complete your first lesson to unlock review mode!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

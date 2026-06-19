import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/quran_repository.dart';
import '../../theme/app_theme.dart';
import '../lesson/lesson_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final surahs = provider.surahsSortedByLength;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Surahs'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: surahs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final info = surahs[i];
          final surahNum = info['number'] as int;
          final totalVerses = info['totalVerses'] as int;
          final hasData = QuranRepository.instance.hasSurahData(surahNum);

          // Count completed verses for this surah
          final sp = provider.progress.surahProgress[surahNum];
          final completed = sp?.completedLessons.length ?? 0;

          return _SurahCard(
            info: info,
            completed: completed,
            totalVerses: totalVerses,
            hasData: hasData,
            onTap: hasData
                ? () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lessonRef: LessonRef(
                            surahNumber: surahNum,
                            verseNumber: (sp?.completedLessons.isEmpty ?? true)
                                ? 1
                                : (completed + 1).clamp(1, totalVerses),
                          ),
                        ),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Map<String, dynamic> info;
  final int completed;
  final int totalVerses;
  final bool hasData;
  final VoidCallback? onTap;

  const _SurahCard({
    required this.info,
    required this.completed,
    required this.totalVerses,
    required this.hasData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalVerses == 0 ? 0.0 : completed / totalVerses;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasData ? AppColors.cardBorder : AppColors.cardBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasData ? AppColors.primaryLight : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${info['number']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: hasData ? AppColors.primaryDark : AppColors.textLight,
                  ),
                ),
              ),
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
                  const SizedBox(height: 4),
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
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completed / $totalVerses verses',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.cardBorder),
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
              const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

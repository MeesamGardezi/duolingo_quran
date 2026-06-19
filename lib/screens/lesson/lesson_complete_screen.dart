import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../models/achievement.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class LessonCompleteScreen extends StatefulWidget {
  final LessonSession session;
  final bool isReview;
  final bool isDailyChallenge;
  final String? completedSurahName;
  final String? completedSurahMeaning;

  const LessonCompleteScreen({
    super.key,
    required this.session,
    this.isReview = false,
    this.isDailyChallenge = false,
    this.completedSurahName,
    this.completedSurahMeaning,
  });

  @override
  State<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;
  List<Achievement> _newAchievements = [];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
        duration: widget.completedSurahName != null
            ? const Duration(seconds: 6)
            : const Duration(seconds: 3));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
        parent: _scaleController, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _confetti.play();
        _scaleController.forward();
        final provider = context.read<AppProvider>();
        setState(() {
          _newAchievements = List.from(provider.pendingAchievements);
        });
        provider.clearPendingAchievements();
        provider.clearNewlyCompletedSurah();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final total = session.exercises.isEmpty ? 1 : session.exercises.length;
    final accuracy = (session.correctCount / total * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            colors: const [
              AppColors.primary,
              AppColors.gold,
              AppColors.blue,
              AppColors.heartRed,
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      children: [
                        Text(
                          widget.completedSurahName != null
                              ? '📖'
                              : session.isPerfect
                                  ? '🌟'
                                  : '✅',
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.completedSurahName != null
                              ? 'Surah Complete!'
                              : session.isPerfect
                                  ? 'Perfect!'
                                  : widget.isDailyChallenge
                                      ? 'Challenge Complete!'
                                      : widget.isReview
                                          ? 'Review Complete!'
                                          : 'Lesson Complete!',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.completedSurahName != null
                              ? 'You completed Surah ${widget.completedSurahName}!'
                              : session.isPerfect
                                  ? 'Flawless — no mistakes!'
                                  : 'Keep it up, you\'re building mastery.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.completedSurahName != null) ...[
                    const SizedBox(height: 20),
                    _SurahCompleteBanner(
                      surahName: widget.completedSurahName!,
                      surahMeaning: widget.completedSurahMeaning,
                    ),
                  ],
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      _StatCard(
                          icon: '⚡',
                          label: 'XP Earned',
                          value: '+${session.xpReward}',
                          color: AppColors.gold),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: '🎯',
                          label: 'Accuracy',
                          value: '$accuracy%',
                          color: AppColors.blue),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: '✔️',
                          label: 'Correct',
                          value:
                              '${session.correctCount}/${session.exercises.length}',
                          color: AppColors.primary),
                    ],
                  ),
                  if (_newAchievements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _AchievementUnlocked(
                        achievement: _newAchievements.first),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text('CONTINUE'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SurahCompleteBanner extends StatelessWidget {
  final String surahName;
  final String? surahMeaning;

  const _SurahCompleteBanner(
      {required this.surahName, this.surahMeaning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SURAH COMPLETE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF90CAF9),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  surahName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (surahMeaning != null)
                  Text(
                    '"$surahMeaning"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                      fontStyle: FontStyle.italic,
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

class _AchievementUnlocked extends StatelessWidget {
  final Achievement achievement;
  const _AchievementUnlocked({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5D6), Color(0xFFFFF0B3)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Row(
        children: [
          Text(achievement.emoji,
              style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Achievement Unlocked!',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldDark,
                        letterSpacing: 0.8)),
                Text(achievement.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text(achievement.description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

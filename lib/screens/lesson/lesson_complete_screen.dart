import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';

class LessonCompleteScreen extends StatefulWidget {
  final LessonSession session;

  const LessonCompleteScreen({super.key, required this.session});

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 100), () {
      _confetti.play();
      _scaleController.forward();
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
    final accuracy = session.exercises.isEmpty
        ? 0
        : (session.correctCount / session.exercises.length * 100).round();

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
              AppColors.red,
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
                        const Text('🌟', style: TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        Text(
                          session.isPerfect ? 'Perfect!' : 'Lesson Complete!',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.isPerfect
                              ? 'You nailed every question!'
                              : 'Keep practicing to improve!',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _StatCard(
                        icon: '⚡',
                        label: 'XP Earned',
                        value: '+${session.xpReward}',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: '🎯',
                        label: 'Accuracy',
                        value: '$accuracy%',
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: '❤️',
                        label: 'Hearts Left',
                        value: '${session.hearts}/3',
                        color: AppColors.heartRed,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    ),
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

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

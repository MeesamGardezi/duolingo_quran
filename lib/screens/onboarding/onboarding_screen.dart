import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';
import '../main_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  String _name = '';
  int _dailyGoal = 20;

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final provider = context.read<AppProvider>();
    if (_name.isNotEmpty) await provider.setUserName(_name);
    await provider.setDailyGoal(_dailyGoal);
    await ProgressService.instance.setOnboardingComplete();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _WelcomePage(onNext: _next),
                  _NamePage(
                    onNext: _next,
                    onChanged: (v) => _name = v,
                  ),
                  _GoalPage(
                    selectedGoal: _dailyGoal,
                    onSelect: (g) => setState(() => _dailyGoal = g),
                    onNext: _next,
                  ),
                  _ReadyPage(
                    name: _name,
                    goal: _dailyGoal,
                    onStart: _finish,
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

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Spacer(),
          const Text('🕌', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text(
            'Quran Journey',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Learn the meaning and beauty of the Quran — one verse a day, Duolingo style.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('GET STARTED'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onChanged;
  const _NamePage({required this.onNext, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text(
            "What's your name?",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is optional — we\'ll use it to personalise your experience.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Your name',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.cardBorder, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.cardBorder, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2.5),
              ),
            ),
            onChanged: onChanged,
          ),
          const Spacer(),
          ElevatedButton(onPressed: onNext, child: const Text('CONTINUE')),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onNext,
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final int selectedGoal;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  static const goals = [
    (xp: 10, label: 'Casual', desc: 'A few minutes a day', emoji: '🌱'),
    (xp: 20, label: 'Regular', desc: '~10 minutes a day', emoji: '🌿'),
    (xp: 30, label: 'Serious', desc: '~15 minutes a day', emoji: '🌳'),
    (xp: 50, label: 'Intense', desc: '~25 minutes a day', emoji: '⚡'),
  ];

  const _GoalPage(
      {required this.selectedGoal,
      required this.onSelect,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text(
            'Set your daily goal',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'How much do you want to learn each day?',
            style:
                TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ...goals.map((g) {
            final selected = selectedGoal == g.xp;
            return GestureDetector(
              onTap: () => onSelect(g.xp),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryLight
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: 2.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(g.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.label,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: selected
                                      ? AppColors.primaryDark
                                      : AppColors.textPrimary)),
                          Text(g.desc,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text('${g.xp} XP',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textSecondary)),
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check_circle,
                            color: AppColors.primary),
                      ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          ElevatedButton(
              onPressed: onNext, child: const Text('CONTINUE')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  final String name;
  final int goal;
  final VoidCallback onStart;

  const _ReadyPage(
      {required this.name, required this.goal, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text('🚀', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            name.isEmpty ? "You're ready!" : "You're ready, $name!",
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Column(
              children: [
                _SummaryRow(
                    icon: '⚡',
                    label: 'Daily goal',
                    value: '$goal XP per day'),
                const Divider(height: 20),
                const _SummaryRow(
                    icon: '📖',
                    label: 'Starting with',
                    value: 'Al-Asr (shortest surah)'),
                const Divider(height: 20),
                const _SummaryRow(
                    icon: '🌙',
                    label: 'Goal',
                    value: 'Complete the full Quran'),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: onStart,
              child: const Text('BEGIN MY JOURNEY')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SummaryRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

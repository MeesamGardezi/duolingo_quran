import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final p = provider.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          const _SectionLabel('Profile'),
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Display Name',
            value: p.userName.isEmpty ? 'Not set' : p.userName,
            onTap: () => _editName(context, provider, p.userName),
          ),
          const SizedBox(height: 20),

          // Daily goal
          const _SectionLabel('Learning'),
          _GoalSelector(
            currentGoal: p.dailyXPGoal,
            onSelect: (xp) => provider.setDailyGoal(xp),
          ),
          const SizedBox(height: 20),

          // Stats
          const _SectionLabel('Your Stats'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Column(
              children: [
                _StatRow(label: 'Total XP', value: '${p.totalXP}'),
                const Divider(height: 20),
                _StatRow(label: 'Streak', value: '${p.streak} days'),
                const Divider(height: 20),
                _StatRow(label: 'Lessons Completed',
                    value: '${p.totalLessonsCompleted}'),
                const Divider(height: 20),
                _StatRow(label: 'Words Learned',
                    value: '${p.vocabularyCount}'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About
          const _SectionLabel('About'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Column(
              children: const [
                _InfoRow(label: 'Translation', value: 'Sahih International'),
                Divider(height: 20),
                _InfoRow(label: 'Version', value: '1.0.0'),
                Divider(height: 20),
                _InfoRow(
                  label: 'Data',
                  value: 'Quran data used for educational purposes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Reset progress (dangerous)
          OutlinedButton(
            onPressed: () => _confirmReset(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Reset All Progress',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _editName(
      BuildContext context, AppProvider provider, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Display Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.setUserName(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final provider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?'),
        content: const Text(
            'This will erase all your XP, streaks, and lesson progress. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.resetProgress();
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final int currentGoal;
  final ValueChanged<int> onSelect;

  static const goals = [
    (xp: 10, label: 'Casual 🌱'),
    (xp: 20, label: 'Regular 🌿'),
    (xp: 30, label: 'Serious 🌳'),
    (xp: 50, label: 'Intense ⚡'),
  ];

  const _GoalSelector({required this.currentGoal, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily XP Goal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 14),
          Row(
            children: goals
                .map((g) => Expanded(
                      child: GestureDetector(
                        onTap: () => onSelect(g.xp),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          decoration: BoxDecoration(
                            color: currentGoal == g.xp
                                ? AppColors.primaryLight
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: currentGoal == g.xp
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text('${g.xp}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: currentGoal == g.xp
                                          ? AppColors.primaryDark
                                          : AppColors.textPrimary)),
                              Text('XP',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: currentGoal == g.xp
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

const _kLeagueTiers = [
  ('Bronze', Color(0xFFCD7F32), Color(0xFFF5E6D3)),
  ('Silver', Color(0xFF9E9E9E), Color(0xFFF5F5F5)),
  ('Gold', Color(0xFFFFD700), Color(0xFFFFF9E6)),
  ('Sapphire', Color(0xFF1E88E5), Color(0xFFE3F2FD)),
  ('Ruby', Color(0xFFE53935), Color(0xFFFFEBEE)),
  ('Emerald', Color(0xFF43A047), Color(0xFFE8F5E9)),
  ('Amethyst', Color(0xFF8E24AA), Color(0xFFF3E5F5)),
  ('Pearl', Color(0xFF26C6DA), Color(0xFFE0F7FA)),
  ('Obsidian', Color(0xFF37474F), Color(0xFFECEFF1)),
  ('Diamond', Color(0xFF29B6F6), Color(0xFFE1F5FE)),
];

String _leagueName(int level) {
  final idx = ((level - 1) ~/ 2).clamp(0, _kLeagueTiers.length - 1);
  return _kLeagueTiers[idx].$1;
}

Color _leagueColor(int level) {
  final idx = ((level - 1) ~/ 2).clamp(0, _kLeagueTiers.length - 1);
  return _kLeagueTiers[idx].$2;
}

Color _leagueBg(int level) {
  final idx = ((level - 1) ~/ 2).clamp(0, _kLeagueTiers.length - 1);
  return _kLeagueTiers[idx].$3;
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  List<_LeaderEntry> _buildLeaderboard(String userName, int userXP, int level) {
    final rand = Random(userXP + level * 100);
    final names = [
      'Ahmad', 'Fatima', 'Omar', 'Aisha', 'Yusuf', 'Zainab',
      'Hassan', 'Maryam', 'Ibrahim', 'Khadijah', 'Ali', 'Safiya',
      'Bilal', 'Hana', 'Tariq', 'Nour', 'Khalid', 'Layla',
      'Hamza', 'Sara', 'Anas', 'Amina',
    ];

    final entries = <_LeaderEntry>[];
    final userEntry = _LeaderEntry(
      name: userName.isEmpty ? 'You' : userName,
      xp: userXP,
      isUser: true,
    );

    // Generate 19 fictional competitors around user's XP
    for (var i = 0; i < 19; i++) {
      final variation = rand.nextInt(200) - 50; // ±100 XP variation
      final competitorXP = (userXP + variation).clamp(0, userXP + 300);
      entries.add(_LeaderEntry(
        name: names[i % names.length],
        xp: competitorXP,
        isUser: false,
      ));
    }
    entries.add(userEntry);

    entries.sort((a, b) => b.xp.compareTo(a.xp));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final p = provider.progress;
    final userName = p.userName.isEmpty ? 'You' : p.userName;
    final entries = _buildLeaderboard(userName, p.totalXP, p.level);
    final userRank = entries.indexWhere((e) => e.isUser) + 1;
    final leagueName = _leagueName(p.level);
    final leagueColor = _leagueColor(p.level);
    final leagueBg = _leagueBg(p.level);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('League', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _LeagueHeader(
            leagueName: leagueName,
            leagueColor: leagueColor,
            leagueBg: leagueBg,
            userRank: userRank,
            totalPlayers: entries.length,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: entries.length,
              itemBuilder: (ctx, i) {
                final entry = entries[i];
                final rank = i + 1;
                return _LeaderRow(
                  rank: rank,
                  entry: entry,
                  leagueColor: leagueColor,
                );
              },
            ),
          ),
          _PromotionBanner(
            userRank: userRank,
            leagueColor: leagueColor,
            leagueName: leagueName,
            nextLeague: p.level < 20 ? _leagueName(p.level + 2) : null,
          ),
        ],
      ),
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final String leagueName;
  final Color leagueColor;
  final Color leagueBg;
  final int userRank;
  final int totalPlayers;

  const _LeagueHeader({
    required this.leagueName,
    required this.leagueColor,
    required this.leagueBg,
    required this.userRank,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: leagueBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: leagueColor.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: leagueColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: leagueColor, width: 2),
            ),
            child: Center(
              child: Text(
                '🏆',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$leagueName League',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: leagueColor,
                  ),
                ),
                Text(
                  'Your rank: #$userRank of $totalPlayers',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#$userRank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: leagueColor,
                ),
              ),
              const Text(
                'This week',
                style: TextStyle(fontSize: 10, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final _LeaderEntry entry;
  final Color leagueColor;

  const _LeaderRow({
    required this.rank,
    required this.entry,
    required this.leagueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankEmojis = ['🥇', '🥈', '🥉'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isUser
            ? leagueColor.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isUser ? leagueColor : AppColors.cardBorder,
          width: entry.isUser ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3
                ? Text(
                    rankEmojis[rank - 1],
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: entry.isUser
                          ? leagueColor
                          : AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: entry.isUser
                  ? leagueColor.withOpacity(0.15)
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: entry.isUser ? leagueColor : AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: entry.isUser
                    ? leagueColor
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (entry.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: leagueColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'YOU',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.gold, size: 16),
              Text(
                '${entry.xp}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  final int userRank;
  final Color leagueColor;
  final String leagueName;
  final String? nextLeague;

  const _PromotionBanner({
    required this.userRank,
    required this.leagueColor,
    required this.leagueName,
    this.nextLeague,
  });

  @override
  Widget build(BuildContext context) {
    if (nextLeague == null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏆', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'You\'ve reached the highest league!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      );
    }

    String message;
    if (userRank <= 5) {
      message = 'Top 5! You\'ll promote to $nextLeague League!';
    } else if (userRank <= 10) {
      message = 'Top 10 — keep going to reach $nextLeague League!';
    } else {
      message = 'Study more to climb up to $nextLeague League!';
    }

    final isPromoting = userRank <= 5;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPromoting ? AppColors.primaryLight : AppColors.redLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPromoting ? AppColors.primary : AppColors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            isPromoting ? '⬆️' : '📚',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isPromoting ? AppColors.primaryDark : AppColors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final int xp;
  final bool isUser;

  const _LeaderEntry({
    required this.name,
    required this.xp,
    required this.isUser,
  });
}

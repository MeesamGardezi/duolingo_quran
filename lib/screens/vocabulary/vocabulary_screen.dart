import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/vocabulary_item.dart';
import '../../theme/app_theme.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _query = '';
  String _filter = 'all'; // all | due | mastered

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    var words = provider.allVocabulary;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      words = words
          .where((w) =>
              w.arabic.contains(q) ||
              w.meaning.toLowerCase().contains(q) ||
              w.transliteration.toLowerCase().contains(q))
          .toList();
    }

    if (_filter == 'due') {
      words = words.where((w) => w.isDueForReview).toList();
    } else if (_filter == 'mastered') {
      words = words.where((w) => w.masteryLevel >= 0.8).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Vocabulary'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _SearchBar(
            onChanged: (v) => setState(() => _query = v),
          ),
          _FilterChips(
            selected: _filter,
            onSelect: (f) => setState(() => _filter = f),
            totalCount: provider.allVocabulary.length,
            dueCount: provider.dueCount,
            masteredCount: provider.allVocabulary
                .where((w) => w.masteryLevel >= 0.8)
                .length,
          ),
          Expanded(
            child: words.isEmpty
                ? _EmptyState(query: _query)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: words.length,
                    itemBuilder: (ctx, i) =>
                        _WordCard(word: words[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search words...',
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.cardBorder, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.cardBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final int totalCount;
  final int dueCount;
  final int masteredCount;

  const _FilterChips({
    required this.selected,
    required this.onSelect,
    required this.totalCount,
    required this.dueCount,
    required this.masteredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _Chip(
              label: 'All ($totalCount)',
              active: selected == 'all',
              onTap: () => onSelect('all')),
          const SizedBox(width: 8),
          _Chip(
              label: 'Due ($dueCount)',
              active: selected == 'due',
              onTap: () => onSelect('due'),
              color: AppColors.gold),
          const SizedBox(width: 8),
          _Chip(
              label: 'Mastered ($masteredCount)',
              active: selected == 'mastered',
              onTap: () => onSelect('mastered'),
              color: AppColors.primary),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? color : AppColors.cardBorder, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final VocabularyItem word;
  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final mastery = word.masteryLevel;
    Color masteryColor;
    if (mastery >= 0.8) {
      masteryColor = AppColors.primary;
    } else if (mastery >= 0.5) {
      masteryColor = AppColors.gold;
    } else {
      masteryColor = AppColors.textLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: AppColors.arabicGreen,
                    height: 1.5,
                  ),
                ),
                Text(
                  word.transliteration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.meaning,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: masteryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mastery >= 0.8
                      ? 'Mastered'
                      : mastery >= 0.5
                          ? 'Learning'
                          : 'New',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: masteryColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'S${word.surahNumber}:${word.verseNumber}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              if (word.isDueForReview)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Due',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            query.isEmpty ? '📖' : '🔍',
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Complete lessons to build your vocabulary!'
                : 'No words match "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';
import 'exercise_base.dart';

class MatchingPairsExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onAnswer;

  const MatchingPairsExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<MatchingPairsExercise> createState() =>
      _MatchingPairsExerciseState();
}

class _MatchingPairsExerciseState
    extends State<MatchingPairsExercise> {
  late List<_Card> _arabicCards;
  late List<_Card> _meaningCards;
  String? _selectedArabic;
  String? _selectedMeaning;
  Set<String> _matchedArabic = {};
  Set<String> _wrongFlash = {};
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    final pairs = widget.exercise.pairs ?? [];
    _arabicCards = pairs
        .map((p) => _Card(text: p.arabic, key: p.arabic))
        .toList()
      ..shuffle();
    _meaningCards = pairs
        .map((p) => _Card(text: p.meaning, key: p.arabic))
        .toList()
      ..shuffle();
  }

  void _tapArabic(String key) {
    if (_matchedArabic.contains(key) || _complete) return;
    setState(() => _selectedArabic = key);
    _tryMatch();
  }

  void _tapMeaning(String key) {
    if (_matchedArabic.contains(key) || _complete) return;
    setState(() => _selectedMeaning = key);
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedArabic == null || _selectedMeaning == null) return;
    if (_selectedArabic == _selectedMeaning) {
      // Correct match
      _matchedArabic.add(_selectedArabic!);
      _selectedArabic = null;
      _selectedMeaning = null;
      if (_matchedArabic.length == (widget.exercise.pairs?.length ?? 0)) {
        _complete = true;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) widget.onAnswer(true);
        });
      }
    } else {
      // Wrong match — flash red briefly
      final wrongA = _selectedArabic!;
      final wrongM = _selectedMeaning!;
      setState(() {
        _wrongFlash = {wrongA, wrongM};
        _selectedArabic = null;
        _selectedMeaning = null;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongFlash = {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(widget.exercise.question),
        const SizedBox(height: 8),
        const Text(
          'Tap a word, then tap its meaning',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: _arabicCards
                    .map((c) => _PairChip(
                          text: c.text,
                          isArabic: true,
                          state: _matchedArabic.contains(c.key)
                              ? _ChipState.matched
                              : _wrongFlash.contains(c.key)
                                  ? _ChipState.wrong
                                  : _selectedArabic == c.key
                                      ? _ChipState.selected
                                      : _ChipState.idle,
                          onTap: () => _tapArabic(c.key),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: _meaningCards
                    .map((c) => _PairChip(
                          text: c.text,
                          isArabic: false,
                          state: _matchedArabic.contains(c.key)
                              ? _ChipState.matched
                              : _wrongFlash.contains(c.key)
                                  ? _ChipState.wrong
                                  : _selectedMeaning == c.key
                                      ? _ChipState.selected
                                      : _ChipState.idle,
                          onTap: () => _tapMeaning(c.key),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        if (_complete) ...[
          const SizedBox(height: 24),
          AnswerFeedbackBar(
            isCorrect: true,
            correctAnswer: '',
            onContinue: () => widget.onAnswer(true),
          ),
        ],
      ],
    );
  }
}

class _Card {
  final String text;
  final String key; // arabic is the shared key
  _Card({required this.text, required this.key});
}

enum _ChipState { idle, selected, matched, wrong }

class _PairChip extends StatelessWidget {
  final String text;
  final bool isArabic;
  final _ChipState state;
  final VoidCallback onTap;

  const _PairChip({
    required this.text,
    required this.isArabic,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border, textColor;
    switch (state) {
      case _ChipState.matched:
        bg = AppColors.primaryLight;
        border = AppColors.primary;
        textColor = AppColors.primaryDark;
        break;
      case _ChipState.selected:
        bg = const Color(0xFFE8F7FF);
        border = AppColors.blue;
        textColor = AppColors.blueDark;
        break;
      case _ChipState.wrong:
        bg = AppColors.redLight;
        border = AppColors.red;
        textColor = AppColors.red;
        break;
      case _ChipState.idle:
      default:
        bg = AppColors.surface;
        border = AppColors.cardBorder;
        textColor = AppColors.textPrimary;
    }

    return GestureDetector(
      onTap: state == _ChipState.matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2.5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontFamily: isArabic ? 'Amiri' : null,
            fontSize: isArabic ? 20 : 13,
            color: textColor,
            fontWeight: FontWeight.w700,
            height: isArabic ? 1.8 : 1.3,
          ),
        ),
      ),
    );
  }
}

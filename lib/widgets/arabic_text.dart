import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ArabicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;
  final FontWeight fontWeight;

  const ArabicText(
    this.text, {
    super.key,
    this.fontSize = 28,
    this.color,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        color: color ?? AppColors.arabicGreen,
        fontWeight: fontWeight,
        height: 2.0,
        letterSpacing: 0,
      ),
    );
  }
}

class ArabicVerseCard extends StatelessWidget {
  final String arabic;
  final String? transliteration;
  final String? translation;

  const ArabicVerseCard({
    super.key,
    required this.arabic,
    this.transliteration,
    this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight, width: 2),
      ),
      child: Column(
        children: [
          ArabicText(arabic, fontSize: 26),
          if (transliteration != null) ...[
            const SizedBox(height: 8),
            Text(
              transliteration!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (translation != null) ...[
            const Divider(height: 24, color: AppColors.cardBorder),
            Text(
              translation!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

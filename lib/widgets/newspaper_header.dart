import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/editorial_theme.dart';

class NewspaperHeader extends StatelessWidget {
  final String editionTitle;
  final String subtitle;
  final bool showLogo;

  const NewspaperHeader({
    super.key,
    this.editionTitle = "EDICIÓN DIARIA",
    this.subtitle = "Crucigramas Editoriales",
    this.showLogo = false,
  });

  static const List<String> _months = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')} ${_months[now.month - 1]} ${now.year}";
    final issueNum = now.month * 30 + now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Whisper dateline flanked by calm hairline
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ED. Nº $issueNum  ·  $dateStr",
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.3,
                color: EditorialTheme.textSecondary,
              ),
            ),
            Text(
              editionTitle.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
                color: EditorialTheme.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(height: 0.8, color: EditorialTheme.borderLine),
        const SizedBox(height: 12),

        // Centered, breathable classic broadsheet nameplate
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "EL CRUCIGRAMISTA",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: EditorialTheme.textPrimary,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
            color: EditorialTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Clean single anchor rule
        EditorialTheme.doubleRule(color: EditorialTheme.inkDark),
      ],
    );
  }
}

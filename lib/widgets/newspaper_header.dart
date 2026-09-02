import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/editorial_theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

class NewspaperHeader extends StatelessWidget {
  final String editionTitle;
  final String subtitle;
  final bool showLogo;

  const NewspaperHeader({
    super.key,
    this.editionTitle = "EDICIÓN DE HOY",
    this.subtitle = "Crucigramas de Alta Calidad Editorial",
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";

    return Column(
      children: [
        // Top fine rule
        Container(
          height: 1,
          color: EditorialTheme.textPrimary,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 2),
        Container(
          height: 2.5,
          color: EditorialTheme.textPrimary,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 8),

        // Date & Issue bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nº ${now.year}.${now.month * 30 + now.day}",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              Text(
                "PREMIO EDITORIAL",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: EditorialTheme.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Main Title Banner with optional graphite pencil logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showLogo) ...[
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/images/logo_pencil.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.edit,
                    size: 32,
                    color: EditorialTheme.primary,
                  ),
                ),
              ).animate().rotate(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 12),
            ],
            Column(
              children: [
                Text(
                  "EL CRUCIGRAMISTA",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: EditorialTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),
        // Bottom fine double rule
        Container(
          height: 2.5,
          color: EditorialTheme.textPrimary,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 2),
        Container(
          height: 1,
          color: EditorialTheme.textPrimary,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, curve: Curves.easeOutQuad);
  }
}

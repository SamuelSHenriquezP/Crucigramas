import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditorialTheme {
  // Color Palette - Periódico Premium
  static const Color background = Color(0xFFF7F5EF); // Marfil cálido
  static const Color surface = Color(0xFFFFFDF8);    // Blanco crema
  static const Color textPrimary = Color(0xFF202124); // Negro carbón
  static const Color textSecondary = Color(0xFF5F6368); // Gris medio
  static const Color primary = Color(0xFF174A5B);     // Azul petróleo profundo
  static const Color accent = Color(0xFFD9A63A);      // Mostaza elegante
  static const Color success = Color(0xFF719579);     // Verde salvia
  static const Color error = Color(0xFFC56D5A);       // Terracota
  static const Color borderLine = Color(0xFFD8D3C9);  // Gris cálido
  static const Color cellFocused = Color(0xFFF7E8BA); // Tint Mostaza cálido
  static const Color wordFocused = Color(0xFFE3EDF0); // Tint Petróleo suave
  static const Color inkDark = Color(0xFF2C302E);     // Tinta sepia oscura

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: surface,
        secondary: accent,
        onSecondary: textPrimary,
        error: error,
        onError: surface,
        surface: surface,
        onSurface: textPrimary,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Dynamic Font Resolver based on player equipped font
  static TextStyle getEditorialFont({
    required String fontId,
    required double fontSize,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
    double? letterSpacing,
  }) {
    final textColor = color ?? textPrimary;
    switch (fontId) {
      case 'font_cinzel':
        return GoogleFonts.cinzel(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_lora':
        return GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_merriweather':
        return GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_roboto_slab':
        return GoogleFonts.robotoSlab(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_playfair':
      default:
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
    }
  }

  // Double ruled vintage newspaper border decoration
  static BoxDecoration get newspaperCardDecoration {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(6.0),
      border: Border.all(color: borderLine, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: textPrimary.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration get inkButtonDecoration {
    return BoxDecoration(
      color: primary,
      borderRadius: BorderRadius.circular(6.0),
      border: Border.all(color: inkDark, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.2),
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditorialTheme {
  // Color Palette - Crisp White Editorial Print
  static const Color background = Color(0xFFFFFFFF);    // Blanco limpio editorial
  static const Color surface = Color(0xFFFFFFFF);       // Blanco puro
  static const Color textPrimary = Color(0xFF1A1A1A);   // Tinta carbón editorial
  static const Color textSecondary = Color(0xFF686868); // Gris neutro editorial
  static const Color primary = Color(0xFF1D3B49);       // Azul tinta sobrio
  static const Color secondary = Color(0xFF285943);     // Verde editorial
  static const Color accent = Color(0xFF9C6D24);        // Ocre dorado imprenta
  static const Color success = Color(0xFF2E6B4E);       // Verde verificación
  static const Color error = Color(0xFF9E342A);         // Rojo corrector
  static const Color borderLine = Color(0xFFE0E0E0);    // Filete fino neutro
  static const Color cellFocused = Color(0xFFF3E4B5);   // Celda activa
  static const Color wordFocused = Color(0xFFE6EEF2);   // Palabra activa
  static const Color inkDark = Color(0xFF1A1A1A);       // Tinta sólida

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
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.libreBaskerville(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        displayMedium: GoogleFonts.libreBaskerville(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.libreBaskerville(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: inkDark),
        titleTextStyle: GoogleFonts.libreBaskerville(
          color: inkDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: inkDark,
          foregroundColor: surface,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkDark,
          side: const BorderSide(color: borderLine, width: 1.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: inkDark, width: 1.0),
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
      case 'font_eb_garamond':
        return GoogleFonts.ebGaramond(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_cormorant':
        return GoogleFonts.cormorantGaramond(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_baskerville':
        return GoogleFonts.libreBaskerville(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_bodoni':
        return GoogleFonts.bodoniModa(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_courier':
        return GoogleFonts.courierPrime(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_space_mono':
        return GoogleFonts.spaceMono(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_alegreya':
        return GoogleFonts.alegreya(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_spectral':
        return GoogleFonts.spectral(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
      case 'font_playfair':
      default:
        return GoogleFonts.libreBaskerville(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
        );
    }
  }

  // Fine hairline editorial surface card (light printer rule instead of heavy dark boxes)
  static BoxDecoration get newspaperCardDecoration {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.zero,
      border: Border.all(color: borderLine, width: 0.9),
    );
  }

  static BoxDecoration get subtleRuleBoxDecoration {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.zero,
      border: Border.all(color: borderLine, width: 0.8),
    );
  }

  static BoxDecoration get inkButtonDecoration {
    return BoxDecoration(
      color: inkDark,
      borderRadius: BorderRadius.zero,
      border: Border.all(color: inkDark, width: 1.0),
    );
  }

  /// Whisper-quiet printer's hairline double rule
  static Widget doubleRule({
    Color color = inkDark,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1.2, color: color),
          const SizedBox(height: 2.5),
          Container(height: 0.5, color: color.withValues(alpha: 0.55)),
        ],
      ),
    );
  }
}

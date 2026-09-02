import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';

class AdManager {
  static int _levelsCompletedCount = 0;
  static const int _interstitialInterval = 3;

  /// Call this when a level is completed to check if an interstitial ad should be shown
  static void onLevelCompleted(BuildContext context) {
    _levelsCompletedCount++;
    final gameState = Provider.of<GameStateProvider>(context, listen: false);

    if (gameState.hasNoAds) return; // VIP players skip ads

    if (_levelsCompletedCount % _interstitialInterval == 0) {
      _showInterstitialAdDialog(context);
    }
  }

  /// Show elegant interstitial ad simulation dialog with optional coin bonus
  static void _showInterstitialAdDialog(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final activeFontId = gameState.activeFontId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: EditorialTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: EditorialTheme.borderLine, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.stars, color: EditorialTheme.accent, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "EDICIÓN PATROCINADA",
                  style: EditorialTheme.getEditorialFont(
                    fontId: activeFontId,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EditorialTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EditorialTheme.borderLine),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.newspaper, color: EditorialTheme.primary, size: 48),
                    const SizedBox(height: 10),
                    Text(
                      "Gracias por jugar a Crucigramas Editorial",
                      textAlign: TextAlign.center,
                      style: EditorialTheme.getEditorialFont(
                        fontId: activeFontId,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Este breve patrocinio mantiene los crucigramas 100% gratuitos y de la más alta calidad.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: EditorialTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: EditorialTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle, color: EditorialTheme.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "+15 Monedas de Bonificación",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                gameState.addCoins(15);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                "Continuar Leyendo (+15 🪙)",
                style: GoogleFonts.inter(
                  color: EditorialTheme.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show Rewarded Ad for +50 free coins
  static void showRewardedAdForCoins(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final activeFontId = gameState.activeFontId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: EditorialTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: EditorialTheme.accent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.movie, color: EditorialTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                "ANUNCIO RECOMPENSADO",
                style: EditorialTheme.getEditorialFont(
                  fontId: activeFontId,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_giftcard, color: EditorialTheme.accent, size: 54),
              const SizedBox(height: 12),
              Text(
                "Mira un video corto patrocinado y recibe inmediatamente 50 Monedas de la Imprenta.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: EditorialTheme.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancelar",
                style: GoogleFonts.inter(color: EditorialTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                gameState.addCoins(50);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: EditorialTheme.success,
                    content: Text(
                      "¡Recompensa reclutada! +50 Monedas añadidas a tu saldo.",
                      style: GoogleFonts.inter(color: EditorialTheme.surface),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
              ),
              child: Text(
                "Ver Video (+50 🪙)",
                style: GoogleFonts.inter(
                  color: EditorialTheme.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

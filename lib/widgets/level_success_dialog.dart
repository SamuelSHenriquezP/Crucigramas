import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/word_entry.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import '../views/dictionary/dictionary_screen.dart';

class LevelSuccessDialog extends StatefulWidget {
  final int coinsEarned;
  final List<WordEntry> newlyDiscoveredWords;
  final VoidCallback onNextLevel;

  const LevelSuccessDialog({
    super.key,
    required this.coinsEarned,
    required this.newlyDiscoveredWords,
    required this.onNextLevel,
  });

  @override
  State<LevelSuccessDialog> createState() => _LevelSuccessDialogState();
}

class _LevelSuccessDialogState extends State<LevelSuccessDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFontId = Provider.of<GameStateProvider>(context).activeFontId;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti effect
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            EditorialTheme.primary,
            EditorialTheme.accent,
            EditorialTheme.success,
            EditorialTheme.inkDark,
          ],
        ),

        Dialog(
          backgroundColor: EditorialTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: EditorialTheme.primary, width: 2.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Editorial Seal Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: EditorialTheme.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "¡EDICIÓN COMPLETADA!",
                    style: EditorialTheme.getEditorialFont(
                      fontId: activeFontId,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 16),

                // Main Trophy / Quill Icon
                const Icon(
                  Icons.verified,
                  size: 64,
                  color: EditorialTheme.primary,
                ).animate().scale(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 12),

                Text(
                  "Crucigrama Resuelto",
                  style: EditorialTheme.getEditorialFont(
                    fontId: activeFontId,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Has ejercitado tu intelecto y enriquecido tu léxico con maestría.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: EditorialTheme.textSecondary,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 20),

                // Reward Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: EditorialTheme.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: EditorialTheme.borderLine, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: EditorialTheme.accent, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "+${widget.coinsEarned} Monedas de Oro",
                        style: EditorialTheme.getEditorialFont(
                          fontId: activeFontId,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                // Newly Discovered Words section
                if (widget.newlyDiscoveredWords.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nuevos términos añadidos al diccionario (${widget.newlyDiscoveredWords.length}):",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: EditorialTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 110),
                    decoration: BoxDecoration(
                      color: EditorialTheme.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: EditorialTheme.borderLine),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.newlyDiscoveredWords.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 8),
                      itemBuilder: (ctx, i) {
                        final word = widget.newlyDiscoveredWords[i];
                        return Row(
                          children: [
                            Text(
                              word.word,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: EditorialTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                word.clue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: EditorialTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const DictionaryScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: EditorialTheme.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "Diccionario",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: EditorialTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onNextLevel();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EditorialTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: EditorialTheme.inkDark, width: 1.5),
                          ),
                        ),
                        child: Text(
                          "Siguiente Edición",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: EditorialTheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

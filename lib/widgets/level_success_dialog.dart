import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: EditorialTheme.borderLine, width: 1.0),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: EditorialTheme.inkDark, width: 2.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Masthead strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "GACETA OFICIAL",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: EditorialTheme.textSecondary,
                      ),
                    ),
                    Text(
                      "EDICIÓN COMPLETADA",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: EditorialTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 0.8, color: EditorialTheme.borderLine),
                const SizedBox(height: 18),

                // Quiet editorial seal
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 32,
                  color: EditorialTheme.accent,
                ),

                const SizedBox(height: 10),

                Text(
                  "Crucigrama Resuelto",
                  textAlign: TextAlign.center,
                  style: EditorialTheme.getEditorialFont(
                    fontId: activeFontId,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: EditorialTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Has completado cada cruce y enriquecido el archivo léxico de esta edición.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: EditorialTheme.textSecondary,
                    height: 1.38,
                  ),
                ),

                const SizedBox(height: 18),

                // Hairline reward strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: EditorialTheme.background,
                    border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on_outlined, color: EditorialTheme.accent, size: 22),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.coinsEarned),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return Text(
                            "+$val MONEDAS EDITORIALES",
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: EditorialTheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                if (widget.newlyDiscoveredWords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "NUEVOS TÉRMINOS ARCHIVADOS (${widget.newlyDiscoveredWords.length})",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: EditorialTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 110),
                    decoration: BoxDecoration(
                      color: EditorialTheme.background,
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
                ],

                const SizedBox(height: 18),

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
                          side: const BorderSide(color: EditorialTheme.inkDark, width: 1.2),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          "DICCIONARIO",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: EditorialTheme.inkDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: EditorialTheme.inkDark, width: 1.4),
                          ),
                        ),
                        child: Text(
                          "SIGUIENTE EDICIÓN",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
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

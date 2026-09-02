import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import 'clue_list_modal.dart';

class ClueDockWidget extends StatefulWidget {
  const ClueDockWidget({super.key});

  @override
  State<ClueDockWidget> createState() => _ClueDockWidgetState();
}

class _ClueDockWidgetState extends State<ClueDockWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final focusedWord = gameState.currentFocusedWord;

    final directionText = gameState.isAcrossFocus ? "HORIZONTAL" : "VERTICAL";
    final wordLengthText = focusedWord != null ? "${focusedWord.word.length} LETRAS" : "";
    final clueText = focusedWord != null ? focusedWord.clue : "Selecciona una casilla para ver la pista";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: EditorialTheme.primary, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: EditorialTheme.primary.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Badge, Direction, Word Length, Controls
          Row(
            children: [
              // Direction & Number Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: EditorialTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gameState.isAcrossFocus ? Icons.arrow_forward : Icons.arrow_downward,
                      size: 13,
                      color: EditorialTheme.surface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      focusedWord != null ? "${focusedWord.number}" : "-",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: EditorialTheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Direction & Length Pills
              Expanded(
                child: Row(
                  children: [
                    Text(
                      directionText,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: EditorialTheme.accent,
                      ),
                    ),
                    if (wordLengthText.isNotEmpty) ...[
                      Text(
                        " • ",
                        style: GoogleFonts.inter(fontSize: 10, color: EditorialTheme.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: EditorialTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          wordLengthText,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: EditorialTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Clue Navigation Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => gameState.selectPreviousWord(),
                    icon: const Icon(Icons.chevron_left, color: EditorialTheme.primary, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Pista anterior",
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => gameState.selectNextWord(),
                    icon: const Icon(Icons.chevron_right, color: EditorialTheme.primary, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Siguiente pista",
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      if (gameState.currentBoard != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ClueListModal(board: gameState.currentBoard!),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.format_list_bulleted,
                      color: EditorialTheme.primary,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Ver todas las pistas",
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Complete Clue Definition Text (Wrapped without truncation, expandable for very long texts)
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                clueText,
                key: ValueKey("clue_${focusedWord?.number}_${focusedWord?.isAcross}"),
                maxLines: _isExpanded ? 10 : 4,
                overflow: TextOverflow.visible,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: EditorialTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import 'clue_list_modal.dart';

class ClueDockWidget extends StatelessWidget {
  const ClueDockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final focusedWord = gameState.currentFocusedWord;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: EditorialTheme.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: EditorialTheme.primary.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Direction & Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EditorialTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  gameState.isAcrossFocus ? Icons.arrow_forward : Icons.arrow_downward,
                  size: 14,
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
          const SizedBox(width: 12),

          // Clue text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameState.isAcrossFocus ? "HORIZONTAL" : "VERTICAL",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: EditorialTheme.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  focusedWord != null ? focusedWord.clue : "Selecciona una casilla para ver la pista",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EditorialTheme.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          // Clue navigation arrows & modal launcher
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
              const SizedBox(width: 4),
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
                  Icons.list_alt,
                  color: EditorialTheme.primary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Ver todas las pistas",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

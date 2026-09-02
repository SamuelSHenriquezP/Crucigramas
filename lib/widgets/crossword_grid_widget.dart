import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crossword_board.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

class CrosswordGridWidget extends StatelessWidget {
  final CrosswordBoard board;

  const CrosswordGridWidget({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final focusedWord = gameState.currentFocusedWord;
    final activeFontId = gameState.activeFontId;

    return AspectRatio(
      aspectRatio: board.cols / board.rows,
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: EditorialTheme.surface,
            border: Border.all(color: EditorialTheme.textPrimary, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: EditorialTheme.textPrimary.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.cols,
              childAspectRatio: 1.0,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
            ),
            itemCount: board.rows * board.cols,
            itemBuilder: (context, index) {
              final r = index ~/ board.cols;
              final c = index % board.cols;
              final cell = board.grid[r][c];

              if (cell.isBlack) {
                return Container(
                  decoration: BoxDecoration(
                    color: EditorialTheme.inkDark,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                );
              }

              final isFocused = (gameState.focusedRow == r && gameState.focusedCol == c);
              final isInFocusedWord = focusedWord != null && focusedWord.containsCell(r, c);

              Color bgColor = EditorialTheme.surface;
              if (isFocused) {
                bgColor = EditorialTheme.cellFocused;
              } else if (isInFocusedWord) {
                bgColor = EditorialTheme.wordFocused;
              } else if (cell.isError) {
                bgColor = const Color(0xFFF9E5E2);
              }

              Color textColor = EditorialTheme.textPrimary;
              if (cell.isError) {
                textColor = EditorialTheme.error;
              } else if (cell.isRevealed) {
                textColor = EditorialTheme.primary;
              }

              Widget cellContent = AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(
                    color: isFocused
                        ? EditorialTheme.accent
                        : (isInFocusedWord
                            ? EditorialTheme.primary.withValues(alpha: 0.5)
                            : EditorialTheme.borderLine),
                    width: isFocused ? 2.0 : 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top-left Clue Number
                    if (cell.number != null)
                      Positioned(
                        top: 2,
                        left: 3,
                        child: Text(
                          "${cell.number}",
                          style: EditorialTheme.getEditorialFont(
                            fontId: activeFontId,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isFocused
                                ? EditorialTheme.primary
                                : EditorialTheme.textPrimary.withValues(alpha: 0.75),
                          ),
                        ),
                      ),

                    // Direction Indicator in active cell
                    if (isFocused)
                      Positioned(
                        top: 2,
                        right: 3,
                        child: Icon(
                          gameState.isAcrossFocus ? Icons.arrow_forward : Icons.arrow_downward,
                          size: 9,
                          color: EditorialTheme.primary,
                        ),
                      ),

                    // Center User Letter with Spring Animation
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: cell.number != null ? 6.0 : 0.0, left: 2.0, right: 2.0, bottom: 2.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            cell.userChar,
                            key: ValueKey("cell_${r}_${c}_${cell.userChar}"),
                            style: EditorialTheme.getEditorialFont(
                              fontId: activeFontId,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ).animate(
                            key: ValueKey("anim_${r}_${c}_${cell.userChar}"),
                          ).scale(
                            duration: 180.ms,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // Shimmer flare for revealed letters
              if (cell.isRevealed) {
                cellContent = cellContent.animate().shimmer(
                  duration: 800.ms,
                  color: EditorialTheme.accent.withValues(alpha: 0.6),
                );
              }

              return RepaintBoundary(
                child: GestureDetector(
                  onTap: () => gameState.selectCell(r, c),
                  child: cellContent,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

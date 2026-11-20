import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/crossword_board.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CrosswordGridWidget extends StatefulWidget {
  final CrosswordBoard board;

  const CrosswordGridWidget({
    super.key,
    required this.board,
  });

  @override
  State<CrosswordGridWidget> createState() => _CrosswordGridWidgetState();
}

class _CrosswordGridWidgetState extends State<CrosswordGridWidget> {
  final TransformationController _transformationController = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_handleZoomChange);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleZoomChange);
    _transformationController.dispose();
    super.dispose();
  }

  void _handleZoomChange() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final translation = _transformationController.value.getTranslation();
    final isMoved = (scale - 1.0).abs() > 0.08 || translation.x.abs() > 15 || translation.y.abs() > 15;
    if (isMoved != _isZoomed) {
      setState(() {
        _isZoomed = isMoved;
      });
    }
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final focusedWord = gameState.currentFocusedWord;
    final activeFontId = gameState.activeFontId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;

        const double outerFrame = 4.0;
        const double cellSpacing = 1.5;

        final double usableW = math.max(0.0, maxW - outerFrame - 4.0);
        final double usableH = math.max(0.0, maxH - outerFrame - 4.0);

        final double cellByW = (usableW - (widget.board.cols - 1) * cellSpacing) / widget.board.cols;
        final double cellByH = (usableH - (widget.board.rows - 1) * cellSpacing) / widget.board.rows;

        final double cellSize = math.min(cellByW, cellByH).clamp(16.0, 74.0);

        final double targetBoardWidth = cellSize * widget.board.cols + (widget.board.cols - 1) * cellSpacing + outerFrame;
        final double targetBoardHeight = cellSize * widget.board.rows + (widget.board.rows - 1) * cellSpacing + outerFrame;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(32.0),
                minScale: 0.85,
                maxScale: 3.5,
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: targetBoardWidth,
                  height: targetBoardHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.board.cols,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: cellSpacing,
                        mainAxisSpacing: cellSpacing,
                      ),
                      itemCount: widget.board.rows * widget.board.cols,
                      itemBuilder: (context, index) {
                        final r = index ~/ widget.board.cols;
                        final c = index % widget.board.cols;
                        final cell = widget.board.grid[r][c];

                        // Empty grid spaces stay clean white paper (no oppressive black voids)
                        if (cell.isBlack) {
                          return const SizedBox.shrink();
                        }

                        final isFocused = (gameState.focusedRow == r && gameState.focusedCol == c);
                        final isInFocusedWord = focusedWord != null && focusedWord.containsCell(r, c);
                        final isCelebratedCell = gameState.lastCompletedWordCelebration != null &&
                            gameState.lastCompletedWordCelebration!.containsCell(r, c);

                        Color bgColor = EditorialTheme.surface;
                        if (cell.isError) {
                          bgColor = const Color(0xFFF4D5D0);
                        } else if (isFocused) {
                          bgColor = EditorialTheme.cellFocused;
                        } else if (isInFocusedWord) {
                          bgColor = EditorialTheme.wordFocused;
                        } else if (cell.isRevealed) {
                          bgColor = const Color(0xFFF2F2F2);
                        }

                        Color textColor = EditorialTheme.textPrimary;
                        if (cell.isError) {
                          textColor = EditorialTheme.error;
                        } else if (cell.isRevealed) {
                          textColor = EditorialTheme.primary;
                        }

                        Widget cellContent = AnimatedContainer(
                          duration: const Duration(milliseconds: 110),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.zero,
                            border: Border.all(
                              color: isFocused
                                  ? EditorialTheme.primary
                                  : (isInFocusedWord ? EditorialTheme.primary : const Color(0xFF2B2B2B)),
                              width: isFocused ? 2.0 : 1.0,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, cellConstraints) {
                              final h = cellConstraints.maxHeight;
                              final numFontSize = (h * 0.25).clamp(7.0, 11.0);
                              final letterFontSize = (h * 0.58).clamp(13.0, 26.0);

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (cell.number != null)
                                    Positioned(
                                      top: 1.5,
                                      left: 2.5,
                                      child: Text(
                                        "${cell.number}",
                                        style: GoogleFonts.inter(
                                          fontSize: numFontSize,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0,
                                          color: EditorialTheme.textPrimary,
                                        ),
                                      ),
                                    ),

                                  if (isFocused)
                                    Positioned(
                                      top: 2.0,
                                      right: 2.0,
                                      child: Icon(
                                        gameState.isAcrossFocus
                                            ? Icons.arrow_forward_sharp
                                            : Icons.arrow_downward_sharp,
                                        size: numFontSize * 1.05,
                                        color: EditorialTheme.primary,
                                      ),
                                    ),

                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: cell.number != null ? (h * 0.16) : 0.0,
                                        bottom: 1.0,
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            cell.userChar,
                                            key: ValueKey("cell_${r}_${c}_${cell.userChar}"),
                                            style: EditorialTheme.getEditorialFont(
                                              fontId: activeFontId,
                                              fontSize: letterFontSize,
                                              fontWeight: FontWeight.w800,
                                              color: textColor,
                                            ),
                                          ).animate(
                                            key: ValueKey("anim_pop_${r}_${c}_${cell.userChar}"),
                                          ).scale(
                                            begin: const Offset(0.55, 0.55),
                                            end: const Offset(1.0, 1.0),
                                            duration: 140.ms,
                                            curve: Curves.easeOutBack,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );

                        if (isCelebratedCell) {
                          final celebWord = gameState.lastCompletedWordCelebration!;
                          final int waveIdx = celebWord.isAcross
                              ? (c - celebWord.startCol)
                              : (r - celebWord.startRow);
                          cellContent = cellContent.animate(
                            key: ValueKey("celeb_${r}_${c}_${gameState.wordCelebrationTick}"),
                          ).scale(
                            delay: (waveIdx * 45).ms,
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.13, 1.13),
                            duration: 150.ms,
                            curve: Curves.easeOutBack,
                          ).then().scale(
                            begin: const Offset(1.13, 1.13),
                            end: const Offset(1.0, 1.0),
                            duration: 160.ms,
                            curve: Curves.easeOutCubic,
                          );
                        } else if (cell.isError) {
                          cellContent = cellContent.animate(
                            key: ValueKey("err_${r}_${c}_${cell.userChar}"),
                          ).shake(
                            hz: 5,
                            offset: const Offset(3, 0),
                            duration: 260.ms,
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
              ),
            ),

            if (_isZoomed)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Material(
                  color: EditorialTheme.inkDark,
                  borderRadius: BorderRadius.zero,
                  child: InkWell(
                    onTap: _resetZoom,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.center_focus_strong_outlined, size: 13, color: EditorialTheme.surface),
                          const SizedBox(width: 5),
                          Text(
                            "CENTRAR",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: EditorialTheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

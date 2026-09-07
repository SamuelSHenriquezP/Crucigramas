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

    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Interactive Zoomable Container with strict boundary constraints
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(16.0),
          minScale: 0.85,
          maxScale: 3.0,
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: widget.board.cols / widget.board.rows,
            child: Container(
              padding: const EdgeInsets.all(3.0),
              color: Colors.transparent,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.board.cols,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 1.5,
                  mainAxisSpacing: 1.5,
                ),
                itemCount: widget.board.rows * widget.board.cols,
                itemBuilder: (context, index) {
                  final r = index ~/ widget.board.cols;
                  final c = index % widget.board.cols;
                  final cell = widget.board.grid[r][c];

                  // Transparent cell for blocked positions
                  if (cell.isBlack) {
                    return const SizedBox.shrink();
                  }

                  final isFocused = (gameState.focusedRow == r && gameState.focusedCol == c);
                  final isInFocusedWord = focusedWord != null && focusedWord.containsCell(r, c);

                  // Colors palette for cells (Authentic newsprint)
                  Color bgColor = Colors.white;
                  if (isFocused) {
                    bgColor = const Color(0xFFFDE68A); // Warm amber newsprint highlighter
                  } else if (isInFocusedWord) {
                    bgColor = const Color(0xFFE6EEF2); // Soft petroleum ink tint
                  } else if (cell.isError) {
                    bgColor = const Color(0xFFFEE2E2); // Soft terracotta tint
                  }

                  Color textColor = const Color(0xFF1A1D20); // Carbon ink
                  if (cell.isError) {
                    textColor = EditorialTheme.error;
                  } else if (cell.isRevealed) {
                    textColor = EditorialTheme.primary;
                  }

                  Widget cellContent = AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(1.5),
                      border: Border.all(
                        color: isFocused
                            ? const Color(0xFFB45309) // Deep amber border
                            : (isInFocusedWord
                                ? EditorialTheme.primary
                                : const Color(0xFF948F82)), // Fine newsprint rule
                        width: isFocused ? 2.0 : (isInFocusedWord ? 1.2 : 0.8),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;
                        // Proportional font sizing for crisp newspaper legibility
                        final numFontSize = (h * 0.26).clamp(7.0, 11.5);
                        final letterFontSize = (h * 0.60).clamp(13.0, 26.0);

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Clue Number (Crisp, sharp top-left corner)
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
                                    color: const Color(0xFF222629),
                                  ),
                                ),
                              ),

                            // 2. Direction Indicator Arrow (Top-Right of focused cell)
                            if (isFocused)
                              Positioned(
                                top: 2.0,
                                right: 2.5,
                                child: Icon(
                                  gameState.isAcrossFocus ? Icons.arrow_forward : Icons.arrow_downward,
                                  size: numFontSize * 0.95,
                                  color: const Color(0xFF78350F),
                                ),
                              ),

                            // 3. Main Letter Display (Optically centered with slight top offset if number exists)
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: cell.number != null ? (h * 0.18) : 0.0,
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
                                      key: ValueKey("anim_${r}_${c}_${cell.userChar}"),
                                    ).scale(
                                      duration: 120.ms,
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

                  // Shimmer flare for revealed letters
                  if (cell.isRevealed) {
                    cellContent = cellContent.animate().shimmer(
                      duration: 700.ms,
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
        ),

        // Floating Reset Zoom Button (appears when zoomed in)
        if (_isZoomed)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: EditorialTheme.primary,
              borderRadius: BorderRadius.circular(20),
              elevation: 4,
              child: InkWell(
                onTap: _resetZoom,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "Centrar",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }
}

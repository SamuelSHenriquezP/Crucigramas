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
    final isZoomedNow = (scale - 1.0).abs() > 0.08;
    if (isZoomedNow != _isZoomed) {
      setState(() {
        _isZoomed = isZoomedNow;
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
        // Interactive Zoomable Container
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.9,
          maxScale: 3.5,
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: widget.board.cols / widget.board.rows,
            child: Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EA), // Vintage newspaper paper
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: EditorialTheme.inkDark, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: EditorialTheme.inkDark.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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

                  // Black / Blocked Newspaper Cell
                  if (cell.isBlack) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2327), // Deep Sepia Ink
                        borderRadius: BorderRadius.circular(2.0),
                        border: Border.all(color: const Color(0xFF14171A), width: 0.5),
                      ),
                    );
                  }

                  final isFocused = (gameState.focusedRow == r && gameState.focusedCol == c);
                  final isInFocusedWord = focusedWord != null && focusedWord.containsCell(r, c);

                  // Colors palette for cells
                  Color bgColor = Colors.white;
                  if (isFocused) {
                    bgColor = const Color(0xFFFDF3D6); // Amber Warm Tint
                  } else if (isInFocusedWord) {
                    bgColor = const Color(0xFFEBF3F5); // Petrol Tint
                  } else if (cell.isError) {
                    bgColor = const Color(0xFFFDE8E8);
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
                      borderRadius: BorderRadius.circular(2.5),
                      border: Border.all(
                        color: isFocused
                            ? EditorialTheme.accent
                            : (isInFocusedWord
                                ? EditorialTheme.primary.withValues(alpha: 0.7)
                                : const Color(0xFFC0BBAF)),
                        width: isFocused ? 2.5 : 1.0,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;
                        // Proportional font sizing guaranteed not to overlap
                        final numFontSize = (h * 0.28).clamp(7.5, 12.0);
                        final letterFontSize = (h * 0.52).clamp(11.0, 24.0);
                        final topPadding = cell.number != null ? (h * 0.28) : 0.0;

                        return Stack(
                          children: [
                            // 1. Top-Left Clue Number (Strictly bounded in top 30% of cell)
                            if (cell.number != null)
                              Positioned(
                                top: 2.0,
                                left: 3.0,
                                child: Text(
                                  "${cell.number}",
                                  style: GoogleFonts.inter(
                                    fontSize: numFontSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    color: isFocused
                                        ? EditorialTheme.primary
                                        : EditorialTheme.textPrimary.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),

                            // 2. Direction Indicator Arrow (Top-Right of focused cell)
                            if (isFocused)
                              Positioned(
                                top: 2.0,
                                right: 3.0,
                                child: Icon(
                                  gameState.isAcrossFocus ? Icons.arrow_forward : Icons.arrow_downward,
                                  size: numFontSize * 0.95,
                                  color: EditorialTheme.primary,
                                ),
                              ),

                            // 3. User Input Letter (Bounded in lower region with top padding)
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: topPadding,
                                  bottom: 1.0,
                                  left: 1.0,
                                  right: 1.0,
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
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ).animate(
                                      key: ValueKey("anim_${r}_${c}_${cell.userChar}"),
                                    ).scale(
                                      duration: 150.ms,
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

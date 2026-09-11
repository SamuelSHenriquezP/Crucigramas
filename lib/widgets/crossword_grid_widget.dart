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

        // Container padding and cell spacing
        const double containerPadding = 12.0; // 6.0 each side
        const double cellSpacing = 2.0;

        final double usableW = math.max(0.0, maxW - containerPadding - 6.0);
        final double usableH = math.max(0.0, maxH - containerPadding - 6.0);

        final double cellByW = (usableW - (widget.board.cols - 1) * cellSpacing) / widget.board.cols;
        final double cellByH = (usableH - (widget.board.rows - 1) * cellSpacing) / widget.board.rows;

        // Choose the dimension that guarantees zero cutoff on both width and height:
        final double cellSize = math.min(cellByW, cellByH).clamp(16.0, 75.0);

        final double targetBoardWidth = cellSize * widget.board.cols + (widget.board.cols - 1) * cellSpacing + containerPadding;
        final double targetBoardHeight = cellSize * widget.board.rows + (widget.board.rows - 1) * cellSpacing + containerPadding;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(35.0),
                minScale: 0.85,
                maxScale: 3.5,
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: targetBoardWidth,
                  height: targetBoardHeight,
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco limpio y nítido para el tablero
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color(0xFFE5E0D3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF174A5B).withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
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

                        // Las posiciones bloqueadas son 100% transparentes e invisibles (cero cuadros negros)
                        if (cell.isBlack) {
                          return const SizedBox.shrink();
                        }

                        final isFocused = (gameState.focusedRow == r && gameState.focusedCol == c);
                        final isInFocusedWord = focusedWord != null && focusedWord.containsCell(r, c);
                        final isCelebratedCell = gameState.lastCompletedWordCelebration != null &&
                            gameState.lastCompletedWordCelebration!.containsCell(r, c);

                        // Paleta de colores para celdas estilo ficha moderna
                        Color bgColor = Colors.white;
                        if (cell.isError) {
                          bgColor = const Color(0xFFFEE2E2); // Tinte rojo error
                        } else if (isFocused) {
                          bgColor = const Color(0xFFFEF3C7); // Ámbar dorado cálido enfocado
                        } else if (isInFocusedWord) {
                          bgColor = const Color(0xFFEBF3F5); // Suave tinte azul petróleo para la palabra activa
                        } else if (cell.isRevealed) {
                          bgColor = const Color(0xFFFEF9C3); // Tinte dorado de pista revelada
                        }

                        Color textColor = const Color(0xFF1E2124); // Tinta carbón de alta legibilidad
                        if (cell.isError) {
                          textColor = EditorialTheme.error;
                        } else if (cell.isRevealed) {
                          textColor = EditorialTheme.primary;
                        }

                        Widget cellContent = AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(3.5),
                            border: Border.all(
                              color: isFocused
                                  ? const Color(0xFFB45309) // Borde ámbar enfocado
                                  : (isInFocusedWord
                                      ? EditorialTheme.primary // Borde palabra activa
                                      : const Color(0xFFCBC6B8)), // Borde nítido ficha blanca
                              width: isFocused ? 2.2 : (isInFocusedWord ? 1.4 : 0.9),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isFocused
                                    ? const Color(0xFFB45309).withValues(alpha: 0.25)
                                    : (isInFocusedWord
                                        ? EditorialTheme.primary.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.04)),
                                blurRadius: isFocused ? 4.0 : 1.5,
                                offset: Offset(0, isFocused ? 2.0 : 1.0),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, cellConstraints) {
                              final h = cellConstraints.maxHeight;
                              final numFontSize = (h * 0.26).clamp(7.0, 11.5);
                              final letterFontSize = (h * 0.60).clamp(13.0, 26.0);

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // 1. Número de pista en esquina superior izquierda
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
                                          color: const Color(0xFF2B2F33),
                                        ),
                                      ),
                                    ),

                                  // 2. Indicador de dirección en esquina superior derecha de celda enfocada
                                  if (isFocused)
                                    Positioned(
                                      top: 2.0,
                                      right: 2.5,
                                      child: Icon(
                                        gameState.isAcrossFocus ? Icons.arrow_forward_rounded : Icons.arrow_downward_rounded,
                                        size: numFontSize * 1.0,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),

                                  // 3. Letra con animación elástica al teclear
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
                                            key: ValueKey("anim_pop_${r}_${c}_${cell.userChar}"),
                                          ).scale(
                                            begin: const Offset(0.4, 0.4),
                                            end: const Offset(1.0, 1.0),
                                            duration: 180.ms,
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

                        // Animación de celebración al completar una palabra
                        if (isCelebratedCell) {
                          cellContent = cellContent.animate(
                            key: ValueKey("celeb_${r}_${c}_${gameState.wordCelebrationTick}"),
                          ).scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.10, 1.10),
                            duration: 180.ms,
                            curve: Curves.easeInOut,
                          ).then().scale(
                            begin: const Offset(1.10, 1.10),
                            end: const Offset(1.0, 1.0),
                            duration: 180.ms,
                            curve: Curves.easeInOut,
                          ).shimmer(
                            duration: 650.ms,
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                          );
                        }

                        // Destello radiante para letras reveladas por comodín
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
      },
    );
  }
}

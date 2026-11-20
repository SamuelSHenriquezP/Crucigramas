import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/crossword_board.dart';
import '../../models/crossword_cell.dart';
import '../../services/ad_manager.dart';
import '../../services/game_state_provider.dart';
import '../../theme/editorial_theme.dart';
import '../../widgets/crossword_grid_widget.dart';
import '../../widgets/clue_dock_widget.dart';
import '../../widgets/editorial_keyboard.dart';
import '../../widgets/level_success_dialog.dart';
import '../../widgets/newspaper_tutorial_dialog.dart';

class CrosswordGameScreen extends StatefulWidget {
  const CrosswordGameScreen({super.key});

  @override
  State<CrosswordGameScreen> createState() => _CrosswordGameScreenState();
}

class _CrosswordGameScreenState extends State<CrosswordGameScreen> {
  bool _dialogShown = false;
  int _lastSeenCelebrationTick = 0;
  String? _celebratingWord;
  bool _celebratingIsNew = false;
  Timer? _celebrationTimer;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeTutorial();
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkFirstTimeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('tutorial_seen_game') ?? false;
    if (!seen && mounted) {
      await prefs.setBool('tutorial_seen_game', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) NewspaperTutorialDialog.show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    if (gameState.wordCelebrationTick > _lastSeenCelebrationTick) {
      _lastSeenCelebrationTick = gameState.wordCelebrationTick;
      final completedWord = gameState.lastCompletedWordCelebration?.word;
      if (completedWord != null && completedWord.isNotEmpty && !gameState.isLevelComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _celebrationTimer?.cancel();
          setState(() {
            _celebratingWord = completedWord;
            _celebratingIsNew = gameState.lastCelebratedWordIsNew;
          });
          _celebrationTimer = Timer(const Duration(milliseconds: 2000), () {
            if (mounted) {
              setState(() {
                _celebratingWord = null;
              });
            }
          });
        });
      }
    }

    if (gameState.isLevelComplete && !_dialogShown && !gameState.isReviewMode) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => LevelSuccessDialog(
            coinsEarned: gameState.levelReward,
            newlyDiscoveredWords: gameState.newlyDiscoveredWords,
            onNextLevel: () {
              setState(() => _dialogShown = false);
              AdManager.onLevelCompleted(context);
              if (gameState.isTutorialLevel) {
                Navigator.pop(context);
              } else {
                gameState.startNewLevel(
                  title: "Siguiente Edición",
                  category: gameState.currentBoard?.category ?? "Todos",
                );
              }
            },
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        backgroundColor: EditorialTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.8),
          child: Divider(height: 0.8, thickness: 0.8, color: EditorialTheme.borderLine),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, size: 20, color: EditorialTheme.inkDark),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    gameState.currentBoard?.title ?? "Crucigrama",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                ),
                if (gameState.isReviewMode) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    color: EditorialTheme.inkDark,
                    child: Text(
                      "ARCHIVO",
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: EditorialTheme.surface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              gameState.isReviewMode
                  ? "MODO LECTURA  ·  HEMEROTECA"
                  : "${gameState.currentBoard?.placedWords.length ?? 0} PALABRAS  ·  ${(gameState.currentBoard?.category ?? 'General').toUpperCase()}",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: EditorialTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: EditorialTheme.surface,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: EditorialTheme.accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${gameState.coins}",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.help_outline, color: EditorialTheme.textSecondary, size: 20),
            tooltip: "Manual de Instrucciones",
            onPressed: () => NewspaperTutorialDialog.show(context),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.lightbulb_outline, color: EditorialTheme.primary, size: 20),
            tooltip: "Ayudas y Pistas",
            color: EditorialTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: EditorialTheme.borderLine, width: 1.0),
            ),
            onSelected: (value) {
              if (value == 'free_hint') {
                if (!gameState.useFreeDailyHint()) {
                  _showInfoSnackBar(context, "No hay casillas pendientes para la pista gratuita.");
                }
              } else if (value == 'letter') {
                if (!gameState.revealLetter()) {
                  _showNotEnoughCoinsSnackBar(context);
                }
              } else if (value == 'word') {
                if (!gameState.revealWord()) {
                  _showNotEnoughCoinsSnackBar(context);
                }
              } else if (value == 'check') {
                if (!gameState.checkErrors()) {
                  _showNotEnoughCoinsSnackBar(context);
                }
              } else if (value == 'clear_word') {
                gameState.clearCurrentWord();
              } else if (value == 'toggle_sound') {
                gameState.toggleSound();
              }
            },
            itemBuilder: (ctx) => [
              if (gameState.hasFreeDailyHintToday)
                PopupMenuItem(
                  value: 'free_hint',
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: EditorialTheme.success),
                      const SizedBox(width: 10),
                      Text(
                        "Pista gratis del día (0 mon.)",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: EditorialTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'letter',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18, color: EditorialTheme.primary),
                    const SizedBox(width: 10),
                    Text("Revelar Letra (35 mon.)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'word',
                child: Row(
                  children: [
                    const Icon(Icons.spellcheck, size: 18, color: EditorialTheme.accent),
                    const SizedBox(width: 10),
                    Text("Revelar Palabra (80 mon.)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'check',
                child: Row(
                  children: [
                    const Icon(Icons.rule, size: 18, color: EditorialTheme.error),
                    const SizedBox(width: 10),
                    Text("Comprobar Errores (25 mon.)", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear_word',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services_outlined, size: 18, color: EditorialTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text("Limpiar palabra actual", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_sound',
                child: Row(
                  children: [
                    Icon(
                      gameState.soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                      size: 18,
                      color: EditorialTheme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      gameState.soundEnabled ? "Sonido: Activado" : "Sonido: Silenciado",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: gameState.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(color: EditorialTheme.inkDark, strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "IMPRIMIENDO LA EDICIÓN...",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          : gameState.currentBoard == null
              ? const Center(child: Text("Error al generar crucigrama"))
              : SafeArea(
                  child: Column(
                    children: [
                      // Quiet typographic progress line
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 2.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "PROGRESO  ·  ${_getSolvedWordsCount(gameState.currentBoard!)}/${gameState.currentBoard!.placedWords.length}",
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: EditorialTheme.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "DICCIONARIO: ${gameState.solvedWordIds.length}",
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: EditorialTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 2.5,
                              color: EditorialTheme.borderLine.withValues(alpha: 0.6),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final total = gameState.currentBoard!.placedWords.length;
                                  final solved = _getSolvedWordsCount(gameState.currentBoard!);
                                  final ratio = total == 0 ? 0.0 : (solved / total).clamp(0.0, 1.0);
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      width: c.maxWidth * ratio,
                                      height: 2.5,
                                      color: EditorialTheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (gameState.isTutorialLevel)
                        _buildTutorialBanner(gameState),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Center(
                                child: CrosswordGridWidget(board: gameState.currentBoard!),
                              ),
                              if (_celebratingWord != null)
                                Positioned(
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: _celebratingIsNew ? EditorialTheme.primary : EditorialTheme.secondary,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _celebratingIsNew ? Icons.menu_book_outlined : Icons.check_sharp,
                                          color: EditorialTheme.surface,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          _celebratingIsNew
                                              ? "ARCHIVADA EN LÉXICO: $_celebratingWord"
                                              : "RESUELTA: $_celebratingWord",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.7,
                                            color: EditorialTheme.surface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(duration: 180.ms).slideY(begin: -0.2, end: 0),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const ClueDockWidget(),

                      gameState.isReviewMode
                          ? _buildReviewModeBottomBar(context)
                          : const EditorialKeyboard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTutorialBanner(GameStateProvider gameState) {
    if (gameState.currentBoard == null) return const SizedBox.shrink();

    final palabraWord = gameState.currentBoard!.placedWords
        .cast<PlacedWord?>()
        .firstWhere((w) => w?.word == 'PALABRA', orElse: () => null);
    final papelWord = gameState.currentBoard!.placedWords
        .cast<PlacedWord?>()
        .firstWhere((w) => w?.word == 'PAPEL', orElse: () => null);

    final bool isPalabraDone = palabraWord != null &&
        gameState.completedWordIdsInCurrentLevel.contains(palabraWord.wordId);
    final bool isPapelDone = papelWord != null &&
        gameState.completedWordIdsInCurrentLevel.contains(papelWord.wordId);

    String stepTitle = "PASO I · TU PRIMER VOCABLO";
    String stepText = "Toca la casilla inicial (P) y escribe PALABRA según la pista inferior.";
    IconData stepIcon = Icons.touch_app_outlined;

    if (!isPalabraDone) {
      bool hasSomeChars = false;
      for (int c = 0; c < 7; c++) {
        if (gameState.currentBoard!.grid[0][c].userChar.isNotEmpty) {
          hasSomeChars = true;
          break;
        }
      }
      if (hasSomeChars) {
        stepTitle = "PASO II · COMPLETA 'PALABRA'";
        stepText = "Usa el teclado inferior para escribir P - A - L - A - B - R - A.";
        stepIcon = Icons.keyboard_outlined;
      }
    } else if (!isPapelDone) {
      stepTitle = "PASO III · EL CRUCE VERTICAL";
      stepText = "La 'P' inicial ya cruza con la vertical 'PAPEL'. Toca debajo y escribe A - P - E - L.";
      stepIcon = Icons.alt_route;
    } else {
      stepTitle = "TUTORIAL COMPLETADO";
      stepText = "Has resuelto tu primer crucigrama entendiendo los cruces compartidos.";
      stepIcon = Icons.check_box_outlined;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: EditorialTheme.surface,
        border: Border(
          left: BorderSide(color: EditorialTheme.secondary, width: 3.0),
          top: BorderSide(color: EditorialTheme.borderLine, width: 0.7),
          right: BorderSide(color: EditorialTheme.borderLine, width: 0.7),
          bottom: BorderSide(color: EditorialTheme.borderLine, width: 0.7),
        ),
      ),
      child: Row(
        children: [
          Icon(stepIcon, color: EditorialTheme.secondary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepTitle,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: EditorialTheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stepText,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: EditorialTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewModeBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: EditorialTheme.surface,
        border: Border(top: BorderSide(color: EditorialTheme.inkDark, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.archive_outlined, color: EditorialTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "EDICIÓN DE ARCHIVO EN MODO LECTURA",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: EditorialTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Toca cualquier casilla para consultar la definición resuelta.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: EditorialTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              side: const BorderSide(color: EditorialTheme.inkDark, width: 1.2),
            ),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(
              "VOLVER A LA HEMEROTECA",
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  int _getSolvedWordsCount(CrosswordBoard board) {
    int solvedCount = 0;
    for (final pw in board.placedWords) {
      bool wordCorrect = true;
      for (int k = 0; k < pw.word.length; k++) {
        final int r = pw.isAcross ? pw.startRow : pw.startRow + k;
        final int c = pw.isAcross ? pw.startCol + k : pw.startCol;
        if (!board.grid[r][c].isCorrect) {
          wordCorrect = false;
          break;
        }
      }
      if (wordCorrect) solvedCount++;
    }
    return solvedCount;
  }

  void _showNotEnoughCoinsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: EditorialTheme.error,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        content: Text(
          "Monedas insuficientes para activar esta ayuda.",
          style: GoogleFonts.inter(color: EditorialTheme.surface, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: EditorialTheme.inkDark,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        content: Text(
          message,
          style: GoogleFonts.inter(color: EditorialTheme.surface, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

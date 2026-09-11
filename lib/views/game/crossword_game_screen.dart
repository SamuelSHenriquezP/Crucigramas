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

    // Check for single word completion celebration
    if (gameState.wordCelebrationTick > _lastSeenCelebrationTick) {
      _lastSeenCelebrationTick = gameState.wordCelebrationTick;
      final completedWord = gameState.lastCompletedWordCelebration?.word;
      if (completedWord != null && completedWord.isNotEmpty && !gameState.isLevelComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _celebrationTimer?.cancel();
          setState(() {
            _celebratingWord = completedWord;
          });
          _celebrationTimer = Timer(const Duration(milliseconds: 2200), () {
            if (mounted) {
              setState(() {
                _celebratingWord = null;
              });
            }
          });
        });
      }
    }

    // Check for level completion dialog trigger
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
                // Exit tutorial to home
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (gameState.isReviewMode) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: EditorialTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "ARCHIVO",
                      style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.bold, color: EditorialTheme.accent),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              gameState.isReviewMode
                  ? "Modo Lectura • Hemeroteca Histórica"
                  : "${gameState.currentBoard?.placedWords.length ?? 0} Palabras • ${gameState.currentBoard?.category ?? 'General'}",
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: EditorialTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Coins Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: EditorialTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EditorialTheme.accent, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: EditorialTheme.accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  "${gameState.coins}",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Tutorial button
          IconButton(
            icon: const Icon(Icons.help_outline, color: EditorialTheme.primary, size: 22),
            tooltip: "Manual de Instrucciones",
            onPressed: () => NewspaperTutorialDialog.show(context),
          ),

          // Hint Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.lightbulb_outlined, color: EditorialTheme.accent),
            tooltip: "Ayudas y Pistas",
            onSelected: (value) {
              if (value == 'letter') {
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
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'letter',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18, color: EditorialTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Revelar Letra (35 mon.)",
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'word',
                child: Row(
                  children: [
                    const Icon(Icons.spellcheck, size: 18, color: EditorialTheme.accent),
                    const SizedBox(width: 8),
                    Text(
                      "Revelar Palabra (80 mon.)",
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'check',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services, size: 18, color: EditorialTheme.error),
                    const SizedBox(width: 8),
                    Text(
                      "Comprobar Errores (25 mon.)",
                      style: GoogleFonts.inter(fontSize: 13),
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
                  const CircularProgressIndicator(color: EditorialTheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    "Imprimiendo la edición...",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
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
                  // Level Progress Indicator Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "PROGRESO EN LA EDICIÓN",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: EditorialTheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${_getSolvedWordsCount(gameState.currentBoard!)} / ${gameState.currentBoard!.placedWords.length} Palabras",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: EditorialTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: gameState.currentBoard!.placedWords.isEmpty
                                ? 0.0
                                : _getSolvedWordsCount(gameState.currentBoard!) /
                                    gameState.currentBoard!.placedWords.length,
                            backgroundColor: EditorialTheme.borderLine.withValues(alpha: 0.4),
                            color: EditorialTheme.accent,
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tutorial Step-by-Step Banner
                  if (gameState.isTutorialLevel)
                    _buildTutorialBanner(gameState),

                  // Interactive Crossword Board Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Center(
                            child: CrosswordGridWidget(board: gameState.currentBoard!),
                          ),
                          // Notificación gráfica flotante al resolver una palabra
                          if (_celebratingWord != null)
                            Positioned(
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B4332), // Verde bosque editorial profundo
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFF52B788), width: 1.4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.22),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 20)
                                        .animate(onPlay: (c) => c.repeat(reverse: true))
                                        .scale(
                                          begin: const Offset(0.9, 0.9),
                                          end: const Offset(1.15, 1.15),
                                          duration: 400.ms,
                                        ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "¡Palabra descubierta: $_celebratingWord!",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().scale(
                                duration: 250.ms,
                                curve: Curves.easeOutBack,
                              ).fadeIn(duration: 200.ms),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Clue Dock
                  const ClueDockWidget(),

                  // Keyboard or Review Mode Bar
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

    String stepTitle = "PASO 1: TU PRIMER VOCABLO";
    String stepText = "Toca la casilla inicial (P). Observa la pista superior: 'Unidad lingüística dotada de significado'. ¡Escribe PALABRA!";
    IconData stepIcon = Icons.touch_app;

    if (!isPalabraDone) {
      bool hasSomeChars = false;
      for (int c = 0; c < 7; c++) {
        if (gameState.currentBoard!.grid[0][c].userChar.isNotEmpty) {
          hasSomeChars = true;
          break;
        }
      }
      if (hasSomeChars) {
        stepTitle = "PASO 2: COMPLETA 'PALABRA'";
        stepText = "Usa el teclado inferior para escribir P - A - L - A - B - R - A. Las casillas avanzan automáticamente.";
        stepIcon = Icons.keyboard;
      }
    } else if (!isPapelDone) {
      stepTitle = "PASO 3: EL CRUCE DE PALABRAS";
      stepText = "¡Excelente! Fíjate cómo la 'P' inicial ya está escrita para la palabra vertical 'PAPEL'. Toca y escribe: A - P - E - L.";
      stepIcon = Icons.alt_route;
    } else {
      stepTitle = "¡TUTORIAL SUPERADO!";
      stepText = "¡Has completado tu primer crucigrama! Las palabras cruzadas comparten letras en sus intersecciones.";
      stepIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EditorialTheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EditorialTheme.secondary, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(stepIcon, color: EditorialTheme.secondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepTitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
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
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildReviewModeBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        border: const Border(top: BorderSide(color: EditorialTheme.borderLine, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.archive_outlined, color: EditorialTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                "EDICIÓN DE ARCHIVO EN MODO LECTURA",
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: EditorialTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Toca cualquier casilla para ver su definición y palabra resuelta.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: EditorialTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Volver a la Hemeroteca"),
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
        int r = pw.isAcross ? pw.startRow : pw.startRow + k;
        int c = pw.isAcross ? pw.startCol + k : pw.startCol;
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
        content: Text(
          "Monedas insuficientes para activar esta ayuda.",
          style: GoogleFonts.inter(color: EditorialTheme.surface),
        ),
      ),
    );
  }
}

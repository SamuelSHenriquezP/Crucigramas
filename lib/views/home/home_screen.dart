import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/dictionary_repository.dart';
import '../../services/game_state_provider.dart';
import '../../theme/editorial_theme.dart';
import '../../widgets/newspaper_tutorial_dialog.dart';
import '../dictionary/dictionary_screen.dart';
import '../game/crossword_game_screen.dart';
import '../history/history_screen.dart';
import '../shop/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0: Hoy, 1: Explorar, 2: Archivo
  int _archiveSegment = 0; // 0: Diccionario, 1: Hemeroteca
  int _quickWords = 9;
  String _quickDifficulty = 'medio';

  static const List<String> _months = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  static const List<String> _weekdays = [
    'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO',
  ];

  static const List<Map<String, String>> _featuredThemes = [
    {'name': 'Historia', 'image': 'dossier_historia.png'},
    {'name': 'Ciencia', 'image': 'dossier_ciencia.png'},
    {'name': 'Arte', 'image': 'dossier_arte.png'},
    {'name': 'Literatura', 'image': 'dossier_literatura.png'},
    {'name': 'Geografía', 'image': 'dossier_geografia.png'},
    {'name': 'Tecnología', 'image': 'dossier_tecnologia.png'},
    {'name': 'Filosofía', 'image': 'dossier_filosofia.png'},
    {'name': 'Entretenimiento', 'image': 'dossier_entretenimiento.png'},
  ];

  String _cleanHeroTitle(String rawTitle) {
    final idx = rawTitle.indexOf(' (');
    if (idx > 0 && rawTitle.startsWith('Crucigrama del Día')) {
      return rawTitle.substring(0, idx);
    }
    return rawTitle;
  }

  void _openShop() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const ShopScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage;
    switch (_currentTab) {
      case 1:
        activePage = KeyedSubtree(
          key: const ValueKey('tab_explorar'),
          child: _buildExploreTab(context),
        );
        break;
      case 2:
        activePage = KeyedSubtree(
          key: const ValueKey('tab_archivo'),
          child: _buildArchiveTab(context),
        );
        break;
      case 0:
      default:
        activePage = KeyedSubtree(
          key: const ValueKey('tab_hoy'),
          child: _buildTodayTab(context),
        );
        break;
    }

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: activePage,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: EditorialTheme.background,
          border: Border(
            top: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated top active indicator sliding between the 3 tabs
              SizedBox(
                height: 2,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(-1.0 + _currentTab * 1.0, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 2,
                        color: EditorialTheme.inkDark,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    _buildNavItem(index: 0, icon: Icons.grid_on_sharp, label: 'Hoy'),
                    _buildNavItem(index: 1, icon: Icons.explore_outlined, label: 'Explorar'),
                    _buildNavItem(index: 2, icon: Icons.collections_bookmark_outlined, label: 'Archivo'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_currentTab != index) {
            HapticFeedback.selectionClick();
            setState(() => _currentTab = index);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? EditorialTheme.inkDark : EditorialTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? EditorialTheme.inkDark : EditorialTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinWalletBadge(int coins) {
    return _TactilePress(
      onTap: _openShop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: EditorialTheme.surface,
          border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_outlined,
              size: 14,
              color: EditorialTheme.accent,
            ),
            const SizedBox(width: 5),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: coins, end: coins),
              duration: const Duration(milliseconds: 450),
              builder: (_, val, _) => Text(
                "$val",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: EditorialTheme.inkDark,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.storefront_outlined,
              size: 13,
              color: EditorialTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 0: HOY — Editorial Hero + Playful Animated Bento
  // ---------------------------------------------------------------------------
  Widget _buildTodayTab(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();
    final now = DateTime.now();
    final dateHeader = "${_weekdays[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}";
    final featuredTheme = _featuredThemes[now.day % _featuredThemes.length];
    final featuredName = featuredTheme['name']!;
    final featuredImage = featuredTheme['image']!;

    final bool hasDraft = gameState.hasSavedDraft;
    final bool draftIsNonDaily = hasDraft && !gameState.draftTitle.startsWith('Crucigrama del Día');

    final String heroEyebrow;
    final String heroTitle;
    final String heroCta;
    final VoidCallback heroAction;

    if (hasDraft) {
      heroEyebrow = "EN CURSO";
      heroTitle = _cleanHeroTitle(gameState.draftTitle);
      heroCta = "Continuar";
      heroAction = () async {
        await gameState.resumeSavedDraft();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
          );
        }
      };
    } else if (!gameState.isTutorialCompleted && gameState.completedLevelsCount == 0) {
      heroEyebrow = "INICIO  ·  +150 MONEDAS";
      heroTitle = "Tu Primer Crucigrama";
      heroCta = "Empezar";
      heroAction = () async {
        await gameState.startTutorialLevel();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
          );
        }
      };
    } else {
      final doneToday = gameState.isDailyCompletedToday;
      heroEyebrow = doneToday ? "COMPLETADO" : "+200 MONEDAS";
      heroTitle = "Crucigrama del Día";
      heroCta = doneToday ? "Rejugar" : "Jugar hoy";
      heroAction = () {
        gameState.startDailyChallenge();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
        );
      };
    }

    final int solvedCount = gameState.solvedWordIds.length;
    final int totalWords = repo.allWords.length;
    final double lexRatio = totalWords == 0 ? 0.0 : (solvedCount / totalWords).clamp(0.0, 1.0);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Clean 1-line Masthead
            Row(
              children: [
                Expanded(
                  child: Text(
                    "EL CRUCIGRAMISTA",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: EditorialTheme.inkDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCoinWalletBadge(gameState.coins),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.only(left: 6),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.help_outline,
                    size: 19,
                    color: EditorialTheme.textSecondary,
                  ),
                  tooltip: "Manual y práctica",
                  onPressed: () => NewspaperTutorialDialog.show(context),
                ),
              ],
            ).animate().fadeIn(duration: 220.ms),
            const SizedBox(height: 10),
            Container(height: 0.8, color: EditorialTheme.borderLine),

            // 2. Date & Streak
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateHeader,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  Text(
                    "RACHA ${gameState.streak}D",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: EditorialTheme.accent,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 40.ms, duration: 240.ms),

            // 3. Hero Card with Playful Animated Crossword Motif
            _TactilePress(
              onTap: heroAction,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                heroEyebrow,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: EditorialTheme.accent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                heroTitle,
                                style: EditorialTheme.getEditorialFont(
                                  fontId: gameState.activeFontId,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: EditorialTheme.inkDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const _AnimatedHeroCrosswordMotif(),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      color: EditorialTheme.inkDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            heroCta.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_sharp,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms).slideY(
                  begin: 0.04,
                  end: 0,
                  curve: Curves.easeOutCubic,
                ),

            const SizedBox(height: 14),

            // 4. Asymmetric 2-Column Editorial Bento
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: _TactilePress(
                      onTap: () => setState(() => _currentTab = 1),
                      child: Container(
                        color: const Color(0xFFF3F3F3),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "EXPLORAR",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.3,
                                    color: EditorialTheme.primary,
                                  ),
                                ),
                                const Icon(
                                  Icons.tune_sharp,
                                  size: 16,
                                  color: EditorialTheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Partida rápida",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: EditorialTheme.inkDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Elige tamaño, dificultad y colección",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    height: 1.35,
                                    color: EditorialTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Icon(
                                  Icons.arrow_forward_sharp,
                                  size: 14,
                                  color: EditorialTheme.inkDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 280.ms).slideY(
                          begin: 0.05,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _TactilePress(
                            onTap: () {
                              if (draftIsNonDaily) {
                                gameState.startDailyChallenge();
                              } else {
                                gameState.startNewLevel(
                                  title: featuredName,
                                  category: featuredName,
                                );
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const CrosswordGameScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: EditorialTheme.borderLine,
                                  width: 0.9,
                                ),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        draftIsNonDaily ? "EDICIÓN DIARIA" : "DESTACADA",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: EditorialTheme.accent,
                                        ),
                                      ),
                                      if (!draftIsNonDaily)
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Image.asset(
                                            'assets/images/$featuredImage',
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, _, _) => const Icon(
                                              Icons.auto_awesome_outlined,
                                              size: 16,
                                              color: EditorialTheme.inkDark,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          draftIsNonDaily ? "Crucigrama del Día" : featuredName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: EditorialTheme.inkDark,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_sharp,
                                        size: 13,
                                        color: EditorialTheme.textSecondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _TactilePress(
                          onTap: () => setState(() {
                            _currentTab = 2;
                            _archiveSegment = 0;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: EditorialTheme.borderLine,
                                width: 0.9,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "DICCIONARIO",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: EditorialTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      "$solvedCount / $totalWords",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        color: EditorialTheme.inkDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: lexRatio),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, value, _) => LinearProgressIndicator(
                                    value: value,
                                    minHeight: 3,
                                    backgroundColor: const Color(0xFFEDEDED),
                                    color: EditorialTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 160.ms, duration: 280.ms).slideY(
                          begin: 0.05,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: EXPLORAR — Builder + Illustrated Carousel + Clean Tag Cloud + Práctica
  // ---------------------------------------------------------------------------
  Widget _buildExploreTab(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();
    final allCategories = repo.getCategories().where((c) => c != 'Todos').toList();

    final int reward = _quickDifficulty == 'facil'
        ? 50
        : (_quickDifficulty == 'medio' ? 100 : 200);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explorar",
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.inkDark,
                  ),
                ),
                _buildCoinWalletBadge(gameState.coins),
              ],
            ),
          ),
          Container(height: 0.8, color: EditorialTheme.borderLine),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "CONSTRUCTOR RÁPIDO",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildSizeVisualCard(label: "Corto", count: 6, gridCells: 2),
                      const SizedBox(width: 10),
                      _buildSizeVisualCard(label: "Normal", count: 9, gridCells: 3),
                      const SizedBox(width: 10),
                      _buildSizeVisualCard(label: "Extenso", count: 12, gridCells: 4),
                    ],
                  ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildDiffChip(
                        label: "Fácil",
                        val: "facil",
                        color: EditorialTheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      _buildDiffChip(
                        label: "Media",
                        val: "medio",
                        color: EditorialTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildDiffChip(
                        label: "Experto",
                        val: "avanzado",
                        color: EditorialTheme.error,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _TactilePress(
                    onTap: () {
                      final diffTitle = _quickDifficulty == 'facil'
                          ? 'Fácil'
                          : (_quickDifficulty == 'medio' ? 'Media' : 'Experto');
                      gameState.startNewLevel(
                        title: "Crucigrama $diffTitle",
                        category: "Todos",
                        targetWordsCount: _quickWords,
                        difficultyFilter: _quickDifficulty,
                        reward: reward,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                      );
                    },
                    child: Container(
                      color: EditorialTheme.inkDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "JUGAR  ·  +$reward MON.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_sharp,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),
                  Container(height: 0.8, color: EditorialTheme.borderLine),
                  const SizedBox(height: 20),

                  Text(
                    "COLECCIONES ILUSTRADAS",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _featuredThemes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final theme = _featuredThemes[i];
                        final name = theme['name']!;
                        final image = theme['image']!;
                        return _TactilePress(
                          onTap: () {
                            gameState.startNewLevel(title: name, category: name);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const CrosswordGameScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 110,
                            color: const Color(0xFFF4F4F4),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Image.asset(
                                    'assets/images/$image',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.menu_book_outlined,
                                      size: 22,
                                      color: EditorialTheme.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: EditorialTheme.inkDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (i * 35).ms, duration: 220.ms);
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    "TODAS LAS ÁREAS",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allCategories.map((cat) {
                      return _TactilePress(
                        onTap: () {
                          gameState.startNewLevel(title: cat, category: cat);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const CrosswordGameScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: EditorialTheme.inkDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  Container(height: 0.8, color: EditorialTheme.borderLine),
                  const SizedBox(height: 16),

                  _TactilePress(
                    onTap: () async {
                      await gameState.startTutorialLevel();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 18,
                            color: EditorialTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Práctica guiada (PALABRA)",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: EditorialTheme.inkDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_sharp,
                            size: 14,
                            color: EditorialTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ARCHIVO — Unified Diccionario + Hemeroteca + Quiosco access
  // ---------------------------------------------------------------------------
  Widget _buildArchiveTab(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Archivo",
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.inkDark,
                  ),
                ),
                _buildCoinWalletBadge(gameState.coins),
              ],
            ),
          ),

          // Smooth Segmented Switcher: Diccionario | Hemeroteca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildArchiveSegmentButton(
                  index: 0,
                  label: "Diccionario",
                ),
                _buildArchiveSegmentButton(
                  index: 1,
                  label: "Hemeroteca (${gameState.completedHistory.length})",
                ),
              ],
            ),
          ),
          Container(height: 0.8, color: EditorialTheme.borderLine),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              child: _archiveSegment == 0
                  ? const DictionaryScreen(key: ValueKey('arch_dict'), embedded: true)
                  : const HistoryScreen(key: ValueKey('arch_hist'), embedded: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveSegmentButton({
    required int index,
    required String label,
  }) {
    final selected = _archiveSegment == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_archiveSegment != index) {
            HapticFeedback.selectionClick();
            setState(() => _archiveSegment = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? EditorialTheme.inkDark : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? EditorialTheme.inkDark : EditorialTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeVisualCard({
    required String label,
    required int count,
    required int gridCells,
  }) {
    final selected = _quickWords == count;
    return Expanded(
      child: _TactilePress(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _quickWords = count);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? EditorialTheme.inkDark : const Color(0xFFF5F5F5),
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: _MiniProportionGrid(
                  cells: gridCells,
                  activeColor: selected ? Colors.white : EditorialTheme.inkDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : EditorialTheme.inkDark,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                "$count palabras",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.78)
                      : EditorialTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffChip({
    required String label,
    required String val,
    required Color color,
  }) {
    final selected = _quickDifficulty == val;
    return Expanded(
      child: _TactilePress(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _quickDifficulty = val);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            border: Border.all(
              color: selected ? color : EditorialTheme.borderLine,
              width: 0.9,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : EditorialTheme.inkDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Comfortable micro-press spring feedback for cards and buttons
class _TactilePress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TactilePress({
    required this.child,
    required this.onTap,
  });

  @override
  State<_TactilePress> createState() => _TactilePressState();
}

class _TactilePressState extends State<_TactilePress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Playful animated 5x5 miniature crossword motif with staggered reveal letters
class _AnimatedHeroCrosswordMotif extends StatelessWidget {
  const _AnimatedHeroCrosswordMotif();

  // CASA (down col 1), PASO (across row 1), OLAS (down col 3), AZAR (across row 3)
  static const List<String?> _cells = [
    null, 'C', null, null, null,
    'P', 'A', 'S', 'O', null,
    null, 'S', null, 'L', null,
    null, 'A', 'Z', 'A', 'R',
    null, null, null, 'S', null,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
        ),
        itemCount: 25,
        itemBuilder: (ctx, i) {
          final char = _cells[i];
          if (char == null) return const SizedBox.shrink();
          final int row = i ~/ 5;
          final int col = i % 5;
          final bool highlight = (row == 1);
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlight ? EditorialTheme.cellFocused : Colors.white,
              border: Border.all(color: EditorialTheme.inkDark, width: 0.85),
            ),
            child: Text(
              char,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                color: EditorialTheme.inkDark,
                height: 1.0,
              ),
            ),
          ).animate().fadeIn(
                delay: ((row + col) * 45).ms,
                duration: 240.ms,
              ).scale(
                delay: ((row + col) * 45).ms,
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 260.ms,
                curve: Curves.easeOutBack,
              );
        },
      ),
    );
  }
}

/// Tiny proportional grid icon for board size cards (2x2, 3x3, 4x4)
class _MiniProportionGrid extends StatelessWidget {
  final int cells;
  final Color activeColor;

  const _MiniProportionGrid({
    required this.cells,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: SizedBox(
          width: cells * 5.2,
          height: cells * 5.2,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cells,
              crossAxisSpacing: 1.2,
              mainAxisSpacing: 1.2,
            ),
            itemCount: cells * cells,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: activeColor, width: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

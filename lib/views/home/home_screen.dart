import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/game_state_provider.dart';
import '../../services/dictionary_repository.dart';
import '../../theme/editorial_theme.dart';
import '../../widgets/newspaper_header.dart';
import '../game/crossword_game_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../shop/shop_screen.dart';
import '../categories/category_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Newspaper Masthead
                        const NewspaperHeader(
                          editionTitle: "EDICIÓN PRINCIPAL",
                          subtitle: "Revista Editorial de Intelecto",
                        ),

                        const SizedBox(height: 14),

              // 2. Centered Player Stats Bar (Coins, Solved Words, Streak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: EditorialTheme.newspaperCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.monetization_on,
                      color: EditorialTheme.accent,
                      label: "Monedas",
                      value: "${gameState.coins}",
                    ),
                    Container(height: 24, width: 1, color: EditorialTheme.borderLine),
                    _buildStatItem(
                      icon: Icons.menu_book,
                      color: EditorialTheme.primary,
                      label: "Léxico",
                      value: "${gameState.solvedWordIds.length} / ${repo.allWords.length}",
                    ),
                    Container(height: 24, width: 1, color: EditorialTheme.borderLine),
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      color: EditorialTheme.error,
                      label: "Racha",
                      value: "${gameState.streak} d.",
                     ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 16),

              // 3. Featured Hero Card: Active Draft OR Daily Challenge (Centered layout)
              gameState.hasSavedDraft
                  ? InkWell(
                      onTap: () async {
                        await gameState.resumeSavedDraft();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: EditorialTheme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: EditorialTheme.accent, width: 1.8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_note, color: EditorialTheme.accent, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  "BORRADOR GUARDADO",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: EditorialTheme.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gameState.draftTitle,
                              textAlign: TextAlign.center,
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Continúa resolviendo tu partida en borrador",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await gameState.resumeSavedDraft();
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EditorialTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.play_arrow, color: EditorialTheme.surface, size: 20),
                                label: Text(
                                  "CONTINUAR PARTIDA",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.surface,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        gameState.startDailyChallenge();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: gameState.isDailyCompletedToday
                              ? const Color(0xFFEFF5F1)
                              : EditorialTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: gameState.isDailyCompletedToday
                                ? EditorialTheme.success
                                : EditorialTheme.primary,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: EditorialTheme.primary.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gameState.isDailyCompletedToday
                                        ? EditorialTheme.success
                                        : EditorialTheme.accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gameState.isDailyCompletedToday
                                        ? "COMPLETADO HOY"
                                        : "DESAFÍO DEL DÍA",
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: gameState.isDailyCompletedToday
                                          ? EditorialTheme.surface
                                          : EditorialTheme.textPrimary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "+200 🪙",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Crucigrama del Día",
                              textAlign: TextAlign.center,
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: EditorialTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gameState.isDailyCompletedToday
                                  ? "Has completado la edición de hoy. ¡Vuelve mañana!"
                                  : "Edición especial diaria con palabras e intersecciones únicas.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  gameState.startDailyChallenge();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EditorialTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: Icon(
                                  gameState.isDailyCompletedToday ? Icons.replay : Icons.play_arrow_rounded,
                                  color: EditorialTheme.surface,
                                  size: 22,
                                ),
                                label: Text(
                                  gameState.isDailyCompletedToday ? "REJUGAR DESAFÍO" : "RESOLVER AHORA",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.surface,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              // 4. Centered 2x2 Grid of Main Action Cards
              Row(
                children: [
                  Expanded(
                    child: _buildCenteredActionCard(
                      context,
                      gameState,
                      icon: Icons.flash_on,
                      iconColor: EditorialTheme.accent,
                      title: "Partida Rápida",
                      subtitle: "Juega a tu gusto",
                      onTap: () => _showCustomGeneratorModal(context, gameState),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCenteredActionCard(
                      context,
                      gameState,
                      icon: Icons.explore,
                      iconColor: EditorialTheme.primary,
                      title: "Temáticas",
                      subtitle: "Categorías y temas",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const CategorySelectScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCenteredActionCard(
                      context,
                      gameState,
                      icon: Icons.auto_stories,
                      iconColor: EditorialTheme.primary,
                      title: "Diccionario",
                      subtitle: "Glosario y pistas",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const DictionaryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCenteredActionCard(
                      context,
                      gameState,
                      icon: Icons.storefront,
                      iconColor: EditorialTheme.accent,
                      title: "Quiosco",
                      subtitle: "Tienda y temas",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ShopScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: EditorialTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredActionCard(
    BuildContext context,
    GameStateProvider gameState, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: EditorialTheme.newspaperCardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: EditorialTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomGeneratorModal(BuildContext context, GameStateProvider gameState) {
    String selectedCategory = "Todos";
    String selectedDifficulty = "medio";
    int wordsCount = 9;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: EditorialTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: EditorialTheme.borderLine,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "PARTIDA A TU GUSTO",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Elige opciones sencillas para crear tu crucigrama ideal",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1. Size Presets (Corto, Normal, Grande)
                  Text(
                    "Tamaño de Crucigrama:",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPresetSizeChip(
                        label: "Rápido",
                        sublabel: "6 Palabras",
                        icon: Icons.bolt,
                        count: 6,
                        currentCount: wordsCount,
                        onTap: () => setModalState(() => wordsCount = 6),
                      ),
                      const SizedBox(width: 8),
                      _buildPresetSizeChip(
                        label: "Normal",
                        sublabel: "9 Palabras",
                        icon: Icons.grid_view,
                        count: 9,
                        currentCount: wordsCount,
                        onTap: () => setModalState(() => wordsCount = 9),
                      ),
                      const SizedBox(width: 8),
                      _buildPresetSizeChip(
                        label: "Grande",
                        sublabel: "12 Palabras",
                        icon: Icons.military_tech,
                        count: 12,
                        currentCount: wordsCount,
                        onTap: () => setModalState(() => wordsCount = 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 2. Difficulty Selector
                  Text(
                    "Dificultad:",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDifficultyOption(
                        label: "Fácil",
                        val: "facil",
                        selected: selectedDifficulty == "facil",
                        color: EditorialTheme.success,
                        onTap: () => setModalState(() => selectedDifficulty = "facil"),
                      ),
                      const SizedBox(width: 8),
                      _buildDifficultyOption(
                        label: "Media",
                        val: "medio",
                        selected: selectedDifficulty == "medio",
                        color: EditorialTheme.primary,
                        onTap: () => setModalState(() => selectedDifficulty = "medio"),
                      ),
                      const SizedBox(width: 8),
                      _buildDifficultyOption(
                        label: "Avanzada",
                        val: "avanzado",
                        selected: selectedDifficulty == "avanzado",
                        color: EditorialTheme.error,
                        onTap: () => setModalState(() => selectedDifficulty = "avanzado"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Start Game Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      gameState.startNewLevel(
                        title: "Crucigrama Personalizado",
                        category: selectedCategory,
                        targetWordsCount: wordsCount,
                        difficultyFilter: selectedDifficulty,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EditorialTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, color: EditorialTheme.surface, size: 24),
                    label: Text(
                      "¡EMPEZAR A JUGAR!",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: EditorialTheme.surface,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPresetSizeChip({
    required String label,
    required String sublabel,
    required IconData icon,
    required int count,
    required int currentCount,
    required VoidCallback onTap,
  }) {
    final isSelected = count == currentCount;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? EditorialTheme.primary.withValues(alpha: 0.12) : EditorialTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? EditorialTheme.primary : EditorialTheme.borderLine,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? EditorialTheme.primary : EditorialTheme.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? EditorialTheme.primary : EditorialTheme.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: EditorialTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required String label,
    required String val,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : EditorialTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : EditorialTheme.borderLine,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? color : EditorialTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

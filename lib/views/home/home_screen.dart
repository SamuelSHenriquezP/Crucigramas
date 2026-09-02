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
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Newspaper Masthead
              const NewspaperHeader(
                editionTitle: "EDICIÓN PRINCIPAL",
                subtitle: "Revista Editorial de Intelecto",
              ),

              const SizedBox(height: 14),

              // 2. Player Stats Bar (Coins, Solved Words, Streak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: EditorialTheme.newspaperCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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

              const SizedBox(height: 14),

              // 3. Featured Hero Card: Active Draft OR Daily Challenge
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: EditorialTheme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: EditorialTheme.accent, width: 1.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_note, color: EditorialTheme.accent, size: 24),
                                const SizedBox(width: 6),
                                Text(
                                  "BORRADOR GUARDADO",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: EditorialTheme.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              gameState.draftTitle,
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Continúa resolviendo tu partida en borrador.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                icon: const Icon(Icons.play_arrow, color: EditorialTheme.surface, size: 18),
                                label: Text(
                                  "Continuar",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.surface,
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
                        padding: const EdgeInsets.all(16),
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
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: gameState.isDailyCompletedToday
                                          ? EditorialTheme.surface
                                          : EditorialTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
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
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: EditorialTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gameState.isDailyCompletedToday
                                  ? "Has completado la edición de hoy. ¡Vuelve mañana!"
                                  : "Edición especial diaria con palabras e intersecciones únicas.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                icon: Icon(
                                  gameState.isDailyCompletedToday ? Icons.replay : Icons.play_arrow,
                                  color: EditorialTheme.surface,
                                  size: 18,
                                ),
                                label: Text(
                                  gameState.isDailyCompletedToday ? "Rejugar" : "Resolver Ahora",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.surface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              const SizedBox(height: 14),

              // 4. Secondary Action Cards: Select Dossier or Dictionary
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const CategorySelectScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: EditorialTheme.newspaperCardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.explore, color: EditorialTheme.primary, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              "DOSSIERS",
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Niveles y temas",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const DictionaryScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: EditorialTheme.newspaperCardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_stories, color: EditorialTheme.primary, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              "DICCIONARIO",
                              style: EditorialTheme.getEditorialFont(
                                fontId: gameState.activeFontId,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Glosario y pistas",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: EditorialTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Navigation Shortcuts (Quiosco / Tienda, Generador)
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryCard(
                      context,
                      icon: Icons.storefront,
                      title: "Quiosco",
                      subtitle: "Tienda y fuentes",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ShopScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSecondaryCard(
                      context,
                      icon: Icons.tune,
                      title: "Generador",
                      subtitle: "A tu medida",
                      onTap: () => _showCustomGeneratorModal(context, gameState),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildSecondaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: EditorialTheme.newspaperCardDecoration,
        child: Row(
          children: [
            Icon(icon, color: EditorialTheme.primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: EditorialTheme.textSecondary,
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

  void _showCustomGeneratorModal(BuildContext context, GameStateProvider gameState) {
    String selectedCategory = "Todos";
    String selectedDifficulty = "medio";
    int wordsCount = 8;

    showModalBottomSheet(
      context: context,
      backgroundColor: EditorialTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "GENERADOR PERSONALIZADO",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Configura la dificultad y tema del crucigrama",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Row
                  Text(
                    "Dificultad:",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['facil', 'medio', 'avanzado'].map((diff) {
                      final isSelected = selectedDifficulty == diff;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(diff.toUpperCase()),
                            selected: isSelected,
                            selectedColor: EditorialTheme.primary,
                            labelStyle: GoogleFonts.inter(
                              color: isSelected ? EditorialTheme.surface : EditorialTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => selectedDifficulty = diff);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Words Count Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cantidad de Palabras:",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "$wordsCount Palabras",
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: wordsCount.toDouble(),
                    min: 5,
                    max: 14,
                    divisions: 9,
                    activeColor: EditorialTheme.primary,
                    onChanged: (val) => setModalState(() => wordsCount = val.toInt()),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      gameState.startNewLevel(
                        title: "Edición Personalizada",
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Crear Crucigrama",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: EditorialTheme.surface,
                        fontSize: 15,
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
}

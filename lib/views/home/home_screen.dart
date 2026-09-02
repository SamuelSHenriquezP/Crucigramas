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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();
    final categories = repo.getCategories().where((c) => c != 'Todos').toList();

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Newspaper Masthead
              const NewspaperHeader(
                editionTitle: "EDICIÓN DE HOY",
                subtitle: "Revista de Crucigramas e Intelecto",
              ),

              const SizedBox(height: 10),

              // 2. Player Stats Bar (Coins, Solved Words, Streak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 10),

              // 3. Featured Card: Active Draft OR Daily Challenge
              if (gameState.hasSavedDraft) ...[
                InkWell(
                  onTap: () async {
                    await gameState.resumeSavedDraft();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EditorialTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: EditorialTheme.accent, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note, color: EditorialTheme.accent, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BORRADOR EN CURSO",
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: EditorialTheme.accent,
                                ),
                              ),
                              Text(
                                gameState.draftTitle,
                                style: EditorialTheme.getEditorialFont(
                                  fontId: gameState.activeFontId,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: Text(
                            "Continuar",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                RepaintBoundary(
                  child: InkWell(
                    onTap: () {
                      gameState.startDailyChallenge();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: gameState.isDailyCompletedToday
                            ? const Color(0xFFEFF5F1)
                            : EditorialTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: gameState.isDailyCompletedToday
                              ? EditorialTheme.success
                              : EditorialTheme.primary,
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: gameState.isDailyCompletedToday
                                              ? EditorialTheme.surface
                                              : EditorialTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "+200 🪙",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: EditorialTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Crucigrama del Día",
                                  style: EditorialTheme.getEditorialFont(
                                    fontId: gameState.activeFontId,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: gameState.isDailyCompletedToday
                                  ? EditorialTheme.success
                                  : EditorialTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              gameState.isDailyCompletedToday ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              color: EditorialTheme.surface,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // 4. Quick Difficulty Selector
              Row(
                children: [
                  Expanded(
                    child: _buildQuickDifficultyCard(
                      context,
                      gameState,
                      title: "Fácil",
                      wordsCount: 6,
                      difficultyFilter: "facil",
                      reward: 50,
                      color: EditorialTheme.success,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildQuickDifficultyCard(
                      context,
                      gameState,
                      title: "Medio",
                      wordsCount: 9,
                      difficultyFilter: "medio",
                      reward: 100,
                      color: EditorialTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildQuickDifficultyCard(
                      context,
                      gameState,
                      title: "Experto",
                      wordsCount: 13,
                      difficultyFilter: "avanzado",
                      reward: 200,
                      color: EditorialTheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 5. Section Header & Horizontal Theme Carousel
              Text(
                "DOSSIERS TEMÁTICOS",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    return SizedBox(
                      width: 150,
                      child: _buildCategoryCard(context, gameState, cat),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 6. Navigation Shortcuts (Dictionary, Quiosco, Custom Generator)
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryCard(
                      context,
                      icon: Icons.auto_stories,
                      title: "Diccionario",
                      subtitle: "Léxico",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const DictionaryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSecondaryCard(
                      context,
                      icon: Icons.storefront,
                      title: "Quiosco",
                      subtitle: "Tienda",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ShopScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSecondaryCard(
                      context,
                      icon: Icons.tune,
                      title: "Generador",
                      subtitle: "A medida",
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

  Widget _buildQuickDifficultyCard(
    BuildContext context,
    GameStateProvider gameState, {
    required String title,
    required int wordsCount,
    required String difficultyFilter,
    required int reward,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        gameState.startNewLevel(
          title: "Crucigrama $title",
          category: "Todos",
          targetWordsCount: wordsCount,
          difficultyFilter: difficultyFilter,
          reward: reward,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: EditorialTheme.newspaperCardDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "$wordsCount palabras",
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, size: 12, color: EditorialTheme.accent),
                const SizedBox(width: 2),
                Text(
                  "+$reward",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: EditorialTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildCategoryCard(BuildContext context, GameStateProvider gameState, String category) {
    IconData iconData = Icons.article;
    if (category.contains("Historia")) iconData = Icons.account_balance;
    if (category.contains("Ciencia")) iconData = Icons.science;
    if (category.contains("Arte")) iconData = Icons.palette;
    if (category.contains("Filosofía")) iconData = Icons.psychology;
    if (category.contains("Naturaleza")) iconData = Icons.park;
    if (category.contains("Gastronomía")) iconData = Icons.restaurant;
    if (category.contains("Cine")) iconData = Icons.movie;
    if (category.contains("Tecnología")) iconData = Icons.memory;
    if (category.contains("Lenguaje")) iconData = Icons.spellcheck;
    if (category.contains("Cultura")) iconData = Icons.public;

    return InkWell(
      onTap: () {
        gameState.startNewLevel(
          title: "Dossier $category",
          category: category,
          targetWordsCount: 8,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: EditorialTheme.newspaperCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(iconData, color: EditorialTheme.primary, size: 22),
                const Icon(Icons.arrow_forward_ios, size: 12, color: EditorialTheme.borderLine),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
                Text(
                  "Generar Crucigrama",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: EditorialTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

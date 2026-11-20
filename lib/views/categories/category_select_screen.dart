import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/dictionary_repository.dart';
import '../../services/game_state_provider.dart';
import '../../theme/editorial_theme.dart';
import '../game/crossword_game_screen.dart';

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();
    final categories = repo.getCategories().where((c) => c != 'Todos').toList();

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        backgroundColor: EditorialTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, size: 20, color: EditorialTheme.inkDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Temáticas",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: EditorialTheme.inkDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: EditorialTheme.borderLine),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "EDICIÓN RÁPIDA",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Elige dificultad",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Unified open 3-column ruled strip instead of 3 heavy boxes
              Container(
                decoration: BoxDecoration(
                  color: EditorialTheme.surface,
                  border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildQuickDifficultyCard(
                          context,
                          gameState,
                          title: "Fácil",
                          wordsCount: 6,
                          difficultyFilter: "facil",
                          reward: 50,
                          color: EditorialTheme.secondary,
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 0.8, color: EditorialTheme.borderLine),
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
                      const VerticalDivider(width: 1, thickness: 0.8, color: EditorialTheme.borderLine),
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
                ),
              ),

              const SizedBox(height: 26),
              Container(height: 0.8, color: EditorialTheme.borderLine),
              const SizedBox(height: 20),

              Text(
                "SUPLEMENTOS",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ediciones por temática",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.38,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return _buildCategoryCard(context, gameState, cat);
                },
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
        );
      },
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "$wordsCount palabras",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: EditorialTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "+$reward mon.",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: EditorialTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    GameStateProvider gameState,
    String categoryName,
  ) {
    String imageName = "dossier_literatura.png";
    if (categoryName.contains("Historia") || categoryName.contains("Derecho")) imageName = "dossier_historia.png";
    if (categoryName.contains("Ciencia") || categoryName.contains("Astronomía") || categoryName.contains("Medicina")) imageName = "dossier_ciencia.png";
    if (categoryName.contains("Arte")) imageName = "dossier_arte.png";
    if (categoryName.contains("Geografía")) imageName = "dossier_geografia.png";
    if (categoryName.contains("Tecnología")) imageName = "dossier_tecnologia.png";
    if (categoryName.contains("Filosofía") || categoryName.contains("Psicología")) imageName = "dossier_filosofia.png";
    if (categoryName.contains("Entretenimiento") || categoryName.contains("Cine") || categoryName.contains("Teatro") || categoryName.contains("Música")) imageName = "dossier_entretenimiento.png";
    if (categoryName.contains("Literatura") || categoryName.contains("Lenguaje") || categoryName.contains("Comunicación")) imageName = "dossier_literatura.png";

    return InkWell(
      onTap: () {
        gameState.startNewLevel(
          title: "Temática: $categoryName",
          category: categoryName,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
        );
      },
      borderRadius: BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: EditorialTheme.newspaperCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Image.asset(
                    "assets/images/$imageName",
                    fit: BoxFit.contain,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_sharp,
                  size: 14,
                  color: EditorialTheme.textSecondary,
                ),
              ],
            ),
            Text(
              categoryName,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.inkDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

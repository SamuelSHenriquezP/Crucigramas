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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "TEMÁTICAS",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "NIVEL RÁPIDO",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Selecciona la dificultad de tu crucigrama",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

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
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
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

              const SizedBox(height: 28),

              Text(
                "EDICIONES POR TEMÁTICA",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Explora áreas de conocimiento especializadas",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.35,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: EditorialTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$wordsCount Palabras",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: EditorialTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "+$reward 🪙",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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
    if (categoryName.contains("Historia")) imageName = "dossier_historia.png";
    if (categoryName.contains("Ciencia")) imageName = "dossier_ciencia.png";
    if (categoryName.contains("Arte")) imageName = "dossier_arte.png";
    if (categoryName.contains("Geografía")) imageName = "dossier_geografia.png";
    if (categoryName.contains("Tecnología")) imageName = "dossier_tecnologia.png";
    if (categoryName.contains("Filosofía")) imageName = "dossier_filosofia.png";
    if (categoryName.contains("Entretenimiento")) imageName = "dossier_entretenimiento.png";
    if (categoryName.contains("Literatura")) imageName = "dossier_literatura.png";

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
      borderRadius: BorderRadius.circular(8),
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
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: EditorialTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: EditorialTheme.borderLine, width: 1.0),
                  ),
                  child: Image.asset(
                    "assets/images/$imageName",
                    fit: BoxFit.contain,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: EditorialTheme.primary),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: EditorialTheme.getEditorialFont(
                    fontId: gameState.activeFontId,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Temática Especial",
                  style: GoogleFonts.inter(
                    fontSize: 10,
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
}

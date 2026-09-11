import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/completed_edition.dart';
import '../../services/game_state_provider.dart';
import '../../theme/editorial_theme.dart';
import '../game/crossword_game_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final history = gameState.completedHistory;

    int totalWords = 0;
    int totalSeconds = 0;
    for (final item in history) {
      totalWords += item.wordsCount;
      totalSeconds += item.elapsedSeconds;
    }

    final totalHours = totalSeconds ~/ 3600;
    final remainingMinutes = (totalSeconds % 3600) ~/ 60;
    final timeDisplay = totalHours > 0
        ? "${totalHours}h ${remainingMinutes}m"
        : "${remainingMinutes}m ${totalSeconds % 60}s";

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "LA HEMEROTECA",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: EditorialTheme.textPrimary,
              ),
            ),
            Text(
              "ARCHIVO HISTÓRICO DE EDICIONES RESUELTAS",
              style: GoogleFonts.cinzel(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: EditorialTheme.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 22),
              tooltip: "Limpiar Hemeroteca",
              onPressed: () => _confirmClearHistory(context, gameState),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState(context, gameState)
          : CustomScrollView(
              slivers: [
                // Top Summary Header Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: EditorialTheme.newspaperCardDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            icon: Icons.history_edu,
                            color: EditorialTheme.primary,
                            value: "${history.length}",
                            label: "Ediciones",
                          ),
                          Container(height: 30, width: 1, color: EditorialTheme.borderLine),
                          _buildStatColumn(
                            icon: Icons.spellcheck,
                            color: EditorialTheme.secondary,
                            value: "$totalWords",
                            label: "Palabras",
                          ),
                          Container(height: 30, width: 1, color: EditorialTheme.borderLine),
                          _buildStatColumn(
                            icon: Icons.timer_outlined,
                            color: EditorialTheme.accent,
                            value: timeDisplay,
                            label: "Tiempo Total",
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0),
                  ),
                ),

                // Section Label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, size: 16, color: EditorialTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "REGISTRO DE EJEMPLARES (${history.length})",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: EditorialTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final edition = history[index];
                        return _buildHistoryCard(context, gameState, edition, index);
                      },
                      childCount: history.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: EditorialTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: EditorialTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, GameStateProvider gameState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: EditorialTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: EditorialTheme.borderLine, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_library_outlined,
                size: 64,
                color: EditorialTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Hemeroteca sin Archivos",
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Aún no has completado ninguna edición del periódico. ¡Cada crucigrama resuelto quedará archivado aquí para que puedas consultar sus soluciones cuando gustes!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: EditorialTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await gameState.startTutorialLevel();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                  );
                }
              },
              icon: const Icon(Icons.school, size: 18),
              label: const Text("Jugar Tutorial (PALABRA)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    GameStateProvider gameState,
    CompletedEdition edition,
    int index,
  ) {
    final isTutorial = edition.category == 'Tutorial';
    final isDaily = edition.title.contains('Día');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: EditorialTheme.borderLine, width: 1),
      ),
      color: EditorialTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Category Badge + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isTutorial
                        ? EditorialTheme.secondary.withValues(alpha: 0.15)
                        : (isDaily
                            ? EditorialTheme.accent.withValues(alpha: 0.2)
                            : EditorialTheme.borderLine.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isTutorial
                          ? EditorialTheme.secondary
                          : (isDaily ? EditorialTheme.accent : EditorialTheme.borderLine),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTutorial
                            ? Icons.school
                            : (isDaily ? Icons.stars : Icons.label_outline),
                        size: 11,
                        color: isTutorial
                            ? EditorialTheme.secondary
                            : (isDaily ? EditorialTheme.accent : EditorialTheme.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        edition.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isTutorial
                              ? EditorialTheme.secondary
                              : (isDaily ? EditorialTheme.accent : EditorialTheme.textPrimary),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 12, color: EditorialTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      edition.formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: EditorialTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              edition.title,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Metrics row: Duration, Words count, Reward
            Row(
              children: [
                _buildCardPill(
                  icon: Icons.timer,
                  text: edition.formattedDuration,
                ),
                const SizedBox(width: 8),
                _buildCardPill(
                  icon: Icons.spellcheck,
                  text: "${edition.wordsCount} palabras",
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EditorialTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: EditorialTheme.accent, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        "+${edition.coinsEarned}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (edition.boardData != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: EditorialTheme.borderLine),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    gameState.loadBoardFromHistory(edition);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16, color: EditorialTheme.primary),
                  label: Text(
                    "Revisar Tablero Completo",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (index * 40).ms);
  }

  Widget _buildCardPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: EditorialTheme.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: EditorialTheme.borderLine, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: EditorialTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: EditorialTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "¿Vaciar Hemeroteca?",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Se eliminará el archivo de crucigramas completados. Las monedas y estadísticas acumuladas se conservarán.",
          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              gameState.clearCompletedHistory();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EditorialTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Vaciar"),
          ),
        ],
      ),
    );
  }
}

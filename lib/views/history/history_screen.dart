import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/completed_edition.dart';
import '../../services/game_state_provider.dart';
import '../../theme/editorial_theme.dart';
import '../game/crossword_game_screen.dart';

class HistoryScreen extends StatelessWidget {
  final bool embedded;

  const HistoryScreen({super.key, this.embedded = false});

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

    final bodyContent = history.isEmpty
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
                  ).animate().fadeIn(duration: 280.ms).slideY(begin: -0.04, end: 0),
                ),
              ),

              // Section Label + Clear action
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 14, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, size: 15, color: EditorialTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "REGISTRO DE EJEMPLARES (${history.length})",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: EditorialTheme.textSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 19, color: EditorialTheme.textSecondary),
                        tooltip: "Limpiar Hemeroteca",
                        onPressed: () => _confirmClearHistory(context, gameState),
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
            );

    if (embedded) return bodyContent;

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
          "Hemeroteca",
          style: GoogleFonts.libreBaskerville(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EditorialTheme.inkDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: EditorialTheme.borderLine),
        ),
      ),
      body: bodyContent,
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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_library_outlined,
              size: 42,
              color: EditorialTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Hemeroteca sin Archivos",
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: EditorialTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Cada crucigrama resuelto quedará guardado aquí para que puedas consultarlo en modo lectura.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: EditorialTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () async {
                await gameState.startTutorialLevel();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                  );
                }
              },
              child: const Text("JUGAR TUTORIAL (PALABRA)"),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: EditorialTheme.newspaperCardDecoration,
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
                        ? EditorialTheme.secondary.withValues(alpha: 0.12)
                        : (isDaily
                            ? EditorialTheme.accent.withValues(alpha: 0.16)
                            : EditorialTheme.background),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      color: isTutorial
                          ? EditorialTheme.secondary
                          : (isDaily ? EditorialTheme.accent : EditorialTheme.inkDark),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTutorial
                            ? Icons.school_outlined
                            : (isDaily ? Icons.stars_sharp : Icons.label_outline),
                        size: 11,
                        color: isTutorial
                            ? EditorialTheme.secondary
                            : (isDaily ? EditorialTheme.accent : EditorialTheme.inkDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        edition.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isTutorial
                              ? EditorialTheme.secondary
                              : (isDaily ? EditorialTheme.accent : EditorialTheme.inkDark),
                          letterSpacing: 0.7,
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
            const SizedBox(height: 10),

            // Title
            Text(
              edition.title,
              style: EditorialTheme.getEditorialFont(
                fontId: gameState.activeFontId,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.inkDark,
              ),
            ),
            const SizedBox(height: 10),

            // Metrics row: Duration, Words count, Reward
            Row(
              children: [
                _buildCardPill(
                  icon: Icons.timer_outlined,
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
                    color: EditorialTheme.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: EditorialTheme.accent, width: 0.9),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined, color: EditorialTheme.accent, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        "+${edition.coinsEarned}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: EditorialTheme.inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (edition.boardData != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: EditorialTheme.borderLine),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    gameState.loadBoardFromHistory(edition);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: EditorialTheme.background,
                      border: Border.all(color: EditorialTheme.inkDark, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_outlined, size: 14, color: EditorialTheme.inkDark),
                        const SizedBox(width: 6),
                        Text(
                          "REVISAR TABLERO",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: EditorialTheme.inkDark,
                          ),
                        ),
                      ],
                    ),
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
        borderRadius: BorderRadius.zero,
        border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
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
              fontWeight: FontWeight.w600,
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

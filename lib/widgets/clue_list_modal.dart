import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/crossword_board.dart';
import '../models/crossword_cell.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';

class ClueListModal extends StatefulWidget {
  final CrosswordBoard board;

  const ClueListModal({super.key, required this.board});

  @override
  State<ClueListModal> createState() => _ClueListModalState();
}

class _ClueListModalState extends State<ClueListModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: EditorialTheme.primary, width: 3),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: EditorialTheme.borderLine,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ÍNDICE DE PISTAS",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: EditorialTheme.primary),
                ),
              ],
            ),
          ),

          // Tab Bar Across / Down
          TabBar(
            controller: _tabController,
            indicatorColor: EditorialTheme.accent,
            indicatorWeight: 3,
            labelColor: EditorialTheme.primary,
            unselectedLabelColor: EditorialTheme.textSecondary,
            labelStyle: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "HORIZONTALES"),
              Tab(text: "VERTICALES"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClueList(widget.board.acrossWords, gameState),
                _buildClueList(widget.board.downWords, gameState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClueList(List<PlacedWord> words, GameStateProvider gameState) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          "Sin pistas disponibles",
          style: GoogleFonts.inter(color: EditorialTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: words.length,
      separatorBuilder: (ctx, i) => const Divider(color: EditorialTheme.borderLine, height: 1),
      itemBuilder: (ctx, i) {
        final pw = words[i];

        // Check if word is fully solved
        bool isSolved = true;
        for (int k = 0; k < pw.word.length; k++) {
          int r = pw.isAcross ? pw.startRow : pw.startRow + k;
          int c = pw.isAcross ? pw.startCol + k : pw.startCol;
          final cell = widget.board.grid[r][c];
          if (!cell.isCorrect) {
            isSolved = false;
            break;
          }
        }

        return ListTile(
          onTap: () {
            gameState.selectCell(pw.startRow, pw.startCol);
            if (gameState.isAcrossFocus != pw.isAcross) {
              gameState.selectCell(pw.startRow, pw.startCol);
            }
            Navigator.pop(context);
          },
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSolved ? EditorialTheme.success : EditorialTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${pw.number}",
              style: GoogleFonts.playfairDisplay(
                color: EditorialTheme.surface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            pw.clue,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSolved ? EditorialTheme.success : EditorialTheme.textPrimary,
              decoration: isSolved ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            "${pw.word.length} letras • ${pw.category}",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: EditorialTheme.textSecondary,
            ),
          ),
          trailing: isSolved
              ? const Icon(Icons.check_circle, color: EditorialTheme.success, size: 20)
              : const Icon(Icons.chevron_right, color: EditorialTheme.borderLine, size: 20),
        );
      },
    );
  }
}

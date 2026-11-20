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
      height: MediaQuery.of(context).size.height * 0.76,
      decoration: const BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(color: EditorialTheme.inkDark, width: 2.5),
          left: BorderSide(color: EditorialTheme.inkDark, width: 1.2),
          right: BorderSide(color: EditorialTheme.inkDark, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SUPLEMENTO DE PISTAS",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: EditorialTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "ÍNDICE DE DEFINICIONES",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: EditorialTheme.inkDark),
                  ),
                ],
              ),
            ),

            EditorialTheme.doubleRule(margin: const EdgeInsets.symmetric(horizontal: 18)),

            TabBar(
              controller: _tabController,
              indicatorColor: EditorialTheme.inkDark,
              indicatorWeight: 2.5,
              labelColor: EditorialTheme.inkDark,
              unselectedLabelColor: EditorialTheme.textSecondary,
              dividerColor: EditorialTheme.borderLine,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                fontSize: 12,
              ),
              tabs: [
                Tab(text: "HORIZONTALES (${widget.board.acrossWords.length})"),
                Tab(text: "VERTICALES (${widget.board.downWords.length})"),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: words.length,
      separatorBuilder: (ctx, i) => const Divider(color: EditorialTheme.borderLine, height: 1),
      itemBuilder: (ctx, i) {
        final pw = words[i];

        bool isSolved = true;
        for (int k = 0; k < pw.word.length; k++) {
          final int r = pw.isAcross ? pw.startRow : pw.startRow + k;
          final int c = pw.isAcross ? pw.startCol + k : pw.startCol;
          if (!widget.board.grid[r][c].isCorrect) {
            isSolved = false;
            break;
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          onTap: () {
            gameState.selectCell(pw.startRow, pw.startCol);
            if (gameState.isAcrossFocus != pw.isAcross) {
              gameState.selectCell(pw.startRow, pw.startCol);
            }
            Navigator.pop(context);
          },
          leading: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSolved ? EditorialTheme.success : EditorialTheme.primary,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: EditorialTheme.inkDark, width: 1.0),
            ),
            child: Text(
              "${pw.number}",
              style: GoogleFonts.playfairDisplay(
                color: EditorialTheme.surface,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
          title: Text(
            pw.clue,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isSolved ? EditorialTheme.success : EditorialTheme.textPrimary,
              decoration: isSolved ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            "${pw.word.length} LETRAS  ·  ${pw.category.toUpperCase()}",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: EditorialTheme.textSecondary,
            ),
          ),
          trailing: Icon(
            isSolved ? Icons.check_box : Icons.arrow_forward_sharp,
            color: isSolved ? EditorialTheme.success : EditorialTheme.textSecondary,
            size: 18,
          ),
        );
      },
    );
  }
}

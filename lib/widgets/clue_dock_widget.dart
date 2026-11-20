import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import 'clue_list_modal.dart';

class ClueDockWidget extends StatefulWidget {
  const ClueDockWidget({super.key});

  @override
  State<ClueDockWidget> createState() => _ClueDockWidgetState();
}

class _ClueDockWidgetState extends State<ClueDockWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final focusedWord = gameState.currentFocusedWord;

    final directionText = gameState.isAcrossFocus ? "HORIZONTAL" : "VERTICAL";
    final wordLengthText = focusedWord != null ? "${focusedWord.word.length} LETRAS" : "";
    final clueText = focusedWord != null ? focusedWord.clue : "Toca una casilla para ver su definición";

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 12.0, 11.0),
      decoration: const BoxDecoration(
        color: EditorialTheme.surface,
        border: Border(
          top: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
          bottom: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Compact ink clue index badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                color: EditorialTheme.primary,
                child: Text(
                  focusedWord != null
                      ? "${focusedWord.number}${gameState.isAcrossFocus ? 'H' : 'V'}"
                      : "—",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: EditorialTheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  wordLengthText.isNotEmpty
                      ? "$directionText  ·  $wordLengthText"
                      : directionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: EditorialTheme.textSecondary,
                  ),
                ),
              ),

              _MinimalNavButton(
                icon: Icons.chevron_left,
                onTap: () => gameState.selectPreviousWord(),
              ),
              const SizedBox(width: 4),
              _MinimalNavButton(
                icon: Icons.chevron_right,
                onTap: () => gameState.selectNextWord(),
              ),
              const SizedBox(width: 6),
              _MinimalNavButton(
                icon: Icons.format_list_bulleted,
                iconColor: EditorialTheme.surface,
                bgColor: EditorialTheme.inkDark,
                borderColor: EditorialTheme.inkDark,
                onTap: () {
                  if (gameState.currentBoard != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => ClueListModal(board: gameState.currentBoard!),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 210),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
              child: Align(
                key: ValueKey("clue_${focusedWord?.number}_${focusedWord?.isAcross}"),
                alignment: Alignment.centerLeft,
                child: Text(
                  clueText,
                  maxLines: _isExpanded ? 6 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: EditorialTheme.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  const _MinimalNavButton({
    required this.icon,
    required this.onTap,
    this.iconColor = EditorialTheme.inkDark,
    this.bgColor = EditorialTheme.background,
    this.borderColor = EditorialTheme.borderLine,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 0.9),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
      ),
    );
  }
}

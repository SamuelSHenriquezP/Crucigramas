import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';

class EditorialKeyboard extends StatelessWidget {
  const EditorialKeyboard({super.key});

  static const List<List<String>> _keys = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      decoration: const BoxDecoration(
        color: EditorialTheme.background,
        border: Border(
          top: BorderSide(color: EditorialTheme.borderLine, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isDel = key == 'DEL';
                return Expanded(
                  flex: isDel ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isDel) {
                            gameState.onBackspace();
                          } else {
                            gameState.onKeyInput(key);
                          }
                        },
                        borderRadius: BorderRadius.circular(5.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDel ? EditorialTheme.primary : EditorialTheme.surface,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: isDel
                                  ? EditorialTheme.primary
                                  : EditorialTheme.borderLine,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: EditorialTheme.textPrimary.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: isDel
                              ? const Icon(
                                  Icons.backspace_outlined,
                                  color: EditorialTheme.surface,
                                  size: 18,
                                )
                              : Text(
                                  key,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: EditorialTheme.textPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

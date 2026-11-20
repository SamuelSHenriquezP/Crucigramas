import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      padding: const EdgeInsets.fromLTRB(6.0, 7.0, 6.0, 10.0),
      color: const Color(0xFFF1F1F1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: gameState.clearCurrentWord,
                icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                label: const Text('Borrar palabra'),
              ),
              if (context.watch<GameStateProvider>().hasFreeDailyHintToday)
                TextButton.icon(
                  onPressed: () => gameState.useFreeDailyHint(),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                  label: const Text('Pista gratis'),
                ),
            ],
          ),
          ..._keys.map((row) {
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
                      child: _TactileKeyButton(
                        label: key,
                        isDel: isDel,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (isDel) {
                            gameState.onBackspace();
                          } else {
                            gameState.onKeyInput(key);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TactileKeyButton extends StatefulWidget {
  final String label;
  final bool isDel;
  final VoidCallback onTap;

  const _TactileKeyButton({
    required this.label,
    required this.isDel,
    required this.onTap,
  });

  @override
  State<_TactileKeyButton> createState() => _TactileKeyButtonState();
}

class _TactileKeyButtonState extends State<_TactileKeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDel = widget.isDel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 65),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          height: 49,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDel
                ? (_isPressed ? EditorialTheme.inkDark : EditorialTheme.primary)
                : (_isPressed
                      ? EditorialTheme.cellFocused
                      : EditorialTheme.surface),
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(
              color: isDel ? EditorialTheme.primary : const Color(0xFFD5D5D5),
              width: 0.9,
            ),
          ),
          child: isDel
              ? const Icon(
                  Icons.backspace_outlined,
                  color: EditorialTheme.surface,
                  size: 20,
                )
              : Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

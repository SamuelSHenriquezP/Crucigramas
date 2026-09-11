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
      padding: const EdgeInsets.fromLTRB(4.0, 6.0, 4.0, 8.0),
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
            padding: const EdgeInsets.symmetric(vertical: 3.0),
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
        }).toList(),
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
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 52, // Altura ampliada para mayor comodidad táctil al escribir
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDel
                ? (_isPressed ? const Color(0xFF0F323E) : EditorialTheme.primary)
                : (_isPressed ? const Color(0xFFEDE8DD) : Colors.white),
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(
              color: isDel
                  ? EditorialTheme.primary
                  : const Color(0xFFD4CEBF),
              width: 1.2,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 2.0,
                      offset: const Offset(0, 1.8),
                    ),
                  ],
          ),
          child: isDel
              ? const Icon(
                  Icons.backspace_outlined,
                  color: EditorialTheme.surface,
                  size: 21,
                )
              : Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

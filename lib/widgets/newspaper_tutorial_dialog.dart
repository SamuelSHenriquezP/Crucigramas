import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';
import '../views/game/crossword_game_screen.dart';

class NewspaperTutorialDialog extends StatelessWidget {
  const NewspaperTutorialDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const NewspaperTutorialDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: const BoxDecoration(
          color: EditorialTheme.surface,
          border: Border(
            top: BorderSide(color: EditorialTheme.inkDark, width: 2.5),
            left: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
            right: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
            bottom: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
          ),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Broadsheet Supplement Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "GUÍA DE LECTURA",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: EditorialTheme.accent,
                          ),
                        ),
                        Text(
                          "REGLAS",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: EditorialTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 0.8, color: EditorialTheme.borderLine),
                    const SizedBox(height: 12),
                    Text(
                      "Manual del Crucigramista",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: EditorialTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Indicaciones básicas para resolver cada edición",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: EditorialTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 0.8,
                color: EditorialTheme.borderLine,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              // Scrollable Rules
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _buildRuleItem(
                        number: "I.",
                        title: "Selección y Orientación",
                        description:
                            "Toca cualquier casilla para enfocarla. Si pertenece a dos palabras cruzadas, vuelve a tocarla para alternar entre Horizontal y Vertical.",
                      ),
                      const Divider(height: 22, color: EditorialTheme.borderLine),
                      _buildRuleItem(
                        number: "II.",
                        title: "Escritura Directa",
                        description:
                            "Teclea con el teclado inferior. El cursor avanza automáticamente a la siguiente casilla libre dentro de la palabra activa.",
                      ),
                      const Divider(height: 22, color: EditorialTheme.borderLine),
                      _buildRuleItem(
                        number: "III.",
                        title: "Zoom y Encuadre",
                        description:
                            "Pellizca con dos dedos para acercar tableros grandes y arrastra para desplazarte. Usa el botón 'CENTRAR' para volver al encuadre inicial.",
                      ),
                      const Divider(height: 22, color: EditorialTheme.borderLine),
                      _buildRuleItem(
                        number: "IV.",
                        title: "Pistas y Comprobación",
                        description:
                            "Desde la bombilla superior puedes revelar una letra (35 mon.), revelar la palabra completa (80 mon.) o comprobar errores (25 mon.).",
                      ),
                      const Divider(height: 22, color: EditorialTheme.borderLine),
                      _buildRuleItem(
                        number: "V.",
                        title: "Diccionario y Quiosco",
                        description:
                            "Cada vocablo resuelto se archiva en tu Diccionario editorial. Visita el Quiosco para desbloquear tipografías, estilos y credenciales.",
                      ),
                    ],
                  ),
                ),
              ),

              // Clean Footer Action
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: EditorialTheme.background,
                  border: Border(
                    top: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final gameState = Provider.of<GameStateProvider>(context, listen: false);
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          await gameState.startTutorialLevel();
                          navigator.push(
                            MaterialPageRoute(builder: (ctx) => const CrosswordGameScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EditorialTheme.inkDark,
                          side: const BorderSide(color: EditorialTheme.inkDark, width: 1.0),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          "PRÁCTICA",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EditorialTheme.inkDark,
                          foregroundColor: EditorialTheme.surface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          "ENTENDIDO",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildRuleItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          child: Text(
            number,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: EditorialTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: EditorialTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/editorial_theme.dart';

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0), // Pure warm newsprint
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EditorialTheme.textPrimary, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Newspaper Masthead Bar
            Container(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: EditorialTheme.textPrimary, width: 2.0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SUPLEMENTO EDUCATIVO",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: EditorialTheme.accent,
                        ),
                      ),
                      Text(
                        "EDICIÓN ORDINARIA",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: EditorialTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1, color: EditorialTheme.borderLine),
                  const SizedBox(height: 6),
                  Text(
                    "MANUAL DEL CRUCIGRAMISTA",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Guía fundamental para la resolución metódica de crucigramas",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: EditorialTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(height: 1, color: EditorialTheme.textPrimary),
                ],
              ),
            ),

            // Scrollable Instructional Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  children: [
                    _buildRuleItem(
                      number: "I",
                      icon: Icons.touch_app_outlined,
                      title: "Selección & Orientación",
                      description:
                          "Toca cualquier casilla para seleccionarla. Si la casilla forma una intersección de dos palabras, vuelve a tocarla para alternar entre Horizontal y Vertical.",
                    ),
                    const SizedBox(height: 12),
                    _buildRuleItem(
                      number: "II",
                      icon: Icons.keyboard_outlined,
                      title: "Escritura Inteligente",
                      description:
                          "Escribe directamente con el teclado inferior. El cursor avanzará hacia la siguiente casilla vacía de la palabra en juego sin saltar fuera de ella.",
                    ),
                    const SizedBox(height: 12),
                    _buildRuleItem(
                      number: "III",
                      icon: Icons.zoom_in,
                      title: "Zoom y Paneo Libre",
                      description:
                          "Pellizca con dos dedos para agrandar o alejar el tablero a tu gusto. Desliza para moverte por crucigramas grandes y pulsa el botón flotante 'Centrar' para reencuadrar.",
                    ),
                    const SizedBox(height: 12),
                    _buildRuleItem(
                      number: "IV",
                      icon: Icons.lightbulb_outlined,
                      title: "Pistas & Ayudas",
                      description:
                          "Si te atascas en una palabra, pulsa la bombilla superior para revelar una letra (35 🪙) o la palabra completa (80 🪙). Cada crucigrama resuelto te otorgará más monedas.",
                    ),
                    const SizedBox(height: 12),
                    _buildRuleItem(
                      number: "V",
                      icon: Icons.auto_stories_outlined,
                      title: "Léxico & Quiosco",
                      description:
                          "Cada palabra completada pasará a formar parte de tu Diccionario personal. Visita el Quiosco para desbloquear nuevos estilos de papel y tipografías históricas.",
                    ),
                  ],
                ),
              ),
            ),

            // Footer Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: EditorialTheme.borderLine, width: 1.5),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EditorialTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    "¡ENTENDIDO, A RESOLVER!",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: EditorialTheme.accent.withValues(alpha: 0.18),
            border: Border.all(color: EditorialTheme.accent, width: 1.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            number,
            style: GoogleFonts.cinzel(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: EditorialTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: EditorialTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: EditorialTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

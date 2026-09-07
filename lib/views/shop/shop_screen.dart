import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/shop_item.dart';
import '../../services/ad_manager.dart';
import '../../services/game_state_provider.dart';
import '../../services/iap_service.dart';
import '../../theme/editorial_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static final List<ShopItem> _themes = [
    ShopItem(
      id: 'default_theme',
      title: 'Papel Prensa Clásico',
      description: 'Papel marfil cálido tradicional con tinta carbón profundo de imprenta.',
      price: 0,
      type: ShopItemType.theme,
      iconName: 'newspaper',
      data: {'bg': 0xFFF7F5EF, 'ink': 0xFF202124, 'accent': 0xFFD9A63A},
    ),
    ShopItem(
      id: 'theme_sepia_1920',
      title: 'Edición Sepia 1920',
      description: 'Pátina envejecida de hemeroteca histórica con tonos café y pergamino.',
      price: 250,
      type: ShopItemType.theme,
      iconName: 'history_edu',
      data: {'bg': 0xFFEFE8D8, 'ink': 0xFF3D3226, 'accent': 0xFF9E6B38},
    ),
    ShopItem(
      id: 'theme_botanical_salvia',
      title: 'Salvia & Botánica',
      description: 'Papel verde salvia natural con acentos botánicos de gran elegancia.',
      price: 350,
      type: ShopItemType.theme,
      iconName: 'park',
      data: {'bg': 0xFFEEF3EE, 'ink': 0xFF1E3524, 'accent': 0xFF5B8A62},
    ),
    ShopItem(
      id: 'theme_royal_gold',
      title: 'Papiro Imperial',
      description: 'Edición de lujo con toques de orla dorada y textura de papiro selecto.',
      price: 450,
      type: ShopItemType.theme,
      iconName: 'auto_awesome',
      data: {'bg': 0xFFF9F5EA, 'ink': 0xFF2B261F, 'accent': 0xFFB8860B},
    ),
    ShopItem(
      id: 'theme_dark_ink',
      title: 'Tinta Nocturna',
      description: 'Edición de noche con fondo carbón mate profundo y letras marfil.',
      price: 500,
      type: ShopItemType.theme,
      iconName: 'dark_mode',
      data: {'bg': 0xFF1E2124, 'ink': 0xFFF5F3ED, 'accent': 0xFFE5B54F},
    ),
    ShopItem(
      id: 'theme_cyber_press',
      title: 'Tinta Cyber-Prensa',
      description: 'Contraste futurista con trazos cian y tipografía de alto impacto.',
      price: 600,
      type: ShopItemType.theme,
      iconName: 'bolt',
      data: {'bg': 0xFF0F172A, 'ink': 0xFF38BDF8, 'accent': 0xFFA855F7},
    ),
  ];

  static final List<ShopItem> _fonts = [
    ShopItem(
      id: 'font_playfair',
      title: 'Playfair Display',
      description: 'Clásica serif de titulares nobles y gran prestancia periodística.',
      price: 0,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_cinzel',
      title: 'Cinzel Romana',
      description: 'Inspirada en las inscripciones monumentales del Imperio Romano.',
      price: 250,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_lora',
      title: 'Lora Poética',
      description: 'Trazos suaves y equilibrados concebidos para la lectura literaria.',
      price: 300,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_merriweather',
      title: 'Merriweather',
      description: 'Diseño robusto y nítido para páginas editoriales y columnas densas.',
      price: 350,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_roboto_slab',
      title: 'Roboto Slab',
      description: 'Tipografía de bloque inspirada en las máquinas de imprenta del siglo XX.',
      price: 400,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
  ];

  static final List<ShopItem> _dossiers = [
    ShopItem(
      id: 'dossier_mitologia',
      title: 'Mitología Clásica',
      description: 'Panteón griego, héroes homéricos y leyendas de la antigüedad.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'fort',
      assetPath: 'assets/images/dossier_filosofia.png',
    ),
    ShopItem(
      id: 'dossier_filosofia',
      title: 'Filosofía & Mente',
      description: 'Grandes pensadores, dilemas éticos y corrientes del intelecto.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'psychology',
      assetPath: 'assets/images/dossier_filosofia.png',
    ),
    ShopItem(
      id: 'dossier_ciencia_cuantica',
      title: 'Ciencia & Cosmos',
      description: 'Física cuántica, astronomía estelar y fórmulas del universo.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'science',
      assetPath: 'assets/images/dossier_ciencia.png',
    ),
    ShopItem(
      id: 'dossier_gastronomia_mundo',
      title: 'Gastronomía & Sabores',
      description: 'Alta cocina, ingredientes del mundo y técnicas culinarias.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'restaurant',
      assetPath: 'assets/images/dossier_arte.png',
    ),
    ShopItem(
      id: 'dossier_cine_opera',
      title: 'Cine de Culto & Ópera',
      description: 'Obras maestras de la cinematografía, escenografía y lírica.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'movie',
      assetPath: 'assets/images/dossier_entretenimiento.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "EL QUIOSCO EDITORIAL",
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: EditorialTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EditorialTheme.accent, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: EditorialTheme.accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${gameState.coins}",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          children: [
            // 1. Newspaper Supplement Masthead Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: EditorialTheme.newspaperCardDecoration,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SUPLEMENTO ILUSTRADO",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: EditorialTheme.accent,
                          ),
                        ),
                        Text(
                          "QUIOSCO & TALLER",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: EditorialTheme.textSecondary,
                          ),
                        ),
                        Text(
                          "EDICIÓN ESPECIAL",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: EditorialTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1.5, color: EditorialTheme.textPrimary),
                    const SizedBox(height: 8),
                    Text(
                      "GACETA DE LA IMPRENTA",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: EditorialTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Personaliza tu experiencia con tintas clásicas, fuentes históricas y fondos de honor.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: EditorialTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1.5, color: EditorialTheme.textPrimary),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // 2. Patrocinador Editorial (Free Coins Banner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: EditorialTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: EditorialTheme.accent, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: EditorialTheme.accent.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: EditorialTheme.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: EditorialTheme.accent, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PATROCINIO DIARIO",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: EditorialTheme.accent,
                            ),
                          ),
                          Text(
                            "+50 Monedas de la Imprenta",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "Mira un breve patrocinio editorial",
                            style: GoogleFonts.inter(fontSize: 10.5, color: EditorialTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => AdManager.showRewardedAdForCoins(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EditorialTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        "Reclamar",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // 3. CARRUSEL 1: ESTILOS DE PAPEL & TINTA
            _buildSectionHeader(
              sectionNum: "SECCIÓN I",
              title: "ESTILOS DE PAPEL PRENSA",
              subtitle: "Variantes de color y textura para la cuadrícula",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _themes.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = _themes[i];
                  return _buildThemeCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 26),

            // 4. CARRUSEL 2: TIPOGRAFÍAS DE IMPRENTA
            _buildSectionHeader(
              sectionNum: "SECCIÓN II",
              title: "TIPOGRAFÍAS HISTÓRICAS",
              subtitle: "Fuentes clásicas aplicadas a todas las palabras del periódico",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _fonts.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = _fonts[i];
                  return _buildFontCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 26),

            // 5. CARRUSEL 3: DOSSIERS & TEMÁTICAS
            _buildSectionHeader(
              sectionNum: "SECCIÓN III",
              title: "DOSSIERS TEMÁTICOS",
              subtitle: "Áreas de conocimiento y léxico especializado",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dossiers.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = _dossiers[i];
                  return _buildDossierCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 26),

            // 6. CARRUSEL 4: CAUDALES & EDICIÓN VIP
            _buildSectionHeader(
              sectionNum: "SECCIÓN IV",
              title: "CAJA DE FONDOS & SUSCRIPCIÓN VIP",
              subtitle: "Paquetes de monedas y pase de honor 'Redacción de Honor'",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: IapService.storeProducts.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = IapService.storeProducts[i];
                  return _buildIapCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String sectionNum,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: EditorialTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  sectionNum,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: EditorialTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Card for Themes Carousel
  Widget _buildThemeCarouselCard(
    BuildContext context,
    GameStateProvider gameState,
    ShopItem item,
  ) {
    final isUnlocked = gameState.isItemUnlocked(item.id);
    final isEquipped = gameState.activeThemeId == item.id;
    final bgVal = item.data?['bg'] as int? ?? 0xFFF7F5EF;
    final inkVal = item.data?['ink'] as int? ?? 0xFF202124;
    final accVal = item.data?['accent'] as int? ?? 0xFFD9A63A;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEquipped ? EditorialTheme.accent : EditorialTheme.borderLine,
          width: isEquipped ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: EditorialTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme visual swatch bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Color(bgVal),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: EditorialTheme.borderLine),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "EDICIÓN",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Color(inkVal),
                  ),
                ),
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(inkVal), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(accVal), shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: EditorialTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: EditorialTheme.textSecondary,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Action button
          if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EditorialTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: EditorialTheme.accent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 14, color: EditorialTheme.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    "EN USO",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            )
          else if (isUnlocked)
            ElevatedButton(
              onPressed: () => gameState.equipTheme(item.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                "USAR ESTILO",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                if (gameState.coins >= item.price) {
                  gameState.buyShopItem(item.id, item.price);
                  gameState.equipTheme(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: EditorialTheme.success,
                      content: Text("¡Has adquirido ${item.title}!"),
                    ),
                  );
                } else {
                  _showNeedCoinsSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                "${item.price} 🪙 ADQUIRIR",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card for Typography Carousel
  Widget _buildFontCarouselCard(
    BuildContext context,
    GameStateProvider gameState,
    ShopItem item,
  ) {
    final isUnlocked = gameState.isItemUnlocked(item.id);
    final isEquipped = gameState.activeFontId == item.id;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEquipped ? EditorialTheme.accent : EditorialTheme.borderLine,
          width: isEquipped ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: EditorialTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Specimen banner
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: EditorialTheme.background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: EditorialTheme.borderLine),
            ),
            alignment: Alignment.center,
            child: Text(
              "Aa Bb Gg 1928",
              style: EditorialTheme.getEditorialFont(
                fontId: item.id,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: EditorialTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: EditorialTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: EditorialTheme.textSecondary,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EditorialTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: EditorialTheme.accent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 14, color: EditorialTheme.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    "TIPOGRAFÍA ACTIVA",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: EditorialTheme.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            )
          else if (isUnlocked)
            ElevatedButton(
              onPressed: () => gameState.equipFont(item.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                "ACTIVAR FUENTE",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                if (gameState.coins >= item.price) {
                  gameState.buyShopItem(item.id, item.price);
                  gameState.equipFont(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: EditorialTheme.success,
                      content: Text("¡Tipografía ${item.title} adquirida!"),
                    ),
                  );
                } else {
                  _showNeedCoinsSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                "${item.price} 🪙 ADQUIRIR",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card for Dossiers Carousel
  Widget _buildDossierCarouselCard(
    BuildContext context,
    GameStateProvider gameState,
    ShopItem item,
  ) {
    final isUnlocked = gameState.isItemUnlocked(item.id);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: EditorialTheme.newspaperCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: EditorialTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, color: EditorialTheme.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: EditorialTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EditorialTheme.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "✓ DESBLOQUEADO",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.success,
                  letterSpacing: 0.8,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                if (gameState.coins >= item.price) {
                  gameState.buyShopItem(item.id, item.price);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: EditorialTheme.success,
                      content: Text("¡Dossier ${item.title} desbloqueado!"),
                    ),
                  );
                } else {
                  _showNeedCoinsSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                "${item.price} 🪙 DESBLOQUEAR",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card for IAP & VIP Carousel
  Widget _buildIapCarouselCard(
    BuildContext context,
    GameStateProvider gameState,
    IapItem item,
  ) {
    final isVip = item.isVipPackage;
    final isSubscribed = gameState.hasNoAds && isVip;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVip ? EditorialTheme.accent : EditorialTheme.borderLine,
          width: isVip ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isVip ? EditorialTheme.accent : EditorialTheme.textPrimary).withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isVip ? Icons.workspace_premium : Icons.monetization_on,
                color: isVip ? EditorialTheme.accent : EditorialTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isVip ? "MEMBRESÍA DE HONOR" : "FONDO MONETARIO",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isVip ? EditorialTheme.accent : EditorialTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: EditorialTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: EditorialTheme.textSecondary,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isSubscribed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EditorialTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "✓ VIP ACTIVO",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => IapService.processPurchase(context, item),
              style: ElevatedButton.styleFrom(
                backgroundColor: isVip ? EditorialTheme.accent : EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                item.price,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isVip ? EditorialTheme.textPrimary : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void _showNeedCoinsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: EditorialTheme.error,
        content: Text("No tienes suficientes Monedas. ¡Resuelve crucigramas o mira un patrocinio!"),
      ),
    );
  }
}

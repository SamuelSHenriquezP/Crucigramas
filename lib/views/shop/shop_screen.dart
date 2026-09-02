import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/shop_item.dart';
import '../../services/ad_manager.dart';
import '../../services/game_state_provider.dart';
import '../../services/iap_service.dart';
import '../../theme/editorial_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static final List<ShopItem> _shopItems = [
    // Theme Unlocks
    ShopItem(
      id: 'default_theme',
      title: 'Papel Prensa Clásico',
      description: 'El estilo original de periódico en marfil cálido y tinta carbón.',
      price: 0,
      type: ShopItemType.theme,
      iconName: 'newspaper',
    ),
    ShopItem(
      id: 'theme_sepia_1920',
      title: 'Edición Sepia 1920',
      description: 'Papel envejecido de imprenta histórica con tonos sepia y tinta café.',
      price: 250,
      type: ShopItemType.theme,
      iconName: 'history_edu',
    ),
    ShopItem(
      id: 'theme_botanical_salvia',
      title: 'Edición Salvia & Botánica',
      description: 'Papel verde salvia natural con acentos botánicos elegantes.',
      price: 350,
      type: ShopItemType.theme,
      iconName: 'park',
    ),
    ShopItem(
      id: 'theme_royal_gold',
      title: 'Papiro Imperial & Tinta Oro',
      description: 'Edición de lujo con detalles dorados y textura de papiro real.',
      price: 450,
      type: ShopItemType.theme,
      iconName: 'auto_awesome',
    ),
    ShopItem(
      id: 'theme_dark_ink',
      title: 'Tinta Carbón Nocturna',
      description: 'Edición especial de noche con fondo carbón profundo y letras marfil.',
      price: 500,
      type: ShopItemType.theme,
      iconName: 'dark_mode',
    ),
    ShopItem(
      id: 'theme_cyber_press',
      title: 'Tinta Neón Cyber-Prensa',
      description: 'Futurismo editorial con trazos cian y contraste neón.',
      price: 600,
      type: ShopItemType.theme,
      iconName: 'bolt',
    ),

    // Font Unlocks
    ShopItem(
      id: 'font_playfair',
      title: 'Playfair Display (Editorial)',
      description: 'Tipografía serif clásica tradicional del periodismo de alta gama.',
      price: 0,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_cinzel',
      title: 'Cinzel (Romana Imperial)',
      description: 'Inspirada en las inscripciones monumentales del Imperio Romano.',
      price: 250,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_lora',
      title: 'Lora (Poética & Novela)',
      description: 'Curvas suaves pensadas para una lectura literaria placentera.',
      price: 300,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_merriweather',
      title: 'Merriweather (Prensa Tradicional)',
      description: 'Diseñada específicamente para lectura en pantallas y periódicos.',
      price: 350,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_roboto_slab',
      title: 'Roboto Slab (Imprenta Vintage)',
      description: 'Estilo mecánico de imprenta tipográfica del siglo XX.',
      price: 400,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),

    // Temáticas
    ShopItem(
      id: 'dossier_mitologia',
      title: 'Temática Mitología Clásica',
      description: 'Acceso a palabras exclusivas sobre dioses, héroes y leyendas.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'fort',
    ),
    ShopItem(
      id: 'dossier_filosofia',
      title: 'Temática Filosofía & Mente',
      description: 'Crucigramas de gran calibre intelectual sobre el pensamiento humano.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'psychology',
    ),
    ShopItem(
      id: 'dossier_ciencia_cuantica',
      title: 'Temática Ciencia & Física Cuántica',
      description: 'Términos científicos avanzados de física, química y universo.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'science',
    ),
    ShopItem(
      id: 'dossier_gastronomia_mundo',
      title: 'Temática Gastronomía del Mundo',
      description: 'Sabores, técnicas culinarias e ingredientes de alta cocina.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'restaurant',
    ),
    ShopItem(
      id: 'dossier_cine_opera',
      title: 'Temática Cine de Culto & Ópera',
      description: 'Séptimo arte, escenografía y grandes piezas musicales.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'movie',
    ),

    // Powerups & Mechanical Enhancements
    ShopItem(
      id: 'typewriter_sfx',
      title: 'Sonido Máquina Remington',
      description: 'Efecto auditivo y háptico vintage al pulsar cada tecla.',
      price: 200,
      type: ShopItemType.title,
      iconName: 'keyboard',
    ),
    ShopItem(
      id: 'lupa_verdad',
      title: 'Lente del Redactor (Potenciador)',
      description: 'Revelador instantáneo de 3 letras aleatorias del tablero.',
      price: 150,
      type: ShopItemType.title,
      iconName: 'search',
    ),
    ShopItem(
      id: 'badge_redactor_jefe',
      title: 'Sello de Redactor Jefe',
      description: 'Distinción de honor otorgada a los más grandes solucionadores.',
      price: 200,
      type: ShopItemType.title,
      iconName: 'verified',
    ),
    ShopItem(
      id: 'badge_pluma_oro',
      title: 'Pluma de Oro de la Redacción',
      description: 'El máximo reconocimiento periodístico para la colección.',
      price: 600,
      type: ShopItemType.title,
      iconName: 'draw',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        title: Text(
          "QUIOSCO & IMPRENTA",
          style: EditorialTheme.getEditorialFont(
            fontId: gameState.activeFontId,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Coins indicator
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
                  style: EditorialTheme.getEditorialFont(
                    fontId: gameState.activeFontId,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: EditorialTheme.newspaperCardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: EditorialTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront, color: EditorialTheme.surface, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CATÁLOGO DE LA IMPRENTA",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: EditorialTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Canjea tus Monedas",
                            style: EditorialTheme.getEditorialFont(
                              fontId: gameState.activeFontId,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "Desbloquea fuentes tipográficas, temas de papel, compras VIP y monedero.",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: EditorialTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // REWARDED ADS BANNER - "Consigue Monedas Gratis"
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EditorialTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EditorialTheme.accent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: EditorialTheme.accent.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: EditorialTheme.accent, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PATROCINADOR EDITORIAL",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.accent,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            "¡Consigue +50 Monedas Gratis!",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "Mira un breve anuncio patrocinado de 15 segundos",
                            style: GoogleFonts.inter(fontSize: 10, color: EditorialTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => AdManager.showRewardedAdForCoins(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EditorialTheme.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        "Ver Video 🎬",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // IN-APP PURCHASES & VIP SECTION
              _buildSectionHeader("COMPRAS DE LA IMPRENTA & VIP", "Paquetes de monedas y suscripción sin anuncios"),
              const SizedBox(height: 12),
              ...IapService.storeProducts.map((product) {
                return _buildIapCard(context, gameState, product);
              }),

              const SizedBox(height: 24),

              // Section: Themes
              _buildSectionHeader("ESTILOS DE IMPRENTA Y TINTAS", "Personaliza la apariencia visual"),
              const SizedBox(height: 12),
              ..._shopItems.where((i) => i.type == ShopItemType.theme).map((item) {
                return _buildShopItemCard(context, gameState, item);
              }),

              const SizedBox(height: 24),

              // Section: Fonts
              _buildSectionHeader("FUENTES TIPOGRÁFICAS EDITORIALES", "Elige el estilo de letra para tus crucigramas"),
              const SizedBox(height: 12),
              ..._shopItems.where((i) => i.type == ShopItemType.font).map((item) {
                return _buildShopItemCard(context, gameState, item);
              }),

              const SizedBox(height: 24),

              // Section: Temáticas
              _buildSectionHeader("TEMÁTICAS DE EDICIÓN ESPECIAL", "Niveles exclusivos con vocabulario avanzado"),
              const SizedBox(height: 12),
              ..._shopItems.where((i) => i.type == ShopItemType.dossier).map((item) {
                return _buildShopItemCard(context, gameState, item);
              }),

              const SizedBox(height: 24),

              // Section: Badges & Enhancements
              _buildSectionHeader("POTENCIADORES Y RECONOCIMIENTOS", "Mejoras de imprenta e insignias de honor"),
              const SizedBox(height: 12),
              ..._shopItems.where((i) => i.type == ShopItemType.title).map((item) {
                return _buildShopItemCard(context, gameState, item);
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: EditorialTheme.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: EditorialTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildIapCard(BuildContext context, GameStateProvider gameState, IapItem product) {
    final isVipActive = product.isVipPackage && gameState.hasNoAds;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: product.isVipPackage
            ? EditorialTheme.primary.withValues(alpha: 0.05)
            : EditorialTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: product.isVipPackage ? EditorialTheme.accent : EditorialTheme.borderLine,
          width: product.isVipPackage ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: product.isVipPackage
                  ? EditorialTheme.accent.withValues(alpha: 0.2)
                  : EditorialTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              product.isVipPackage ? Icons.workspace_premium : Icons.monetization_on,
              color: product.isVipPackage ? EditorialTheme.accent : EditorialTheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: EditorialTheme.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isVipActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: EditorialTheme.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "SUSCRITO VIP",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.surface,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => IapService.processPurchase(context, product),
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                product.price,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.surface,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopItemCard(BuildContext context, GameStateProvider gameState, ShopItem item) {
    final isUnlocked = gameState.isItemUnlocked(item.id);
    final isEquippedTheme = item.type == ShopItemType.theme && gameState.activeThemeId == item.id;
    final isEquippedFont = item.type == ShopItemType.font && gameState.activeFontId == item.id;
    final isEquipped = isEquippedTheme || isEquippedFont;

    IconData iconData = Icons.palette;
    if (item.iconName == 'history_edu') iconData = Icons.history_edu;
    if (item.iconName == 'park') iconData = Icons.park;
    if (item.iconName == 'auto_awesome') iconData = Icons.auto_awesome;
    if (item.iconName == 'dark_mode') iconData = Icons.dark_mode;
    if (item.iconName == 'bolt') iconData = Icons.bolt;
    if (item.iconName == 'font_download') iconData = Icons.font_download;
    if (item.iconName == 'fort') iconData = Icons.castle;
    if (item.iconName == 'psychology') iconData = Icons.psychology;
    if (item.iconName == 'science') iconData = Icons.science;
    if (item.iconName == 'restaurant') iconData = Icons.restaurant;
    if (item.iconName == 'movie') iconData = Icons.movie;
    if (item.iconName == 'keyboard') iconData = Icons.keyboard;
    if (item.iconName == 'search') iconData = Icons.search;
    if (item.iconName == 'verified') iconData = Icons.verified;
    if (item.iconName == 'draw') iconData = Icons.draw;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: EditorialTheme.newspaperCardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked ? EditorialTheme.primary.withValues(alpha: 0.1) : EditorialTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: EditorialTheme.borderLine),
            ),
            child: Icon(
              iconData,
              color: isUnlocked ? EditorialTheme.primary : EditorialTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: item.type == ShopItemType.font
                      ? EditorialTheme.getEditorialFont(
                          fontId: item.id,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: EditorialTheme.textPrimary,
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: EditorialTheme.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action Button (Buy / Equip / Equipped)
          if (item.type == ShopItemType.theme || item.type == ShopItemType.font) ...[
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: EditorialTheme.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "ACTIVO",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.surface,
                  ),
                ),
              )
            else if (isUnlocked)
              OutlinedButton(
                onPressed: () {
                  if (item.type == ShopItemType.theme) {
                    gameState.equipTheme(item.id);
                  } else {
                    gameState.equipFont(item.id);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  side: const BorderSide(color: EditorialTheme.primary),
                ),
                child: Text(
                  "Usar",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.primary,
                  ),
                ),
              )
            else
              _buildBuyButton(context, gameState, item),
          ] else ...[
            if (isUnlocked)
              const Icon(Icons.check_circle, color: EditorialTheme.success, size: 28)
            else
              _buildBuyButton(context, gameState, item),
          ],
        ],
      ),
    );
  }

  Widget _buildBuyButton(BuildContext context, GameStateProvider gameState, ShopItem item) {
    final canAfford = gameState.coins >= item.price;

    return ElevatedButton(
      onPressed: canAfford
          ? () {
              if (gameState.buyShopItem(item.id, item.price)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: EditorialTheme.success,
                    content: Text(
                      "¡Felicidades! Has desbloqueado '${item.title}'",
                      style: GoogleFonts.inter(color: EditorialTheme.surface),
                    ),
                  ),
                );
              }
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: EditorialTheme.error,
                  content: Text(
                    "Necesitas ${item.price - gameState.coins} monedas más.",
                    style: GoogleFonts.inter(color: EditorialTheme.surface),
                  ),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? EditorialTheme.primary : EditorialTheme.borderLine,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: EditorialTheme.accent, size: 14),
          const SizedBox(width: 4),
          Text(
            "${item.price}",
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: canAfford ? EditorialTheme.surface : EditorialTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

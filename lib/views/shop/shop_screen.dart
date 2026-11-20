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
      id: 'theme_financial_salmon',
      title: 'Salmón Financiero',
      description: 'Edición económica en papel rosado con tinta azul marina de gran prestigio.',
      price: 400,
      type: ShopItemType.theme,
      iconName: 'trending_up',
      data: {'bg': 0xFFFCECE4, 'ink': 0xFF17375E, 'accent': 0xFFC25953},
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
      id: 'theme_pergamino_medieval',
      title: 'Pergamino Medieval',
      description: 'Códice manuscrito con tinta nuez de agallas e iluminación en oro.',
      price: 500,
      type: ShopItemType.theme,
      iconName: 'menu_book',
      data: {'bg': 0xFFF4ECD8, 'ink': 0xFF3B2F23, 'accent': 0xFFC99700},
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
      id: 'theme_nordic_minimal',
      title: 'Minimalismo Ártico',
      description: 'Papel blanco nieve puro con sutiles acentos grafito y azul hielo.',
      price: 350,
      type: ShopItemType.theme,
      iconName: 'ac_unit',
      data: {'bg': 0xFFF8FAFC, 'ink': 0xFF0F172A, 'accent': 0xFF38BDF8},
    ),
    ShopItem(
      id: 'theme_crimson_velvet',
      title: 'Rubí & Terciopelo',
      description: 'Crema aristocrático con tinta borgoña profundo y detalles en oro viejo.',
      price: 550,
      type: ShopItemType.theme,
      iconName: 'diamond',
      data: {'bg': 0xFFFBF7F5, 'ink': 0xFF4A0E17, 'accent': 0xFFD4AF37},
    ),
    ShopItem(
      id: 'theme_emerald_library',
      title: 'Biblioteca Victoriana',
      description: 'Ambiente de encuadernaciones de cuero, verde bosque y apliques de latón.',
      price: 450,
      type: ShopItemType.theme,
      iconName: 'local_library',
      data: {'bg': 0xFFF4F7F4, 'ink': 0xFF0B2E1F, 'accent': 0xFFC29B38},
    ),
    ShopItem(
      id: 'theme_midnight_ocean',
      title: 'Medianoche Oceánica',
      description: 'Azul abisal de altamar con tipografía nácar perlada y destellos celestes.',
      price: 600,
      type: ShopItemType.theme,
      iconName: 'water',
      data: {'bg': 0xFF0B192C, 'ink': 0xFFE0F2FE, 'accent': 0xFF38BDF8},
    ),
    ShopItem(
      id: 'theme_sakura_sumie',
      title: 'Cerezo & Sumi-e',
      description: 'Papel seda japonés con rubor de cerezo y pinceladas de tinta pura.',
      price: 450,
      type: ShopItemType.theme,
      iconName: 'filter_vintage',
      data: {'bg': 0xFFFFF5F7, 'ink': 0xFF262626, 'accent': 0xFFF472B6},
    ),
    ShopItem(
      id: 'theme_coffee_press',
      title: 'Café & Tertulia',
      description: 'Café vienés con notas de avellana, canela y tinta espresso aromática.',
      price: 380,
      type: ShopItemType.theme,
      iconName: 'coffee',
      data: {'bg': 0xFFF7F2EB, 'ink': 0xFF3E2723, 'accent': 0xFFB07D4F},
    ),
    ShopItem(
      id: 'theme_marble_olympus',
      title: 'Mármol Olímpico',
      description: 'Blanco estatuario del Partenón con vetas ceniza y acentos de bronce.',
      price: 550,
      type: ShopItemType.theme,
      iconName: 'account_balance',
      data: {'bg': 0xFFF8F9FA, 'ink': 0xFF1A1A1A, 'accent': 0xFFCD7F32},
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
    ShopItem(
      id: 'font_eb_garamond',
      title: 'EB Garamond',
      description: 'El canon renacentista de las letras humanistas y de la alta imprenta.',
      price: 350,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_cormorant',
      title: 'Cormorant Garamond',
      description: 'Estética aristocrática con remates finos para portadas de revistas de lujo.',
      price: 400,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_baskerville',
      title: 'Libre Baskerville',
      description: 'La cumbre de la imprenta británica del siglo XVIII, sobria y legible.',
      price: 350,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_bodoni',
      title: 'Bodoni Moda',
      description: 'Contraste geométrico y sofisticación italiana de altísimo impacto visual.',
      price: 450,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_courier',
      title: 'Courier Prime',
      description: 'Máquina de escribir auténtica de reporteros de redacción y teletipos.',
      price: 300,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_space_mono',
      title: 'Space Mono',
      description: 'Monospaciado contemporáneo geométrico para ediciones vanguardistas.',
      price: 350,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_alegreya',
      title: 'Alegreya Clásica',
      description: 'Diseñada expresamente para novelas, ensayos y alta literatura.',
      price: 380,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
    ShopItem(
      id: 'font_spectral',
      title: 'Spectral Moderna',
      description: 'Serif nítida y cristalina optimizada para lectura en pantallas.',
      price: 300,
      type: ShopItemType.font,
      iconName: 'font_download',
    ),
  ];

  static final List<ShopItem> _dossiers = [
    ShopItem(
      id: 'dossier_mitologia',
      title: 'Mitología & Olimpo',
      description: 'Panteón griego, héroes homéricos, criaturas y leyendas antiguas.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'fort',
      assetPath: 'assets/images/dossier_filosofia.png',
    ),
    ShopItem(
      id: 'dossier_filosofia',
      title: 'Filosofía & Mente',
      description: 'Grandes pensadores, dilemas éticos y corrientes del intelecto humano.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'psychology',
      assetPath: 'assets/images/dossier_filosofia.png',
    ),
    ShopItem(
      id: 'dossier_ciencia_cuantica',
      title: 'Ciencia & Cosmos',
      description: 'Astrofísica estelar, física cuántica y ecuaciones del universo.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'science',
      assetPath: 'assets/images/dossier_ciencia.png',
    ),
    ShopItem(
      id: 'dossier_gastronomia_mundo',
      title: 'Gastronomía & Sabores',
      description: 'Alta cocina, especias del mundo y técnicas culinarias maestras.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'restaurant',
      assetPath: 'assets/images/dossier_arte.png',
    ),
    ShopItem(
      id: 'dossier_cine_opera',
      title: 'Cine de Culto & Ópera',
      description: 'Obras maestras del séptimo arte, directores de culto y lírica.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'movie',
      assetPath: 'assets/images/dossier_entretenimiento.png',
    ),
    ShopItem(
      id: 'dossier_historia_antigua',
      title: 'Roma, Grecia & Egipto',
      description: 'Faraones del Nilo, césares imperiales y las polis helénicas.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'account_balance',
      assetPath: 'assets/images/dossier_historia.png',
    ),
    ShopItem(
      id: 'dossier_literatura_universal',
      title: 'Literatura & Clásicos',
      description: 'Obras cumbre de la narrativa universal, poetas y dramaturgos.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'menu_book',
      assetPath: 'assets/images/dossier_literatura.png',
    ),
    ShopItem(
      id: 'dossier_musica_maestros',
      title: 'Música Clásica & Óperas',
      description: 'Sinfonías inmortales, movimientos barrocos y genios virtuosos.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'music_note',
      assetPath: 'assets/images/dossier_entretenimiento.png',
    ),
    ShopItem(
      id: 'dossier_geografia_maravillas',
      title: 'Geografía & Rutas',
      description: 'Cumbres nevadas, estrechos marítimos y capitales del planeta.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'public',
      assetPath: 'assets/images/dossier_geografia.png',
    ),
    ShopItem(
      id: 'dossier_naturaleza_fauna',
      title: 'Naturaleza & Ecosistemas',
      description: 'Flora exótica, especies asombrosas y equilibrio biológico.',
      price: 300,
      type: ShopItemType.dossier,
      iconName: 'nature',
      assetPath: 'assets/images/dossier_geografia.png',
    ),
    ShopItem(
      id: 'dossier_arquitectura_monumentos',
      title: 'Arquitectura & Diseños',
      description: 'Catedrales góticas, templos milenarios y rascacielos vanguardistas.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'apartment',
      assetPath: 'assets/images/dossier_historia.png',
    ),
    ShopItem(
      id: 'dossier_tecnologia_inventos',
      title: 'Grandes Inventos',
      description: 'De la imprenta de tipos móviles a la inteligencia artificial.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'precision_manufacturing',
      assetPath: 'assets/images/dossier_tecnologia.png',
    ),
    ShopItem(
      id: 'dossier_economia_comercio',
      title: 'Economía & Monedas',
      description: 'La Ruta de la Seda, mercados globales y términos del comercio.',
      price: 350,
      type: ShopItemType.dossier,
      iconName: 'payments',
      assetPath: 'assets/images/dossier_historia.png',
    ),
    ShopItem(
      id: 'dossier_arte_vanguardias',
      title: 'Arte & Vanguardias',
      description: 'Impresionismo, cubismo, renacimiento y las pinceladas maestras.',
      price: 400,
      type: ShopItemType.dossier,
      iconName: 'palette',
      assetPath: 'assets/images/dossier_arte.png',
    ),
  ];

  static final List<ShopItem> _titles = [
    ShopItem(
      id: 'title_cronista',
      title: 'Cronista Aprendiz',
      description: 'Iniciación en las letras y en el arte de descifrar crucigramas diarios.',
      price: 0,
      type: ShopItemType.title,
      iconName: 'edit_note',
    ),
    ShopItem(
      id: 'title_corresponsal',
      title: 'Corresponsal Especial',
      description: 'Viajero incatigable de palabras e informaciones de primera plana.',
      price: 150,
      type: ShopItemType.title,
      iconName: 'flight_takeoff',
    ),
    ShopItem(
      id: 'title_critico',
      title: 'Crítico Literario',
      description: 'Ojo analítico y juicio refinado ante las definiciones más enigmáticas.',
      price: 250,
      type: ShopItemType.title,
      iconName: 'rate_review',
    ),
    ShopItem(
      id: 'title_hemeroteca',
      title: 'Investigador de Hemeroteca',
      description: 'Especialista en desempolvar vocablos arcanos y etimologías olvidadas.',
      price: 350,
      type: ShopItemType.title,
      iconName: 'find_in_page',
    ),
    ShopItem(
      id: 'title_columnista',
      title: 'Columnista Titular',
      description: 'Firma de renombre con espacio fijo en la sección de opinión editorial.',
      price: 450,
      type: ShopItemType.title,
      iconName: 'article',
    ),
    ShopItem(
      id: 'title_maestro',
      title: 'Maestro de la Lengua',
      description: 'Erudición comprobada y dominio soberano del léxico castellano.',
      price: 600,
      type: ShopItemType.title,
      iconName: 'school',
    ),
    ShopItem(
      id: 'title_redactor_jefe',
      title: 'Redactor Jefe',
      description: 'Autoridad máxima que aprueba cada edición antes de entrar a talleres.',
      price: 800,
      type: ShopItemType.title,
      iconName: 'workspace_premium',
    ),
    ShopItem(
      id: 'title_pulitzer',
      title: 'Premio Pulitzer de Intelecto',
      description: 'Galardón honorífico a la excelencia y destreza mental sobresaliente.',
      price: 1200,
      type: ShopItemType.title,
      iconName: 'military_tech',
    ),
    ShopItem(
      id: 'title_academico',
      title: 'Académico de Honor',
      description: 'Sillón vitalicio y custodio de la pureza y esplendor de las letras.',
      price: 1500,
      type: ShopItemType.title,
      iconName: 'verified',
    ),
    ShopItem(
      id: 'title_escriba_supremo',
      title: 'Escriba Supremo del Imperio',
      description: 'Leyenda viviente de la imprenta. No existe crucigrama sin resolver.',
      price: 2000,
      type: ShopItemType.title,
      iconName: 'shield',
    ),
  ];

  static final List<ShopItem> _quills = [
    ShopItem(
      id: 'quill_poeta',
      title: 'Pluma del Poeta',
      description: 'Pluma de ganso tallada para redactores románticos y soñadores.',
      price: 120,
      type: ShopItemType.quill,
      iconName: 'feather',
    ),
    ShopItem(
      id: 'quill_vintage_1920',
      title: 'Estilográfica Vintage 1920',
      description: 'Clásica pluma de celuloide con émbolo y plumín de acero suizo.',
      price: 280,
      type: ShopItemType.quill,
      iconName: 'draw',
    ),
    ShopItem(
      id: 'quill_bronce',
      title: 'Pluma de Bronce Antiguo',
      description: 'Pesada pieza forjada para escribas de actas históricas y tratados.',
      price: 400,
      type: ShopItemType.quill,
      iconName: 'hardware',
    ),
    ShopItem(
      id: 'quill_oro_24k',
      title: 'Pluma de Oro 24K',
      description: 'Joya de orfebrería con plumín bañado en oro para firmas insignes.',
      price: 750,
      type: ShopItemType.quill,
      iconName: 'star',
    ),
    ShopItem(
      id: 'quill_obsidiana',
      title: 'Pluma de Obsidiana Imperial',
      description: 'Piedra volcánica pulida que absorbe la luz y traza líneas imborrables.',
      price: 1000,
      type: ShopItemType.quill,
      iconName: 'shield',
    ),
    ShopItem(
      id: 'quill_sello_cera',
      title: 'Sello Ex-Libris de Cera',
      description: 'Sello de lacre escarlata para autenticar ediciones completadas.',
      price: 500,
      type: ShopItemType.quill,
      iconName: 'approval',
    ),
    ShopItem(
      id: 'quill_sello_platino',
      title: 'Gran Sello de Platino',
      description: 'La máxima distinción tipográfica de la Casa Editora.',
      price: 1200,
      type: ShopItemType.quill,
      iconName: 'verified_user',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        backgroundColor: EditorialTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_sharp, size: 20, color: EditorialTheme.inkDark),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: !(ModalRoute.of(context)?.canPop ?? false),
        title: Text(
          "Quiosco",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: EditorialTheme.inkDark,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: EditorialTheme.surface,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: EditorialTheme.borderLine, width: 0.9),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: EditorialTheme.accent, size: 15),
                const SizedBox(width: 5),
                Text(
                  "${gameState.coins}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: EditorialTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: EditorialTheme.borderLine),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // 1. Open Broadsheet Supplement Lead
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TALLER DE IMPRENTA",
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: EditorialTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gaceta del Quiosco",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Personaliza el periódico con tintas clásicas, tipografías históricas y rangos de honor.",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: EditorialTheme.textSecondary,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 0.8, color: EditorialTheme.borderLine),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Patrocinador Editorial (Quiet hairline card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: EditorialTheme.newspaperCardDecoration,
                child: Row(
                  children: [
                    const Icon(Icons.stars_sharp, color: EditorialTheme.accent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "+50 Monedas de la Imprenta",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: EditorialTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "Patrocinio editorial gratuito",
                            style: GoogleFonts.inter(fontSize: 11, color: EditorialTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => AdManager.showRewardedAdForCoins(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EditorialTheme.inkDark,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                      ),
                      child: Text(
                        "RECLAMAR",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
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

            // 6. CARRUSEL 4: TÍTULOS & CREDENCIALES DE HONOR
            _buildSectionHeader(
              sectionNum: "SECCIÓN IV",
              title: "TÍTULOS & CREDENCIALES DE HONOR",
              subtitle: "Rangos periodísticos honoríficos que acreditan tu maestría",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _titles.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = _titles[i];
                  return _buildTitleCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 26),

            // 7. CARRUSEL 5: INSTRUMENTOS DEL ESCRIBA
            _buildSectionHeader(
              sectionNum: "SECCIÓN V",
              title: "INSTRUMENTOS DEL ESCRIBA",
              subtitle: "Plumas de colección y sellos editoriales de prestigio",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 215,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quills.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final item = _quills[i];
                  return _buildQuillCarouselCard(context, gameState, item);
                },
              ),
            ),

            const SizedBox(height: 26),

            // 8. CARRUSEL 6: CAUDALES & EDICIÓN VIP
            _buildSectionHeader(
              sectionNum: "SECCIÓN VI",
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(
                  color: EditorialTheme.inkDark,
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  sectionNum,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: EditorialTheme.borderLine),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: EditorialTheme.textPrimary,
            ),
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
      width: 248,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isEquipped ? EditorialTheme.inkDark : EditorialTheme.borderLine,
          width: isEquipped ? 1.8 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme visual swatch bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Color(bgVal),
              borderRadius: BorderRadius.zero,
              border: Border.all(color: EditorialTheme.inkDark, width: 0.9),
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
                    letterSpacing: 1.1,
                    color: Color(inkVal),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Color(inkVal),
                        border: Border.all(color: EditorialTheme.borderLine, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Color(accVal),
                        border: Border.all(color: EditorialTheme.borderLine, width: 0.5),
                      ),
                    ),
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
                color: EditorialTheme.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.accent, width: 1.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_sharp, size: 14, color: EditorialTheme.inkDark),
                  const SizedBox(width: 4),
                  Text(
                    "EN USO",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: EditorialTheme.inkDark,
                      letterSpacing: 0.9,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "USAR ESTILO",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.9,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "${item.price} MONEDAS · ADQUIRIR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.inkDark,
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
      width: 248,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isEquipped ? EditorialTheme.inkDark : EditorialTheme.borderLine,
          width: isEquipped ? 1.8 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Specimen banner
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: EditorialTheme.background,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: EditorialTheme.borderLine, width: 1),
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
                color: EditorialTheme.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.accent, width: 1.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_sharp, size: 14, color: EditorialTheme.inkDark),
                  const SizedBox(width: 4),
                  Text(
                    "TIPOGRAFÍA ACTIVA",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: EditorialTheme.inkDark,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "ACTIVAR FUENTE",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "${item.price} MONEDAS · ADQUIRIR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.inkDark,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: EditorialTheme.background,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: EditorialTheme.inkDark, width: 1.0),
                ),
                child: const Icon(Icons.menu_book_outlined, color: EditorialTheme.primary, size: 18),
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
                color: EditorialTheme.success.withValues(alpha: 0.14),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.success, width: 1.0),
              ),
              child: Text(
                "✓ DESBLOQUEADO",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "${item.price} MONEDAS · ABRIR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card for Editorial Titles Carousel
  Widget _buildTitleCarouselCard(
    BuildContext context,
    GameStateProvider gameState,
    ShopItem item,
  ) {
    final isUnlocked = gameState.isItemUnlocked(item.id);
    final isEquipped = gameState.activeTitleId == item.id;

    return Container(
      width: 248,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isEquipped ? EditorialTheme.inkDark : EditorialTheme.borderLine,
          width: isEquipped ? 1.8 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title badge bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isEquipped
                  ? EditorialTheme.accent.withValues(alpha: 0.16)
                  : EditorialTheme.background,
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: isEquipped ? EditorialTheme.accent : EditorialTheme.borderLine,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEquipped ? Icons.military_tech : Icons.workspace_premium_outlined,
                  size: 15,
                  color: isEquipped ? EditorialTheme.accent : EditorialTheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  "CREDENCIAL DE PRENSA",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isEquipped ? EditorialTheme.inkDark : EditorialTheme.primary,
                  ),
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
              fontSize: 16,
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
          if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EditorialTheme.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.accent, width: 1.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_sharp, size: 14, color: EditorialTheme.inkDark),
                  const SizedBox(width: 4),
                  Text(
                    "TÍTULO ACTIVO",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: EditorialTheme.inkDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            )
          else if (isUnlocked)
            ElevatedButton(
              onPressed: () => gameState.equipTitle(item.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "EQUIPAR TÍTULO",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
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
                  gameState.equipTitle(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: EditorialTheme.success,
                      content: Text("¡Has obtenido el título de ${item.title}!"),
                    ),
                  );
                } else {
                  _showNeedCoinsSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "${item.price} MONEDAS · INVESTIR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.inkDark,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card for Quills & Seals Carousel
  Widget _buildQuillCarouselCard(
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: EditorialTheme.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: EditorialTheme.accent, width: 1.0),
                ),
                child: const Icon(Icons.edit_outlined, color: EditorialTheme.accent, size: 18),
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
                color: EditorialTheme.success.withValues(alpha: 0.14),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.success, width: 1.0),
              ),
              child: Text(
                "✓ EN LA COLECCIÓN",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
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
                      content: Text("¡Has añadido ${item.title} a tu colección!"),
                    ),
                  );
                } else {
                  _showNeedCoinsSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                "${item.price} MONEDAS · ADQUIRIR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
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
      width: 248,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EditorialTheme.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isVip ? EditorialTheme.inkDark : EditorialTheme.borderLine,
          width: isVip ? 1.8 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isVip ? Icons.workspace_premium : Icons.monetization_on_outlined,
                color: isVip ? EditorialTheme.accent : EditorialTheme.primary,
                size: 20,
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
                color: EditorialTheme.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.zero,
                border: Border.all(color: EditorialTheme.accent, width: 1.1),
              ),
              child: Text(
                "✓ VIP ACTIVO",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: EditorialTheme.inkDark,
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                item.price,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isVip ? EditorialTheme.inkDark : Colors.white,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/game_state_provider.dart';
import '../theme/editorial_theme.dart';

class IapItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final int coinsAmount;
  final bool isVipPackage;

  const IapItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.coinsAmount = 0,
    this.isVipPackage = false,
  });
}

class IapService {
  static const List<IapItem> storeProducts = [
    IapItem(
      id: 'coins_pack_small',
      title: 'Bolsa de Monedas (Aprendiz)',
      description: '250 Monedas de oro para canjear pistas o estilos.',
      price: '\$0.99 USD',
      coinsAmount: 250,
    ),
    IapItem(
      id: 'coins_pack_medium',
      title: 'Cofre del Redactor Jefe',
      description: '1,000 Monedas + Sello exclusivo de Redactor.',
      price: '\$2.99 USD',
      coinsAmount: 1000,
    ),
    IapItem(
      id: 'coins_pack_large',
      title: 'Arca Imperial de Tinta',
      description: '3,500 Monedas de la máxima categoría.',
      price: '\$6.99 USD',
      coinsAmount: 3500,
    ),
    IapItem(
      id: 'vip_subscription_no_ads',
      title: 'Suscripción VIP "Redacción de Honor"',
      description: 'Elimina todos los anuncios, otorga 500 Monedas y bonificación del +20% en premios.',
      price: '\$1.99 USD / mes',
      coinsAmount: 500,
      isVipPackage: true,
    ),
  ];

  static void processPurchase(BuildContext context, IapItem item) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final activeFontId = gameState.activeFontId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: EditorialTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: EditorialTheme.accent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.shopping_bag, color: EditorialTheme.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "CONFIRMAR COMPRA",
                  style: EditorialTheme.getEditorialFont(
                    fontId: activeFontId,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: EditorialTheme.getEditorialFont(
                  fontId: activeFontId,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: EditorialTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.price,
                  style: EditorialTheme.getEditorialFont(
                    fontId: activeFontId,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EditorialTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancelar",
                style: GoogleFonts.inter(color: EditorialTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (item.isVipPackage) {
                  gameState.activateVipNoAds();
                }
                if (item.coinsAmount > 0) {
                  gameState.addCoins(item.coinsAmount);
                }

                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: EditorialTheme.success,
                    content: Text(
                      "¡Compra realizada con éxito! Gracias por apoyar la redacción.",
                      style: GoogleFonts.inter(color: EditorialTheme.surface),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EditorialTheme.primary,
              ),
              child: Text(
                "Comprar Ahora",
                style: GoogleFonts.inter(
                  color: EditorialTheme.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum ShopItemType { theme, font, dossier, title }

class ShopItem {
  final String id;
  final String title;
  final String description;
  final int price;
  final ShopItemType type;
  final String iconName;
  final String? assetPath;
  final Map<String, dynamic>? data;

  ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.iconName,
    this.assetPath,
    this.data,
  });
}

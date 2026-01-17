import 'item_type.dart';

class ItemEffect {
  final double? multiplier;
  final int? damageBonus;

  const ItemEffect({this.multiplier, this.damageBonus});
}

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ItemType type;
  final String imageUrl;
  final ItemEffect? effect;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.imageUrl,
    this.effect,
  });
}

import '../models/task_category.dart';
import '../models/hero_class.dart';
import '../models/inventory_item.dart';
import '../models/item_type.dart';

const String heroImageUrl = 'https://i.ibb.co/Z8pS7mC/pixel-hero-blue.png';

// Colori in ARGB int (senza import di UI)
class CategoryConfig {
  final int colorArgb;
  final String iconKey; // solo una chiave, la UI poi mappa a IconData
  const CategoryConfig({required this.colorArgb, required this.iconKey});
}

const Map<TaskCategory , CategoryConfig> categoryConfig = {
  TaskCategory .work: CategoryConfig(colorArgb: 0xFF3B82F6, iconKey: 'briefcase'),
  TaskCategory .study: CategoryConfig(colorArgb: 0xFFA855F7, iconKey: 'book'),
  TaskCategory .home: CategoryConfig(colorArgb: 0xFFF97316, iconKey: 'home'),
  TaskCategory .health: CategoryConfig(colorArgb: 0xFFEF4444, iconKey: 'heart'),
  TaskCategory .social: CategoryConfig(colorArgb: 0xFF22C55E, iconKey: 'users'),
  TaskCategory .other: CategoryConfig(colorArgb: 0xFFEAB308, iconKey: 'sparkles'),
};

class HeroConfig {
  final String iconKey;
  final String description;
  const HeroConfig({required this.iconKey, required this.description});
}

const Map<HeroClass, HeroConfig> heroConfig = {
  HeroClass.knight: HeroConfig(iconKey: 'shield', description: 'Forza e disciplina'),
  HeroClass.mage: HeroConfig(iconKey: 'zap', description: 'Conoscenza e studio'),
  HeroClass.ninja: HeroConfig(iconKey: 'target', description: 'Agilità e task rapidi'),
  HeroClass.dwarf: HeroConfig(iconKey: 'wind', description: 'Equilibrio e benessere'),
  HeroClass.healer: HeroConfig(iconKey: 'sun', description: 'Aiutare gli altri'),

};

const List<InventoryItem> shopItems = [
  InventoryItem(
    id: 'eq1',
    name: "Guanti d'Oro",
    description: '+20% Cristalli guadagnati',
    price: 300,
    type: ItemType.equipment,
    imageUrl: 'https://img.icons8.com/color/96/boxing-glove.png',
    effect: ItemEffect(multiplier: 1.2),
  ),
  InventoryItem(
    id: 'eq2',
    name: 'Spada del Focus',
    description: '+10 Danni al Boss',
    price: 450,
    type: ItemType.equipment,
    imageUrl: 'https://img.icons8.com/color/96/sword.png',
    effect: ItemEffect(damageBonus: 10),
  ),
  InventoryItem(
    id: 'm1',
    name: 'Lofi Chill Pack',
    description: 'Sblocca tracce Lofi per il focus',
    price: 100,
    type: ItemType.game,
    imageUrl: 'https://img.icons8.com/color/96/music.png',
  ),
  InventoryItem(
    id: 'm2',
    name: 'Synthwave Beats',
    description: 'Musica adrenalinica per le sfide',
    price: 150,
    type: ItemType.game,
    imageUrl: 'https://img.icons8.com/color/96/electronic-music.png',
  ),
];

const List<InventoryItem> cosmeticItems = [
  InventoryItem(
    id: 'c1',
    name: 'Armatura Drago',
    description: 'Un look leggendario',
    price: 500,
    type: ItemType.cosmetic,
    imageUrl: 'https://img.icons8.com/color/96/armor.png',
  ),
  InventoryItem(
    id: 'c2',
    name: 'Veste Astrale',
    description: 'Per maghi dello studio',
    price: 600,
    type: ItemType.cosmetic,
    imageUrl: 'https://img.icons8.com/color/96/wizard.png',
  ),
  InventoryItem(
    id: 'c3',
    name: 'Mantello Ombra',
    description: 'Focus invisibile',
    price: 400,
    type: ItemType.cosmetic,
    imageUrl: 'https://img.icons8.com/color/96/cloak.png',
  ),
];

class EnemySprite {
  final String name;
  final String sprite; // emoji come nel TS
  final String description;
  const EnemySprite({required this.name, required this.sprite, required this.description});
}

const List<EnemySprite> enemySprites = [
  EnemySprite(name: 'Ombra del Divano', sprite: '🛋️', description: 'Ti attira nel relax eterno'),
  EnemySprite(name: 'Demone Social', sprite: '📱', description: 'Ruba minuti preziosi'),
  EnemySprite(name: 'Ciclope del Letto', sprite: '🛏️', description: 'Solo altri 5 minuti...'),
  EnemySprite(name: 'Golem della Noia', sprite: '🗿', description: 'Rende tutto pesante'),
];

import '../../../models/hero_class.dart';

class HeroClassDef {
  final HeroClass classId;
  final String bodyId;
  final String defaultWeaponId;

  /// Se non hai overlay armatura come PNG separati, lascia [].
  final List<String> armorVariantIds;

  HeroClassDef({
    required this.classId,
    required this.bodyId,
    required this.defaultWeaponId,
    this.armorVariantIds = const [],
  });
}

/// Definizioni per tutte le classi disponibili.
final List<HeroClassDef> kHeroClassDefs = [
  HeroClassDef(
    classId: HeroClass.knight,
    bodyId: 'body_knight_base',
    defaultWeaponId: 'weapon_knight_base',
    armorVariantIds: const [], // aggiungi quando hai i PNG armor
  ),
  HeroClassDef(
    classId: HeroClass.ninja,
    bodyId: 'body_ninja_base',
    defaultWeaponId: 'weapon_ninja_base',
    armorVariantIds: const [],
  ),
  HeroClassDef(
    classId: HeroClass.mage,
    bodyId: 'body_mage_base',
    defaultWeaponId: 'weapon_mage_base',
    armorVariantIds: const [],
  ),
  HeroClassDef(
    classId: HeroClass.dwarf,
    bodyId: 'body_dwarf_base',
    defaultWeaponId: 'weapon_dwarf_base',
    armorVariantIds: const [],
  ),
  HeroClassDef(
    classId: HeroClass.healer,
    bodyId: 'body_healer_base',
    defaultWeaponId: 'weapon_healer_base',
    armorVariantIds: const [],
  ),
];

final Map<HeroClass, HeroClassDef> kHeroClassDefById = {
  for (final d in kHeroClassDefs) d.classId: d,
};

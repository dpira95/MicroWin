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

/// SOLO Knight + Ninja
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
];

final Map<HeroClass, HeroClassDef> kHeroClassDefById = {
  for (final d in kHeroClassDefs) d.classId: d,
};

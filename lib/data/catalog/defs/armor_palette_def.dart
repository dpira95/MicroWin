/// Armor “palette” = 2 varianti fisse per classe.
/// Questa definizione descrive solo la VARIANTE (a1/a2), non l’asset.
/// L’asset effettivo lo ricavi dai ids in HeroClassDef.armorVariantIds.
class ArmorVariantDef {
  final String key;   // 'a1' / 'a2'
  final String label; // testo UI

  ArmorVariantDef({required this.key, required this.label});
}

final List<ArmorVariantDef> kArmorVariantDefs = [
  ArmorVariantDef(key: 'a1', label: 'Standard'),
  ArmorVariantDef(key: 'a2', label: 'Invertita'),
];

final Map<String, ArmorVariantDef> kArmorVariantByKey = {
  for (final v in kArmorVariantDefs) v.key: v,
};

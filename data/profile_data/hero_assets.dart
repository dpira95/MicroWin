import 'package:flutter/widgets.dart';

/// Risolve un asset ID (catalogo) nel path reale in /assets.
/// Qui puoi mantenere compatibilità con nomi vecchi (es. warrior_type1.png)
/// senza sporcare catalogo, profilo, UI o composer.
class HeroAssets {
  /// Override “manuali” per asset già esistenti con naming non standard.
  /// Aggiungi qui finché non rinomini i file.
  static final Map<String, String> _overrides = {
    // Teste/visi attuali (assets/hero/faces/)
    'head_warrior_01': 'assets/hero/faces/warrior_type1.png',
    'head_warrior_02': 'assets/hero/faces/warrior_type2.png',

    // Esempio: se hai un copricapo già pronto (assets/hero/head/)
    'hw_helmet_01': 'assets/hero/head/head_helmet_01.png',
  };

  /// Convenzioni base (quando i file seguiranno lo standard).
  /// Per ora può convivere con gli override sopra.
  static String pathOf(String assetId) {
    final o = _overrides[assetId];
    if (o != null) return o;

    // Head (testa/viso/capelli) — convenzione proposta:
    if (assetId.startsWith('head_')) {
      // es: head_mage_01 -> assets/hero/faces/head_mage_01.png
      return 'assets/hero/faces/$assetId.png';
    }

    // Headwear (cappelli/elmi)
    if (assetId.startsWith('hw_')) {
      return 'assets/hero/head/$assetId.png';
    }

    // Body / Armor variants
    if (assetId.startsWith('body_') || assetId.startsWith('armor_')) {
      return 'assets/hero/body/$assetId.png';
    }

    // Weapon
    if (assetId.startsWith('wpn_') || assetId.startsWith('weapon_')) {
      return 'assets/hero/weapons/$assetId.png';
    }

    // Fallback: se ti scappa un id non previsto
    return 'assets/hero/$assetId.png';
  }

  static AssetImage imageOf(String assetId) => AssetImage(pathOf(assetId));
}

/// Istanza comoda.
final heroAssets = HeroAssets();

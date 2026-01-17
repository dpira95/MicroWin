import '../catalog/defs/hero_class_def.dart';
import '../catalog/defs/head_def.dart';
import '../catalog/defs/skin_palette_def.dart';
import '../catalog/defs/armor_palette_def.dart';
import '../../models/hero_class.dart';

class HeroCatalog {
  // --- Class defs ---
  HeroClassDef classDef(HeroClass id) {
    final d = kHeroClassDefById[id];
    if (d == null) {
      throw StateError('HeroCatalog: class def mancante per $id');
    }
    return d;
  }

  List<HeroClassDef> get allClasses => List.unmodifiable(kHeroClassDefs);

  // --- Head (globali, non dipendono dalla classe) ---
  List<String> get allHeadIds => List.unmodifiable(kHeadIds);

  List<String> headPaletteIdsForHead(String headId) {
    return List.unmodifiable(kHeadPaletteIdsByHeadId[headId] ?? const <String>[]);
  }

  // --- Create screen options (dipendenti dalla classe) ---
  /// Ritorna le varianti disponibili per la classe selezionata (può essere vuoto).
  List<String> armorVariantIdsForClass(HeroClass id) => classDef(id).armorVariantIds;

  /// Arma fissa per classe (mostrata in creazione).
  String defaultWeaponIdForClass(HeroClass id) => classDef(id).defaultWeaponId;

  /// Body univoco per classe.
  String bodyIdForClass(HeroClass id) => classDef(id).bodyId;

  // --- Skin palettes (globali) ---
  List<SkinPaletteDef> get skinPalettes => List.unmodifiable(kSkinPaletteDefs);

  SkinPaletteDef skinPaletteById(String id) {
    final p = kSkinPaletteById[id];
    if (p == null) throw StateError('HeroCatalog: skin palette sconosciuta: $id');
    return p;
  }

  // --- Armor variants meta (globali) ---
  List<ArmorVariantDef> get armorVariants => List.unmodifiable(kArmorVariantDefs);

  ArmorVariantDef armorVariantByKey(String key) {
    final v = kArmorVariantByKey[key];
    if (v == null) throw StateError('HeroCatalog: armor variant key sconosciuta: $key');
    return v;
  }
}

/// Istanza comoda (stateless, dati statici).
final HeroCatalog heroCatalog = HeroCatalog();

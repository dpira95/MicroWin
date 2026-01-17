import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../../data/catalog/hero_catalog.dart';
import '../../models/hero_class.dart';
import '../../models/hero_identity.dart';
import '../../models/hero_loadout.dart';
import '../../data/profile_data/hero_assets.dart';
import '../../data/profile_data/hero_sprite_meta.dart';

class HeroComposer {
  static const double canvasSize = 256.0;

  Widget buildAvatar({
    required HeroIdentity identity,
    required HeroLoadout loadout,
    double idleT = 0.0,
  }) {
    final heroClass = _parseHeroClass(identity.classId);
    final classDef = heroCatalog.classDef(heroClass);

    final bodyId = classDef.bodyId;

    // Head globale + palette per head
    final headLayerAssetId = _resolveHeadLayerAssetId(
      allHeadIds: heroCatalog.allHeadIds,
      selectedHeadId: identity.headId,
      selectedHeadPaletteId: identity.headPaletteId,
    );

    final armorId = _resolveArmorId(
      classDefArmorIds: classDef.armorVariantIds,
      armorPaletteId: identity.armorPaletteId,
    );

    final weaponId = classDef.defaultWeaponId;

    final headwearId = _resolveHeadwearId(loadout);

    final idleY = _idleOffsetY(idleT);

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: idleY,
            child: SizedBox(
              width: canvasSize,
              height: canvasSize,
              child: Stack(
                children: [
                  _layer(assetId: bodyId),
                  if (armorId != null) _layer(assetId: armorId),
                  _layer(assetId: headLayerAssetId),
                  _layer(assetId: weaponId),
                  if (headwearId != null) _headwearLayer(headwearId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _layer({required String assetId}) {
    return Image.asset(
      HeroAssets.pathOf(assetId),
      width: canvasSize,
      height: canvasSize,
      filterQuality: FilterQuality.none,
      fit: BoxFit.contain,
    );
  }

  Widget _headwearLayer(String headwearId) {
    final pivot = HeroSpriteMeta.pivotForHead(headwearId);
    final offset = HeroSpriteMeta.offsetForHead(headwearId);

    final pos =
        HeroSpriteMeta.faceHeadAnchor - pivot + offset + HeroSpriteMeta.headGlobalOffset;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Image.asset(
        HeroAssets.pathOf(headwearId),
        width: canvasSize,
        height: canvasSize,
        filterQuality: FilterQuality.none,
        fit: BoxFit.contain,
      ),
    );
  }

  double _idleOffsetY(double t) {
    final phase = (t * 2 * math.pi) % (2 * math.pi);
    return math.sin(phase) * 1.5;
  }

  HeroClass _parseHeroClass(String raw) {
    for (final v in HeroClass.values) {
      if (v.name == raw) return v;
    }
    final cleaned = raw.replaceAll('HeroClass.', '');
    for (final v in HeroClass.values) {
      if (v.name == cleaned) return v;
    }
    throw StateError('HeroComposer: classId sconosciuto: $raw');
  }

  String _resolveHeadLayerAssetId({
    required List<String> allHeadIds,
    required String selectedHeadId,
    required String selectedHeadPaletteId,
  }) {
    final headId = allHeadIds.contains(selectedHeadId)
        ? selectedHeadId
        : (allHeadIds.isNotEmpty ? allHeadIds.first : 'head_01');

    final palettes = heroCatalog.headPaletteIdsForHead(headId);

    // Se non hai palette per questa head, usa sempre la base.
    if (palettes.isEmpty) return headId;

    // Se l'utente ha selezionato una palette valida per quella head, usa quella.
    if (selectedHeadPaletteId.isNotEmpty && palettes.contains(selectedHeadPaletteId)) {
      return selectedHeadPaletteId;
    }

    // Fallback: prima palette disponibile.
    return palettes.first;
  }

  String? _resolveArmorId({
    required List<String> classDefArmorIds,
    required String armorPaletteId,
  }) {
    if (classDefArmorIds.isEmpty) return null;
    if (classDefArmorIds.contains(armorPaletteId)) return armorPaletteId;
    if (armorPaletteId == 'a1' && classDefArmorIds.isNotEmpty) {
      return classDefArmorIds[0];
    }
    if (armorPaletteId == 'a2' && classDefArmorIds.length > 1) {
      return classDefArmorIds[1];
    }
    return classDefArmorIds.first;
  }

  String? _resolveHeadwearId(HeroLoadout loadout) {
    final ids = loadout.extraCosmeticIds;
    for (final id in ids) {
      if (id.startsWith('head_')) return id;
    }
    return null;
  }
}

final heroComposer = HeroComposer();

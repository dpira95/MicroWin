import 'package:flutter/material.dart';

import '../../../logic/hero/hero_composer.dart';
import '../../../models/hero_identity.dart';
import '../../../models/hero_loadout.dart';

class HeroCompositeView extends StatelessWidget {
  final String classId;
  final String headId;
  final String headPaletteId;
  final String armorPaletteId;
  final String skinPaletteId;

  const HeroCompositeView({
    super.key,
    required this.classId,
    required this.headId,
    required this.headPaletteId,
    required this.armorPaletteId,
    required this.skinPaletteId,
  });

  @override
  Widget build(BuildContext context) {
    final identity = HeroIdentity(
      name: 'preview',
      classId: classId,
      headId: headId,
      headPaletteId: headPaletteId,
      armorPaletteId: armorPaletteId,
      skinPaletteId: skinPaletteId,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    final loadout = HeroLoadout(
      extraCosmeticIds: const [],
    );

    return Center(
      child: heroComposer.buildAvatar(
        identity: identity,
        loadout: loadout,
        idleT: 0.0,
      ),
    );
  }
}

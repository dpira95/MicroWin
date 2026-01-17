import 'package:flutter/material.dart';

import 'hero_preview/hero_composite_view.dart';

class HeroPreview extends StatelessWidget {
  final String classId;
  final String headId;
  final String headPaletteId;
  final String armorPaletteId;
  final String skinPaletteId;

  const HeroPreview({
    super.key,
    required this.classId,
    required this.headId,
    required this.headPaletteId,
    required this.armorPaletteId,
    required this.skinPaletteId,
  });

  @override
  Widget build(BuildContext context) {
    final headLabel = headPaletteId.trim().isEmpty ? headId : headPaletteId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroCompositeView(
          classId: classId,
          headId: headId,
          headPaletteId: headPaletteId,
          armorPaletteId: armorPaletteId,
          skinPaletteId: skinPaletteId,
        ),
        const SizedBox(height: 8),

        _pill('class: $classId'),
        const SizedBox(height: 6),
        _pill('head: $headLabel | armor: $armorPaletteId | skin: $skinPaletteId'),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF334155), width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

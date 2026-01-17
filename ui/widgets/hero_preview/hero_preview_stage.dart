import 'package:flutter/material.dart';

import 'hero_composite_view.dart';

class HeroPreviewStage extends StatelessWidget {
  final String classId;
  final String headId;
  final String headPaletteId;
  final String armorPaletteId;
  final String skinPaletteId;

  const HeroPreviewStage({
    super.key,
    required this.classId,
    required this.headId,
    required this.headPaletteId,
    required this.armorPaletteId,
    required this.skinPaletteId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155), width: 2),
        color: const Color(0xFF0B1220),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF17304A),
                    Color(0xFF0B1220),
                  ],
                ),
              ),
              child: const Opacity(
                opacity: 0.12,
                child: Center(child: Icon(Icons.forest, size: 140)),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 170,
              height: 220,
              child: HeroCompositeView(
                classId: classId,
                headId: headId,
                headPaletteId: headPaletteId,
                armorPaletteId: armorPaletteId,
                skinPaletteId: skinPaletteId,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1220),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF334155), width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

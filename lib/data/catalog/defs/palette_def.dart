import 'package:flutter/material.dart';

class PaletteDef {
  /// Id stabile (es: "pal_01")
  final String id;

  /// Nome mostrato in UI
  final String displayName;

  /// Colori base del personaggio
  final Color skinColor;
  final Color hairColor;
  final Color outfitColor;

  const PaletteDef({
    required this.id,
    required this.displayName,
    required this.skinColor,
    required this.hairColor,
    required this.outfitColor,
  });
}

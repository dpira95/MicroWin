// lib/data/hero_sprite_meta.dart
import 'package:flutter/material.dart';

/// Metadati per comporre sprite modulari su canvas fisso (256x256).
/// - Il "face" riempie il canvas (0..256) con la testa posizionata in modo coerente.
/// - Ogni head cosmetic ha un pivot interno (punto di aggancio) sul suo PNG.
/// - La posizione del head layer si calcola così:
///     headTopLeft = faceHeadAnchor - headPivot + headOffset
///
/// Nota: i valori qui sono DEFAULT.
/// Dopo che crei 2-3 cappelli veri, aggiusti solo questi pivot/offset e basta.
class HeroSpriteMeta {
  static const double canvas = 256.0;
  static const Size canvasSize = Size(canvas, canvas);

  /// Punto "testa" sul canvas della faccia/base.
  /// È la posizione dove vuoi che si agganci cappello/elmo.
  /// (x: centro testa, y: linea appoggio per headwear)
  static const Offset faceHeadAnchor = Offset(128, 86);

  /// Offset extra per headwear (se vuoi alzare/abbassare globalmente).
  static const Offset headGlobalOffset = Offset(0, 0);

  /// Pivot interno per ogni head cosmetic: il punto che deve combaciare con faceHeadAnchor.
  /// Chiave: id cosmetico (es: 'head_hat_01')
  static const Map<String, Offset> headPivot = {
    // Convenzione: pivot = punto “base” cappello/elmo (dove tocca la testa).
    // Questi sono placeholder: li aggiusti dopo con 2 numeri e basta.
    'head_hat_01': Offset(128, 150),
    'head_helmet_01': Offset(128, 128),
  };

  /// Offset extra per singolo head cosmetic (se vuoi micro-correzioni).
  static const Map<String, Offset> headOffset = {
    // Esempio: 'head_hat_01': Offset(0, -2),
  };

  static Offset pivotForHead(String headId) {
    return headPivot[headId] ?? const Offset(128, 128);
  }

  static Offset offsetForHead(String headId) {
    return headOffset[headId] ?? Offset.zero;
  }
}

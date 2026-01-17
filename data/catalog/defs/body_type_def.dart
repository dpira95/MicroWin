class BodyTypeDef {
  /// Id stabile (es: "type1")
  final String id;

  /// Nome mostrato in UI
  final String displayName;

  /// Suffisso/chiave sprite (es: "t1")
  final String spriteVariantKey;

  const BodyTypeDef({
    required this.id,
    required this.displayName,
    required this.spriteVariantKey,
  });
}

/// Skin palette globali (scelte discrete).
/// Qui NON c’è logica, solo dati.
///
/// Nota: i colori reali (Color) li puoi mappare in UI dove serve.
/// Qui teniamo solo ID + label.
class SkinPaletteDef {
  final String id;
  final String label;

  SkinPaletteDef({required this.id, required this.label});
}

/// Ordine = ordine di visualizzazione in creazione.
final List<SkinPaletteDef> kSkinPaletteDefs = [
  SkinPaletteDef(id: 'skin_light', label: 'Chiara'),
  SkinPaletteDef(id: 'skin_medium', label: 'Media'),
  SkinPaletteDef(id: 'skin_dark', label: 'Scura'),
  SkinPaletteDef(id: 'skin_green', label: 'Verde'),
  SkinPaletteDef(id: 'skin_blue', label: 'Blu'),
  SkinPaletteDef(id: 'skin_red', label: 'Rossa'),
];

final Map<String, SkinPaletteDef> kSkinPaletteById = {
  for (final p in kSkinPaletteDefs) p.id: p,
};

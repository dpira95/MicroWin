/// Head globali (uguali per tutte le classi).
final List<String> kHeadIds = [
  'head_01',
  'head_02',
  'head_03',
  'head_04',
  'head_05',
];

/// Palette per head (dipendenti dalla head).
/// Qui metti gli ASSET ID reali che esistono nel progetto.
/// Convenzione usata: head_<nn>_p<nn>
final Map<String, List<String>> kHeadPaletteIdsByHeadId = {
  'head_01': ['head_01_p01', 'head_01_p02', 'head_01_p03'],
  'head_02': ['head_02_p01', 'head_02_p02', 'head_02_p03'],
  'head_03': ['head_03_p01', 'head_03_p02', 'head_03_p03'],
  'head_04': ['head_04_p01', 'head_04_p02', 'head_04_p03'],
  'head_05': ['head_05_p01', 'head_05_p02', 'head_05_p03'],
};

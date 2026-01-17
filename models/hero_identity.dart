class HeroIdentity {
  /// Immutabile dopo la creazione.
  final String name;

  /// Es: "warrior", "mage", ...
  final String classId;

  /// Head selezionata (globale): es "head_01"
  final String headId;

  /// Palette head selezionata (dipendente dalla head): es "head_01_p02"
  /// Se vuota => usa la head base (headId).
  final String headPaletteId;

  /// Variante armatura base (overlay/variant): es "armor_warrior_a1"
  final String armorPaletteId;

  /// Palette pelle base: es "skin_01"
  final String skinPaletteId;

  /// Epoch ms: quando è stato creato il personaggio.
  final int createdAtMs;

  const HeroIdentity({
    required this.name,
    required this.classId,
    required this.headId,
    required this.headPaletteId,
    required this.armorPaletteId,
    required this.skinPaletteId,
    required this.createdAtMs,
  });

  HeroIdentity copyWith({
    String? name,
    String? classId,
    String? headId,
    String? headPaletteId,
    String? armorPaletteId,
    String? skinPaletteId,
    int? createdAtMs,
  }) {
    return HeroIdentity(
      name: name ?? this.name,
      classId: classId ?? this.classId,
      headId: headId ?? this.headId,
      headPaletteId: headPaletteId ?? this.headPaletteId,
      armorPaletteId: armorPaletteId ?? this.armorPaletteId,
      skinPaletteId: skinPaletteId ?? this.skinPaletteId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'classId': classId,
    'headId': headId,
    'headPaletteId': headPaletteId,
    'armorPaletteId': armorPaletteId,
    'skinPaletteId': skinPaletteId,
    'createdAtMs': createdAtMs,
  };

  static HeroIdentity fromJson(Map<String, dynamic> json) {
    // Back-compat: vecchio campo "bodyTypeId" usato come head.
    final legacyHead = (json['bodyTypeId'] ?? '').toString();

    // Back-compat minima: se arriva un vecchio "paletteId", lo spacchettiamo se possibile.
    final legacyPalette = json['paletteId']?.toString();

    String armor = (json['armorPaletteId'] ?? '').toString();
    String skin = (json['skinPaletteId'] ?? '').toString();

    if ((armor.isEmpty || skin.isEmpty) && legacyPalette != null && legacyPalette.isNotEmpty) {
      armor = armor.isEmpty ? 'armor_01' : armor;
      skin = skin.isEmpty ? 'skin_01' : skin;

      final aIdx = legacyPalette.indexOf('armor_');
      final sIdx = legacyPalette.indexOf('_skin_');
      if (aIdx == 0 && sIdx > 0) {
        final aNum = legacyPalette.substring('armor_'.length, sIdx);
        final sNum = legacyPalette.substring(sIdx + '_skin_'.length);
        final a = int.tryParse(aNum) ?? 0;
        final s = int.tryParse(sNum) ?? 0;
        armor = 'armor_${(a + 1).toString().padLeft(2, '0')}';
        skin = 'skin_${(s + 1).toString().padLeft(2, '0')}';
      }
    }

    if (armor.isEmpty) armor = 'armor_01';
    if (skin.isEmpty) skin = 'skin_01';

    final head = (json['headId'] ?? '').toString();
    final resolvedHead = head.isNotEmpty ? head : (legacyHead.isNotEmpty ? legacyHead : 'head_01');

    // headPaletteId può mancare nei salvataggi vecchi.
    final headPalette = (json['headPaletteId'] ?? '').toString();

    return HeroIdentity(
      name: (json['name'] ?? '').toString(),
      classId: (json['classId'] ?? '').toString(),
      headId: resolvedHead,
      headPaletteId: headPalette, // vuoto => base
      armorPaletteId: armor,
      skinPaletteId: skin,
      createdAtMs: (json['createdAtMs'] is int)
          ? json['createdAtMs'] as int
          : int.tryParse((json['createdAtMs'] ?? '0').toString()) ?? 0,
    );
  }
}

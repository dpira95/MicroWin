// lib/models/hero_loadout.dart
class HeroLoadout {
  /// Cosmetico armatura equipaggiato (mutabile).
  /// Es: "armor_basic_blue", "armor_knight_01"
  final String? armorCosmeticId;

  /// Cosmetico arma equipaggiata (mutabile).
  /// Es: "weapon_sword_01"
  final String? weaponCosmeticId;

  /// Tint/colore applicato al cosmetico armatura (se previsto).
  /// Es: "tint_01"
  final String? armorTintId;

  /// Extra cosmetici (mantello, cappello, occhiali ecc).
  final List<String> extraCosmeticIds;

  const HeroLoadout({
    this.armorCosmeticId,
    this.weaponCosmeticId,
    this.armorTintId,
    this.extraCosmeticIds = const [],
  });

  HeroLoadout copyWith({
    String? armorCosmeticId,
    String? weaponCosmeticId,
    String? armorTintId,
    List<String>? extraCosmeticIds,
    bool clearArmorCosmeticId = false,
    bool clearWeaponCosmeticId = false,
    bool clearArmorTintId = false,
  }) {
    return HeroLoadout(
      armorCosmeticId:
      clearArmorCosmeticId ? null : (armorCosmeticId ?? this.armorCosmeticId),
      weaponCosmeticId:
      clearWeaponCosmeticId ? null : (weaponCosmeticId ?? this.weaponCosmeticId),
      armorTintId: clearArmorTintId ? null : (armorTintId ?? this.armorTintId),
      extraCosmeticIds: extraCosmeticIds ?? this.extraCosmeticIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'armorCosmeticId': armorCosmeticId,
    'weaponCosmeticId': weaponCosmeticId,
    'armorTintId': armorTintId,
    'extraCosmeticIds': extraCosmeticIds,
  };

  static HeroLoadout fromJson(Map<String, dynamic> json) {
    final extrasRaw = json['extraCosmeticIds'];
    final extras = <String>[];
    if (extrasRaw is List) {
      for (final e in extrasRaw) {
        extras.add(e.toString());
      }
    }

    return HeroLoadout(
      armorCosmeticId: json['armorCosmeticId']?.toString(),
      weaponCosmeticId: json['weaponCosmeticId']?.toString(),
      armorTintId: json['armorTintId']?.toString(),
      extraCosmeticIds: extras,
    );
  }
}

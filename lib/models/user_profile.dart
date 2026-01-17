import 'hero_identity.dart';
import 'hero_loadout.dart';

class UserProfile {
  final String profileId;

  final int crystals;
  final int level;
  final int xp;

  final HeroIdentity hero;
  final HeroLoadout loadout;

  final List<String> unlockedCosmeticIds;

  final int lastSeenAtMs;

  const UserProfile({
    required this.profileId,
    required this.crystals,
    required this.level,
    required this.xp,
    required this.hero,
    required this.loadout,
    this.unlockedCosmeticIds = const [],
    required this.lastSeenAtMs,
  });

  UserProfile copyWith({
    String? profileId,
    int? crystals,
    int? level,
    int? xp,
    HeroIdentity? hero,
    HeroLoadout? loadout,
    List<String>? unlockedCosmeticIds,
    int? lastSeenAtMs,
  }) {
    return UserProfile(
      profileId: profileId ?? this.profileId,
      crystals: crystals ?? this.crystals,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      hero: hero ?? this.hero,
      loadout: loadout ?? this.loadout,
      unlockedCosmeticIds: unlockedCosmeticIds ?? this.unlockedCosmeticIds,
      lastSeenAtMs: lastSeenAtMs ?? this.lastSeenAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'profileId': profileId,
    'crystals': crystals,
    'level': level,
    'xp': xp,
    'hero': hero.toJson(),
    'loadout': loadout.toJson(),
    'unlockedCosmeticIds': unlockedCosmeticIds,
    'lastSeenAtMs': lastSeenAtMs,
  };

  static UserProfile fromJson(Map<String, dynamic> json) {
    final unlockedRaw = json['unlockedCosmeticIds'];
    final unlocked = <String>[];
    if (unlockedRaw is List) {
      for (final e in unlockedRaw) {
        unlocked.add(e.toString());
      }
    }

    final heroJson =
    (json['hero'] is Map) ? (json['hero'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    final loadoutJson =
    (json['loadout'] is Map) ? (json['loadout'] as Map).cast<String, dynamic>() : <String, dynamic>{};

    return UserProfile(
      profileId: (json['profileId'] ?? '').toString(),
      crystals: (json['crystals'] is int)
          ? json['crystals'] as int
          : int.tryParse((json['crystals'] ?? '0').toString()) ?? 0,
      level: (json['level'] is int)
          ? json['level'] as int
          : int.tryParse((json['level'] ?? '1').toString()) ?? 1,
      xp: (json['xp'] is int) ? json['xp'] as int : int.tryParse((json['xp'] ?? '0').toString()) ?? 0,
      hero: HeroIdentity.fromJson(heroJson),
      loadout: HeroLoadout.fromJson(loadoutJson),
      unlockedCosmeticIds: unlocked,
      lastSeenAtMs: (json['lastSeenAtMs'] is int)
          ? json['lastSeenAtMs'] as int
          : int.tryParse((json['lastSeenAtMs'] ?? '0').toString()) ?? 0,
    );
  }
}

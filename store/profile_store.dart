import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/profile_data/profile_repository.dart';
import '../models/hero_identity.dart';
import '../models/hero_loadout.dart';
import '../models/user_profile.dart';


class ProfileStore extends ChangeNotifier {
  final ProfileRepository _repo;

  UserProfile? _current;
  bool _loaded = false;

  ProfileStore({ProfileRepository? repo}) : _repo = repo ?? ProfileRepository();

  bool get loaded => _loaded;
  UserProfile? get current => _current;

  bool get hasProfile => _current != null;
  bool get hasHeroIdentity => _current?.hero.name.isNotEmpty == true;

  Future<void> load() async {
    _current = await _repo.loadProfile();
    _loaded = true;
    notifyListeners();
  }

  Future<void> clear() async {
    _current = null;
    await _repo.clearProfile();
    notifyListeners();
  }

  /// Crea profilo nuovo SOLO se non esiste già.
  /// Base immutabile: una volta creato, non la sovrascrivi più.
  Future<UserProfile> createProfileIfMissing({
    required HeroIdentity hero,
  }) async {
    if (_current != null) return _current!;

    final now = DateTime.now().millisecondsSinceEpoch;
    final profile = UserProfile(
      profileId: _randomId(14),
      crystals: 150,
      level: 1,
      xp: 0,
      hero: hero,
      loadout: const HeroLoadout(),
      unlockedCosmeticIds: const [],
      lastSeenAtMs: now,
    );

    _current = profile;
    await _repo.saveProfile(profile);
    notifyListeners();
    return profile;
  }

  /// Aggiorna solo la parte MUTABILE (currency/exp/loadout/unlocked).
  Future<void> updateProfile(UserProfile updated) async {
    _current = updated.copyWith(
      lastSeenAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.saveProfile(_current!);
    notifyListeners();
  }

  Future<void> updateLoadout(HeroLoadout loadout) async {
    final c = _current;
    if (c == null) return;
    await updateProfile(c.copyWith(loadout: loadout));
  }

  Future<void> addCrystals(int delta) async {
    final c = _current;
    if (c == null) return;
    final next = c.crystals + delta;
    await updateProfile(c.copyWith(crystals: next < 0 ? 0 : next));
  }

  Future<void> addXp(int delta) async {
    final c = _current;
    if (c == null) return;

    int xp = c.xp + delta;
    int level = c.level;

    while (xp >= 100) {
      xp -= 100;
      level += 1;
    }
    if (xp < 0) xp = 0;

    await updateProfile(c.copyWith(xp: xp, level: level));
  }

  String _randomId(int len) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
  }
}

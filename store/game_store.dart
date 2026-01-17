// lib/store/game_store.dart
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/constants.dart';
import '../data/profile_data/profile_repository.dart';
import '../models/active_tool.dart';
import '../models/game_state.dart';
import '../models/hero_class.dart';
import '../models/inventory_item.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_status.dart';
import '../models/user_profile.dart';
import '../models/hero_identity.dart';
import '../models/hero_loadout.dart';

class GameStore extends ChangeNotifier {
  // --- Stato "legacy" usato ancora da varie schermate (AppShell/Map/TaskSession) ---
  GameState _gameState;
  List<Task> tasks;
  List<String> unlockedIds;
  ActiveTool activeTool;

  // --- Profilo locale (nuovo) ---
  final ProfileRepository _profileRepo;
  UserProfile? _profile;
  bool _bootstrapped = false;

  static const String headNone = 'head_none';

  GameStore({
    GameState? initialState,
    List<Task>? initialTasks,
    List<String>? initialUnlockedIds,
    ProfileRepository? profileRepository,
  })  : _gameState = initialState ?? _initialState(),
        tasks = initialTasks ?? _initialTasks(),
        unlockedIds = initialUnlockedIds ?? <String>[],
        activeTool = ActiveTool.none,
        _profileRepo = profileRepository ?? ProfileRepository() {
    _bootstrap();
  }

  GameState get gameState => _gameState;
  bool get bootstrapped => _bootstrapped;

  UserProfile? get profile => _profile;

  bool get needsHeroCreation {
    if (!_bootstrapped) return false;
    final p = _profile;
    if (p == null) return true;
    if (p.hero.name.trim().isEmpty) return true;
    if (p.hero.classId.trim().isEmpty) return true;
    if (p.hero.headId.trim().isEmpty) return true;

    return false;
  }

  // --------- HEAD COSMETIC (cappello/elmo) ---------

  String get equippedHeadCosmeticId {
    final p = _profile;
    if (p == null) return headNone;
    for (final id in p.loadout.extraCosmeticIds) {
      if (id.startsWith('head_')) return id;
    }
    return headNone;
  }

  Future<void> setHeadCosmetic(String headId) async {
    final p = _profile;
    if (p == null) return;

    final normalized = headId.trim().isEmpty ? headNone : headId.trim();

    final currentExtras = p.loadout.extraCosmeticIds;
    final nextExtras = <String>[
      for (final e in currentExtras)
        if (!e.startsWith('head_')) e,
    ];

    if (normalized != headNone) nextExtras.add(normalized);

    final nextLoadout = p.loadout.copyWith(extraCosmeticIds: nextExtras);
    final updated = p.copyWith(loadout: nextLoadout, lastSeenAtMs: _nowMs());

    _profile = updated;
    await _profileRepo.saveProfile(updated);
    notifyListeners();
  }

  // -----------------------------------------------

  static GameState _initialState() {
    return GameState(
      user: UserState(
        name: 'Eroe',
        heroClass: HeroClass.knight,
        level: 1,
        xp: 0,
        crystals: 0,
        avatarUrl: heroImageUrl,
        equippedIds: const [],
      ),
      boss: const BossState(
        name: 'Il Procrastino',
        hp: 85,
        maxHp: 100,
        level: 1,
      ),
      stats: const StatsState(
        tasksCompleted: 0,
        streakDays: 0,
        totalCrystals: 0,
      ),
      activeTaskId: null,
    );
  }


  static List<Task> _initialTasks() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      Task(
        id: '1',
        title: 'Fare 10 flessioni',
        durationMinutes: 5,
        category: TaskCategory.health,
        completed: false,
        createdAtMs: now,
        totalActiveMs: 0,
        status: TaskStatus.idle,
        delayCount: 0,
      ),
      Task(
        id: '2',
        title: 'Leggere 5 pagine',
        durationMinutes: 15,
        category: TaskCategory.study,
        completed: false,
        createdAtMs: now,
        totalActiveMs: 0,
        status: TaskStatus.idle,
        delayCount: 0,
      ),
    ];
  }

  Future<void> _bootstrap() async {
    try {
      final p = await _profileRepo.loadProfile();
      _profile = p;

      if (p != null) {
        _applyProfileToLegacyState(p);
      }
    } catch (_) {
      // ignora
    } finally {
      _bootstrapped = true;
      notifyListeners();
    }
  }

  void _applyProfileToLegacyState(UserProfile p) {
    final mappedClass = _mapClassIdToHeroClass(p.hero.classId);

    _gameState = _gameState.copyWith(
      user: _gameState.user.copyWith(
        name: p.hero.name.isEmpty ? _gameState.user.name : p.hero.name,
        heroClass: mappedClass,
        level: p.level,
        xp: p.xp,
        crystals: p.crystals,
      ),
      activeTaskId: _gameState.activeTaskId,
    );
  }

  HeroClass _mapClassIdToHeroClass(String id) {
    switch (id) {
      case 'mage':
        return HeroClass.mage;
      case 'ninja':
        return HeroClass.ninja;
      case 'dwarf':
        return HeroClass.dwarf;
      case 'healer':
        return HeroClass.healer;
      case 'knight':
      default:
        return HeroClass.knight;
    }
  }


  // ---- task helpers ----
  int _nowMs() => DateTime.now().millisecondsSinceEpoch;
  int requiredMsFor(Task t) => t.durationMinutes * 60 * 1000;

  int totalElapsedMs(Task t) {
    final sessionMs =
    (t.status == TaskStatus.active && t.startTimeMs != null) ? (_nowMs() - t.startTimeMs!) : 0;
    return t.totalActiveMs + max(0, sessionMs);
  }

  int timeLeftMs(Task t) => max(0, requiredMsFor(t) - totalElapsedMs(t));

  Task? get activeTask {
    final id = _gameState.activeTaskId;
    if (id == null) return null;
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ---- tool ----
  void setActiveTool(ActiveTool tool) {
    activeTool = tool;
    notifyListeners();
  }

  // ---- tasks ----
  void addTask({
    required String title,
    required int durationMinutes,
    required TaskCategory category,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final id = _randomId();
    final now = _nowMs();

    final newTask = Task(
      id: id,
      title: trimmed,
      durationMinutes: durationMinutes,
      category: category,
      completed: false,
      createdAtMs: now,
      totalActiveMs: 0,
      status: TaskStatus.idle,
      delayCount: 0,
    );

    tasks = [newTask, ...tasks];
    notifyListeners();
  }

  void toggleStartPauseTask(String taskId) {
    final now = _nowMs();

    tasks = tasks.map((t) {
      if (t.id != taskId) return t;

      if (t.status == TaskStatus.active) {
        final sessionMs = t.startTimeMs == null ? 0 : (now - t.startTimeMs!);
        return t.copyWith(
          status: TaskStatus.paused,
          pausedAtMs: now,
          totalActiveMs: t.totalActiveMs + max(0, sessionMs),
        );
      } else {
        return t.copyWith(
          status: TaskStatus.active,
          startTimeMs: now,
          pausedAtMs: null,
        );
      }
    }).toList();

    final isActivating = _gameState.activeTaskId != taskId;
    _gameState = _gameState.copyWith(activeTaskId: isActivating ? taskId : null);

    activeTool = ActiveTool.none;
    notifyListeners();
  }

  Future<bool> completeTask(String taskId) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx < 0) return false;

    final task = tasks[idx];
    if (task.completed) return false;

    final now = _nowMs();
    final int sessionActiveMs =
    (task.status == TaskStatus.active && task.startTimeMs != null) ? (now - task.startTimeMs!) : 0;

    final int totalMsElapsed = task.totalActiveMs + (sessionActiveMs < 0 ? 0 : sessionActiveMs);
    final requiredMs = requiredMsFor(task);

    if (totalMsElapsed < requiredMs) return false;

    tasks = tasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(
        completed: true,
        status: TaskStatus.idle,
        totalActiveMs: totalMsElapsed,
        startTimeMs: null,
        pausedAtMs: null,
      );
    }).toList();

    _gameState = _gameState.copyWith(activeTaskId: null);

    final equipped = shopItems.where((i) => _gameState.user.equippedIds.contains(i.id)).toList();

    final crystalMultiplier = equipped.fold<double>(
      1.0,
          (acc, curr) => acc * (curr.effect?.multiplier ?? 1.0),
    );
    final extraDamage = equipped.fold<int>(
      0,
          (acc, curr) => acc + (curr.effect?.damageBonus ?? 0),
    );

    final rewardCrystals = (task.durationMinutes * 1.5 * crystalMultiplier).floor();
    final xpGain = task.durationMinutes * 2;

    final damage = 15 + extraDamage;
    var newHp = _gameState.boss.hp - damage;

    var newLevel = _gameState.user.level;
    var newXp = _gameState.user.xp + xpGain;

    if (newXp >= 100) {
      newLevel += 1;
      newXp = 0;
    }

    var bossLevel = _gameState.boss.level;
    var maxHp = _gameState.boss.maxHp;

    if (newHp <= 0) {
      bossLevel += 1;
      maxHp += 20;
      newHp = maxHp;
    }

    _gameState = GameState(
      user: _gameState.user.copyWith(
        xp: newXp,
        level: newLevel,
        crystals: _gameState.user.crystals + rewardCrystals,
      ),
      boss: _gameState.boss.copyWith(
        hp: newHp,
        level: bossLevel,
        maxHp: maxHp,
      ),
      stats: _gameState.stats.copyWith(
        tasksCompleted: _gameState.stats.tasksCompleted + 1,
        totalCrystals: _gameState.stats.totalCrystals + rewardCrystals,
      ),
      activeTaskId: null,
    );

    final p = _profile;
    if (p != null) {
      final updated = p.copyWith(
        crystals: _gameState.user.crystals,
        level: _gameState.user.level,
        xp: _gameState.user.xp,
        lastSeenAtMs: _nowMs(),
      );
      _profile = updated;
      await _profileRepo.saveProfile(updated);
    }

    notifyListeners();
    return true;
  }

  // ---- shop ----
  bool purchase(InventoryItem item) {
    if (_gameState.user.crystals < item.price) return false;

    _gameState = _gameState.copyWith(
      user: _gameState.user.copyWith(crystals: _gameState.user.crystals - item.price),
      activeTaskId: _gameState.activeTaskId,
    );

    if (!unlockedIds.contains(item.id)) {
      unlockedIds = [...unlockedIds, item.id];
    }

    final p = _profile;
    if (p != null) {
      final updated = p.copyWith(
        crystals: _gameState.user.crystals,
        lastSeenAtMs: _nowMs(),
      );
      _profile = updated;
      _profileRepo.saveProfile(updated);
    }

    notifyListeners();
    return true;
  }

  void toggleEquip(String itemId) {
    final equipped = _gameState.user.equippedIds;
    final isEquipped = equipped.contains(itemId);

    final updated = isEquipped ? equipped.where((e) => e != itemId).toList() : [...equipped, itemId];

    _gameState = _gameState.copyWith(
      user: _gameState.user.copyWith(equippedIds: updated),
      activeTaskId: _gameState.activeTaskId,
    );

    notifyListeners();
  }

  // ---- hero/profile creation ----
  Future<void> createHeroAndProfile({
    required String heroName,
    required String classId,
    required String headId,
    required String headPaletteId,
    required String armorPaletteId,
    required String skinPaletteId,
  }) async {

    final now = _nowMs();

    final hero = HeroIdentity(
      name: heroName.trim(),
      classId: classId,
      headId: headId,
      headPaletteId: headPaletteId,
      armorPaletteId: armorPaletteId,
      skinPaletteId: skinPaletteId,
      createdAtMs: now,
    );


    final profile = UserProfile(
      profileId: _randomIdLong(),
      crystals: _gameState.user.crystals,
      level: _gameState.user.level,
      xp: _gameState.user.xp,
      hero: hero,
      loadout: const HeroLoadout(extraCosmeticIds: [headNone]),
      unlockedCosmeticIds: const [],
      lastSeenAtMs: now,
    );

    _profile = profile;
    await _profileRepo.saveProfile(profile);

    _applyProfileToLegacyState(profile);
    notifyListeners();
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _profileRepo.clearProfile();
    notifyListeners();
  }

  // ---- utils ----
  String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(7, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String _randomIdLong() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
  }
}

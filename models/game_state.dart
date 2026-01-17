import 'hero_class.dart';

class UserState {
  final String name;
  final HeroClass heroClass;
  final int level;
  final int xp; // 0..100
  final int crystals;
  final String avatarUrl;
  final List<String> equippedIds;

  const UserState({
    required this.name,
    required this.heroClass,
    required this.level,
    required this.xp,
    required this.crystals,
    required this.avatarUrl,
    required this.equippedIds,
  });

  UserState copyWith({
    String? name,
    HeroClass? heroClass,
    int? level,
    int? xp,
    int? crystals,
    String? avatarUrl,
    List<String>? equippedIds,
  }) {
    return UserState(
      name: name ?? this.name,
      heroClass: heroClass ?? this.heroClass,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      crystals: crystals ?? this.crystals,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      equippedIds: equippedIds ?? this.equippedIds,
    );
  }
}

class BossState {
  final String name;
  final int hp;
  final int maxHp;
  final int level;

  const BossState({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.level,
  });

  BossState copyWith({
    String? name,
    int? hp,
    int? maxHp,
    int? level,
  }) {
    return BossState(
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      level: level ?? this.level,
    );
  }
}

class StatsState {
  final int tasksCompleted;
  final int streakDays;
  final int totalCrystals;

  const StatsState({
    required this.tasksCompleted,
    required this.streakDays,
    required this.totalCrystals,
  });

  StatsState copyWith({
    int? tasksCompleted,
    int? streakDays,
    int? totalCrystals,
  }) {
    return StatsState(
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      streakDays: streakDays ?? this.streakDays,
      totalCrystals: totalCrystals ?? this.totalCrystals,
    );
  }
}

class GameState {
  final UserState user;
  final BossState boss;
  final StatsState stats;
  final String? activeTaskId;

  const GameState({
    required this.user,
    required this.boss,
    required this.stats,
    required this.activeTaskId,
  });

  GameState copyWith({
    UserState? user,
    BossState? boss,
    StatsState? stats,
    String? activeTaskId,
  }) {
    return GameState(
      user: user ?? this.user,
      boss: boss ?? this.boss,
      stats: stats ?? this.stats,
      activeTaskId: activeTaskId,
    );
  }
}

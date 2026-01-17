// lib/ui/app_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/game_store.dart';
import '../models/hero_identity.dart';
import '../models/hero_loadout.dart';
import '../logic/hero/hero_composer.dart';

import 'screens/create_hero_screen.dart';
import 'screens/map_screen.dart';
import 'screens/inv_screen.dart';
import 'screens/guild_screen.dart';
import 'screens/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();

    if (!store.bootstrapped) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (store.needsHeroCreation) {
      return const CreateHeroScreen();
    }

    final user = store.gameState.user;

    // Source of truth: profilo persistente (può essere null per safety).
    final p = store.profile;

    final hero = p?.hero ??
        const HeroIdentity(
          name: '',
          classId: 'warrior',
          headId: 'head_01',
          headPaletteId: '',
          armorPaletteId: 'a1',
          skinPaletteId: 'skin_01',
          createdAtMs: 0,
        );

    // Headwear/cosmetici (se presenti). Se non li usi ancora, resta vuoto.
    const headNone = 'head_none';
    String headwearId = headNone;
    final extras = p?.loadout.extraCosmeticIds ?? const <String>[];
    for (final id in extras) {
      if (id.startsWith('head_')) {
        headwearId = id;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF818CF8), width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: HeroAvatarIcon(
                    hero: hero,
                    headCosmeticId: headwearId,
                    headNoneValue: headNone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LVL ${user.level}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: (user.xp % 100) / 100.0,
                            backgroundColor: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, size: 18, color: Color(0xFF22D3EE)),
                      const SizedBox(width: 6),
                      Text(
                        '${user.crystals}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          MapScreen(),
          InvScreen(),
          GuildScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF818CF8),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mappa'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Zaino'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Gilda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Eroe'),
        ],
      ),
    );
  }
}

class HeroAvatarIcon extends StatefulWidget {
  final HeroIdentity hero;
  final String headCosmeticId;
  final String headNoneValue;

  const HeroAvatarIcon({
    super.key,
    required this.hero,
    required this.headCosmeticId,
    required this.headNoneValue,
  });

  @override
  State<HeroAvatarIcon> createState() => _HeroAvatarIconState();
}

class _HeroAvatarIconState extends State<HeroAvatarIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool get _hasHead => widget.headCosmeticId != widget.headNoneValue;

  @override
  Widget build(BuildContext context) {
    final loadout = HeroLoadout(
      extraCosmeticIds: _hasHead ? <String>[widget.headCosmeticId] : const <String>[],
    );

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final dy = ((_c.value - 0.5) * 3.0);

        return Transform.translate(
          offset: Offset(0, dy),
          child: FittedBox(
            fit: BoxFit.cover,
            child: heroComposer.buildAvatar(
              identity: widget.hero,
              loadout: loadout,
              idleT: 0.0,
            ),
          ),
        );
      },
    );
  }
}

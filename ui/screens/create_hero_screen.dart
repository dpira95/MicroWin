// lib/ui/screens/create_hero_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../store/game_store.dart';
import '../../data/catalog/hero_catalog.dart';
import '../../models/hero_class.dart';
import '../widgets/hero_preview/hero_composite_view.dart';

class CreateHeroScreen extends StatefulWidget {
  const CreateHeroScreen({super.key});

  @override
  State<CreateHeroScreen> createState() => _CreateHeroScreenState();
}

class _CreateHeroScreenState extends State<CreateHeroScreen> {
  final _nameCtrl = TextEditingController();

  String _classId = 'knight';

  // Nuovi campi corretti:
  String _headId = 'head_01';
  String _headPaletteId = ''; // vuoto = base (o fallback alla prima palette disponibile)
  String _armorPaletteId = ''; // verrà normalizzato con le varianti della classe
  String _skinPaletteId = 'skin_01';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  HeroClass _parseHeroClass(String raw) {
    for (final v in HeroClass.values) {
      if (v.name == raw) return v;
    }
    final cleaned = raw.replaceAll('HeroClass.', '');
    for (final v in HeroClass.values) {
      if (v.name == cleaned) return v;
    }
    return HeroClass.knight;
  }

  void _applyClass(String id) {
    final hc = _parseHeroClass(id);

    final armorIds = heroCatalog.armorVariantIdsForClass(hc);
    final newArmor = armorIds.isNotEmpty ? armorIds.first : '';

    setState(() {
      _classId = id;
      _armorPaletteId = newArmor;
      // head e palette restano, perché sono globali.
    });
  }

  void _applyHead(String headId) {
    final palettes = heroCatalog.headPaletteIdsForHead(headId);
    setState(() {
      _headId = headId;
      _headPaletteId = palettes.isNotEmpty ? palettes.first : '';
    });
  }

  void _applyHeadPalette(String paletteId) {
    setState(() => _headPaletteId = paletteId);
  }

  void _applyArmorVariant(String armorId) {
    setState(() => _armorPaletteId = armorId);
  }

  Future<void> _confirm() async {
    final store = context.read<GameStore>();

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un nome')),
      );
      return;
    }

    await store.createHeroAndProfile(
      heroName: name,
      classId: _classId,
      headId: _headId,
      headPaletteId: _headPaletteId,
      armorPaletteId: _armorPaletteId,
      skinPaletteId: _skinPaletteId,
    );
  }

  IconData _classIcon(String id) {
    switch (id) {
      case 'mage':
        return Icons.auto_fix_high;
      case 'ninja':
        return Icons.visibility_off;
      case 'dwarf':
        return Icons.construction;
      case 'healer':
        return Icons.local_hospital;
      case 'knight':
      default:
        return Icons.shield;
    }
  }

  Widget _choiceChip({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B1220) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF818CF8) : const Color(0xFF334155),
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hc = _parseHeroClass(_classId);

    final headIds = heroCatalog.allHeadIds;
    if (headIds.isNotEmpty && !headIds.contains(_headId)) {
      _headId = headIds.first;
    }

    final headPalettes = heroCatalog.headPaletteIdsForHead(_headId);
    final armorIds = heroCatalog.armorVariantIdsForClass(hc);

    // Normalizzazione armor selezionata
    final resolvedArmor = armorIds.isNotEmpty
        ? (armorIds.contains(_armorPaletteId) ? _armorPaletteId : armorIds.first)
        : '';

    // Normalizzazione head palette selezionata
    final resolvedHeadPalette = headPalettes.isEmpty
        ? ''
        : (headPalettes.contains(_headPaletteId) ? _headPaletteId : headPalettes.first);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Crea il tuo personaggio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Classe e aspetto base non saranno modificabili in seguito.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),

            // Preview reale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1220),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155), width: 2),
                ),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // Avatar
                    HeroCompositeView(
                      classId: _classId,
                      headId: _headId,
                      headPaletteId: resolvedHeadPalette,
                      armorPaletteId: resolvedArmor,
                      skinPaletteId: _skinPaletteId,
                    ),

                    // Etichetta piccola overlay (debug utile)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          '$_classId • $_headId • ${resolvedHeadPalette.isEmpty ? "base" : resolvedHeadPalette}\n$resolvedArmor • $_skinPaletteId',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Form scrollabile
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'NOME',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text('CLASSE', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final id in const ['knight', 'mage', 'ninja', 'dwarf', 'healer'])
                              _choiceChip(
                                selected: _classId == id,
                                onTap: () => _applyClass(id),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(_classIcon(id), color: Colors.white70),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text('HEAD', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final id in headIds)
                              _choiceChip(
                                selected: _headId == id,
                                onTap: () => _applyHead(id),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Center(
                                    child: Text(
                                      id.replaceAll('head_', ''),
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text('HEAD PALETTE', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        if (headPalettes.isEmpty)
                          const Text(
                            'Nessuna palette per questa head (usa la base).',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final pid in headPalettes)
                                _choiceChip(
                                  selected: resolvedHeadPalette == pid,
                                  onTap: () => _applyHeadPalette(pid),
                                  child: SizedBox(
                                    width: 64,
                                    height: 52,
                                    child: Center(
                                      child: Text(
                                        pid.split('_').last.replaceAll('p', ''),
                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        const Text('VARIANTE ARMATURA', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        if (armorIds.isEmpty)
                          const Text(
                            'Nessuna variante armatura disponibile per questa classe.',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final aid in armorIds)
                                _choiceChip(
                                  selected: resolvedArmor == aid,
                                  onTap: () => _applyArmorVariant(aid),
                                  child: SizedBox(
                                    width: 96,
                                    height: 52,
                                    child: Center(
                                      child: Text(
                                        aid.split('_').last.toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        const Text('SKIN PALETTE', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: [
                            for (final id in const ['skin_01', 'skin_02', 'skin_03'])
                              _choiceChip(
                                selected: _skinPaletteId == id,
                                onTap: () => setState(() => _skinPaletteId = id),
                                child: SizedBox(
                                  width: 64,
                                  height: 52,
                                  child: Center(
                                    child: Text(
                                      id.replaceAll('skin_', ''),
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirm,
                            child: const Text('CONFERMA'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

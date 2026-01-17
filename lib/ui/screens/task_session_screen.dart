import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/constants.dart';
import '../../logic/hero/hero_composer.dart';
import '../../models/active_tool.dart';
import '../../models/hero_identity.dart';
import '../../models/hero_loadout.dart';
import '../../store/game_store.dart';
import '../widgets/tool_panels.dart';

class TaskSessionScreen extends StatefulWidget {
  const TaskSessionScreen({super.key});

  @override
  State<TaskSessionScreen> createState() => _TaskSessionScreenState();
}

class _TaskSessionScreenState extends State<TaskSessionScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final task = store.activeTask;

    if (task == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: SafeArea(
          child: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Torna'),
            ),
          ),
        ),
      );
    }

    final leftMs = store.timeLeftMs(task);
    final totalMs = store.requiredMsFor(task);
    final progress =
    totalMs == 0 ? 1.0 : (1.0 - (leftMs / totalMs)).clamp(0.0, 1.0);

    final leftSec = (leftMs / 1000).ceil();
    final leftMin = (leftSec / 60).floor();
    final secR = leftSec % 60;
    final timerText =
        '${leftMin.toString().padLeft(2, '0')}:${secR.toString().padLeft(2, '0')}';

    final enemy = enemySprites[task.category.index % enemySprites.length];
    final canWin = leftMs <= 0;

    final activeTool = store.activeTool;
    final isFiles = activeTool == ActiveTool.explorer;
    final profile = store.profile;
    final hero = profile?.hero ??
        const HeroIdentity(
          name: '',
          classId: 'knight',
          headId: 'head_01',
          headPaletteId: '',
          armorPaletteId: '',
          skinPaletteId: 'skin_01',
          createdAtMs: 0,
        );
    final loadout = profile?.loadout ?? const HeroLoadout(extraCosmeticIds: []);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: task.title,
              onHome: () {
                store.toggleStartPauseTask(task.id);
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timerText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          enemy.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 10,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // 0) Keep PDF state alive
                    pdfStateKeeper(),

                    // 1) Arena
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  Text(
                                    enemy.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: canWin
                                        ? () async {
                                            final ok = await store.completeTask(task.id);
                                            if (ok && context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        : null,
                                    child: const Text('VITTORIA'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 8,
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: heroComposer.buildAvatar(
                                identity: hero,
                                loadout: loadout,
                                idleT: 0.0,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(enemy.sprite, style: const TextStyle(fontSize: 64)),
                                const SizedBox(height: 4),
                                Text(
                                  enemy.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2) Tool panel bottom (NON per Files)
                    if (activeTool != ActiveTool.none && !isFiles)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: buildToolPanel(
                          activeTool,
                              () => store.setActiveTool(ActiveTool.none),
                        ),
                      ),

                    // 3) PDF overlay SEMPRE montato
                    PdfFullscreenOverlay(
                      show: isFiles,
                      onMinimize: () => store.setActiveTool(ActiveTool.none),
                      onRequestClosePdf: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Chiudere il PDF?'),
                            content: const Text(
                              'Se chiudi, il PDF verrà rimosso e dovrai riaprirlo.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Sì'),
                              ),
                            ],
                          ),
                        );
                        return ok == true;
                      },
                    ),
                  ],
                ),
              ),
            ),
            _ToolBar(
              activeTool: activeTool,
              onTap: (tool) {
                store.setActiveTool(activeTool == tool ? ActiveTool.none : tool);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onHome;

  const _TopBar({required this.title, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 2),
        ),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onHome, icon: const Icon(Icons.home)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBar extends StatelessWidget {
  final ActiveTool activeTool;
  final void Function(ActiveTool tool) onTap;

  const _ToolBar({required this.activeTool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget toolBtn(IconData icon, String label, ActiveTool tool) {
      final selected = activeTool == tool;
      return Expanded(
        child: InkWell(
          onTap: () => onTap(tool),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0B1220)
                  : const Color(0xFF1E293B),
              border: const Border(
                top: BorderSide(color: Color(0xFF334155), width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        toolBtn(Icons.calculate, 'Calc', ActiveTool.calculator),
        toolBtn(Icons.dialpad, 'Dial', ActiveTool.dialer),
        toolBtn(Icons.folder, 'Files', ActiveTool.explorer),
        toolBtn(Icons.music_note, 'Music', ActiveTool.music),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../store/game_store.dart';
import 'task_session_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final tasks = store.tasks.where((t) => !t.completed).toList();

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: tasks.length,
          itemBuilder: (context, i) {
            final t = tasks[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155), width: 2),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(t.status.name == 'active' ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      store.toggleStartPauseTask(t.id);
                      if (store.gameState.activeTaskId == t.id) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TaskSessionScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          '${t.durationMinutes}m • ${t.category.name} • ${t.status.name}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'store/game_store.dart';
import 'ui/app_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameStore(),
      child: const MicroWinApp(),
    ),
  );
}

class MicroWinApp extends StatelessWidget {
  const MicroWinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MicroWin',
      theme: ThemeData.dark(useMaterial3: true),
      home: const AppShell(),
    );
  }
}

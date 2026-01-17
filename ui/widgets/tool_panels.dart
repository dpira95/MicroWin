// lib/ui/widgets/tool_panels.dart
import 'package:flutter/material.dart';

import '../../models/active_tool.dart';
import 'calculator_panel.dart';
import 'dialer_panel.dart';
import 'pdf_panel.dart';

final GlobalKey<PdfPanelState> _pdfKey = GlobalKey<PdfPanelState>();

Widget pdfStateKeeper() {
  return IgnorePointer(
    ignoring: true,
    child: Offstage(
      offstage: true,
      child: PdfPanel(key: _pdfKey),
    ),
  );
}

Widget buildToolPanel(ActiveTool tool, VoidCallback onClose) {
  Widget wrap(String title, double h, Widget body) {
    return Container(
      height: h,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1220),
        border: Border(
          top: BorderSide(color: Color(0xFF334155), width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: body),
        ],
      ),
    );
  }

  switch (tool) {
    case ActiveTool.calculator:
      return wrap('Calculator', 440, CalculatorPanel(onClose: onClose));
    case ActiveTool.dialer:
      return wrap('Dialer', 520, DialerPanel(onClose: onClose));

    case ActiveTool.explorer:
      return wrap('Files', 220, const _PdfLauncherBody());
    case ActiveTool.music:
      return wrap('Music Player', 240, const _MusicBody());
    case ActiveTool.none:
      return const SizedBox.shrink();
  }
}

class _PdfLauncherBody extends StatefulWidget {
  const _PdfLauncherBody();

  @override
  State<_PdfLauncherBody> createState() => _PdfLauncherBodyState();
}

class _PdfLauncherBodyState extends State<_PdfLauncherBody> {
  @override
  Widget build(BuildContext context) {
    final state = _pdfKey.currentState;

    final fileLabel = state?.fileNameOrPlaceholder ?? 'Nessun PDF selezionato';
    final pageLabel = state?.pageLabel ?? '';
    final hasSelected = state?.hasSelectedPdf ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fileLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _pdfKey.currentState?.pickPdf();
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(hasSelected ? 'Cambia PDF' : 'Scegli PDF'),
              ),
            ),
            const SizedBox(width: 10),
            if (pageLabel.isNotEmpty)
              Text(pageLabel, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Apri Files per visualizzare a schermo intero.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}

class _MusicBody extends StatelessWidget {
  const _MusicBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Placeholder music player', style: TextStyle(color: Colors.white54)),
    );
  }
}

/// Overlay fullscreen PDF sempre montato.
/// (3) su rientro: reload stesso file + pagina, poi rebuild del renderer via Key.
class PdfFullscreenOverlay extends StatefulWidget {
  final bool show;
  final VoidCallback onMinimize;
  final Future<bool> Function() onRequestClosePdf;

  const PdfFullscreenOverlay({
    super.key,
    required this.show,
    required this.onMinimize,
    required this.onRequestClosePdf,
  });

  @override
  State<PdfFullscreenOverlay> createState() => _PdfFullscreenOverlayState();
}

class _PdfFullscreenOverlayState extends State<PdfFullscreenOverlay> {
  int _viewerEpoch = 0;
  bool _wasShown = false;
  bool _reloading = false;

  @override
  void didUpdateWidget(covariant PdfFullscreenOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nowShown = widget.show;
    if (nowShown && !_wasShown) {
      _onEnterFiles();
    }
    _wasShown = nowShown;
  }

  void _onEnterFiles() {
    final state = _pdfKey.currentState;
    if (state == null) {
      setState(() => _viewerEpoch++);
      return;
    }

    // Se non c'è un PDF selezionato, non ricaricare nulla.
    if (!state.hasSelectedPdf) {
      setState(() => _viewerEpoch++);
      return;
    }

    // Ricarica file e pagina.
    setState(() {
      _reloading = true;
    });

    state.reloadKeepingPage().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _reloading = false;
        _viewerEpoch++; // forza ricostruzione renderer
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _pdfKey.currentState;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !widget.show,
        child: AnimatedOpacity(
          opacity: widget.show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 120),
          child: Material(
            color: const Color(0xFF020617),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B1220),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF334155), width: 2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state?.fileNameOrPlaceholder ?? 'PDF',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(state?.pageLabel ?? '', style: const TextStyle(color: Colors.white70)),
                        if (_reloading) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                        IconButton(
                          tooltip: 'Nascondi',
                          onPressed: widget.onMinimize,
                          icon: const Icon(Icons.minimize),
                        ),
                        IconButton(
                          tooltip: 'Chiudi PDF',
                          onPressed: (state?.hasSelectedPdf ?? false)
                              ? () async {
                            final ok = await widget.onRequestClosePdf();
                            if (ok) {
                              state?.clearPdf();
                              widget.onMinimize();
                            }
                          }
                              : null,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: (state == null)
                        ? const SizedBox.shrink()
                        : (state.hasSelectedPdf
                        ? state.buildPdfView(viewerKey: ValueKey<int>(_viewerEpoch))
                        : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Nessun PDF selezionato.', style: TextStyle(color: Colors.white54)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await state.pickPdf();
                                  if (!mounted) return;
                                  setState(() => _viewerEpoch++);
                                },
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Scegli un PDF'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

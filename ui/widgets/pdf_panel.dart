// lib/ui/widgets/pdf_panel.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfPanel extends StatefulWidget {
  const PdfPanel({super.key});

  @override
  PdfPanelState createState() => PdfPanelState();
}

class PdfPanelState extends State<PdfPanel> with AutomaticKeepAliveClientMixin {
  PdfControllerPinch? _controller;
  String? _path;
  String? _error;
  bool _busy = false;

  int? _pagesTotal;
  int? _pageCurrent; // 1-based

  @override
  bool get wantKeepAlive => true;

  bool get hasOpenPdf => _controller != null && _path != null && _error == null;

  bool get hasSelectedPdf => _path != null && _path!.isNotEmpty;

  String get fileNameOrPlaceholder {
    if (_path == null) return 'Nessun PDF selezionato';
    final sep = Platform.pathSeparator;
    final idx = _path!.lastIndexOf(sep);
    return idx >= 0 ? _path!.substring(idx + 1) : _path!;
  }

  String get pageLabel {
    if (_pageCurrent == null) return '';
    if (_pagesTotal == null) return '$_pageCurrent';
    return '$_pageCurrent / $_pagesTotal';
  }

  int get savedPageOr1 => (_pageCurrent == null || _pageCurrent! < 1) ? 1 : _pageCurrent!;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> pickPdf() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: false,
      );

      if (result == null) return;

      final p = result.files.single.path;
      if (p == null || p.isEmpty) {
        setState(() => _error = 'File non valido');
        return;
      }

      final f = File(p);
      if (!await f.exists()) {
        setState(() => _error = 'File non trovato');
        return;
      }

      _path = p;
      _pageCurrent = 1;

      await _openFromPathKeepingPage(); // apre e inizializza controller + pagesCount
    } catch (_) {
      setState(() => _error = 'Errore selezione PDF');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void clearPdf() {
    _controller?.dispose();
    _controller = null;
    _path = null;
    _error = null;
    _busy = false;
    _pagesTotal = null;
    _pageCurrent = null;
    if (mounted) setState(() {});
  }

  /// === SOLUZIONE (3) ===
  /// Chiamala quando rientri su Files:
  /// - se c'è un path selezionato, ricarica il documento
  /// - ripristina la pagina corrente salvata
  Future<void> reloadKeepingPage() async {
    if (_busy) return;
    if (!hasSelectedPdf) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _openFromPathKeepingPage();
    } catch (_) {
      if (mounted) setState(() => _error = 'Errore ricarica PDF');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openFromPathKeepingPage() async {
    final p = _path;
    if (p == null || p.isEmpty) return;

    final file = File(p);
    if (!await file.exists()) {
      setState(() => _error = 'File non trovato');
      return;
    }

    final pageToRestore = savedPageOr1;

    // chiude controller precedente (anche se "vive", lo ricreiamo apposta)
    _controller?.dispose();
    _controller = null;

    // PdfControllerPinch usa Future<PdfDocument>; per pagesCount leggiamo il doc una volta
    final docFuture = PdfDocument.openFile(p);
    final doc = await docFuture;
    _pagesTotal = doc.pagesCount;

    // clamp pagina
    final safePage = pageToRestore.clamp(1, _pagesTotal ?? pageToRestore);

    _controller = PdfControllerPinch(
      document: docFuture,
      initialPage: safePage,
    );

    // aggiorna stato pagina
    setState(() {
      _error = null;
      _pageCurrent = safePage;
    });

    // alcuni device non rispettano initialPage: dopo il primo frame riprova jump
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        (_controller as dynamic).jumpToPage(safePage);
      } catch (_) {
        try {
          (_controller as dynamic).animateToPage(safePage);
        } catch (_) {}
      }
    });
  }

  /// Viewer costruito nell’overlay fullscreen.
  /// viewerKey serve per forzare la ricostruzione del renderer.
  Widget buildPdfView({Key? viewerKey}) {
    if (_busy && !hasOpenPdf) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!hasOpenPdf) {
      return Center(
        child: Text(
          _error ?? 'Scegli un PDF (dal pannello Files).',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F172A),
      child: PdfViewPinch(
        key: viewerKey,
        controller: _controller!,
        onDocumentError: (_) {
          if (!mounted) return;
          setState(() => _error = 'PDF non valido');
        },
        onPageChanged: (int page) {
          if (!mounted) return;
          setState(() => _pageCurrent = page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // State keeper: non renderizza UI qui.
    return const SizedBox.shrink();
  }
}

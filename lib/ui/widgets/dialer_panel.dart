import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class DialerPanel extends StatefulWidget {
  final VoidCallback onClose;
  const DialerPanel({super.key, required this.onClose});

  @override
  State<DialerPanel> createState() => _DialerPanelState();
}

class _DialerPanelState extends State<DialerPanel> {
  final _numberCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool _loading = false;
  bool _granted = false;
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];

  @override
  void initState() {
    super.initState();
    _initContacts();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initContacts() async {
    setState(() => _loading = true);
    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);
      _granted = granted;

      if (!granted) {
        setState(() => _loading = false);
        return;
      }

      final list = await FlutterContacts.getContacts(
        withProperties: true, // numeri
        withThumbnail: false,
        withPhoto: false,
      );

      _contacts = list;
      _filtered = list;
    } catch (_) {
      // ignora: gestiamo con UI
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = _contacts);
      return;
    }

    setState(() {
      _filtered = _contacts.where((c) {
        final name = c.displayName.toLowerCase();
        final hasName = name.contains(q);
        final hasPhone = c.phones.any((p) => (p.number).replaceAll(' ', '').contains(q.replaceAll(' ', '')));
        return hasName || hasPhone;
      }).toList();
    });
  }

  void _pickNumberFrom(Contact c) {
    if (c.phones.isEmpty) return;
    final n = c.phones.first.number.trim(); // semplice: primo numero
    _numberCtrl.text = n;
    setState(() {});
  }

  Future<void> _openDialer() async {
    final raw = _numberCtrl.text.trim();
    if (raw.isEmpty) return;

    final number = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: number);

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Header lo gestisce _ToolPanel, qui solo contenuto.
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_granted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Permesso contatti negato.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _initContacts,
            child: const Text('RICHIEDI PERMESSO'),
          ),
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: _numberCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Numero',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openDialer,
            child: const Text('CHIAMA'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Cerca contatto (nome o numero)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF334155), width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF0F172A),
            ),
            child: _filtered.isEmpty
                ? const Center(child: Text('Nessun contatto', style: TextStyle(color: Colors.white54)))
                : ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF334155)),
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
                return ListTile(
                  dense: true,
                  title: Text(
                    c.displayName.isEmpty ? '(Senza nome)' : c.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: phone.isEmpty
                      ? const Text('Nessun numero', style: TextStyle(color: Colors.white54))
                      : Text(phone, style: const TextStyle(color: Colors.white54)),
                  onTap: phone.isEmpty ? null : () => _pickNumberFrom(c),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

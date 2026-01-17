import 'package:flutter/material.dart';

class CalculatorPanel extends StatefulWidget {
  /// Non usato più per l’header (lo fa _ToolPanel), ma lo lasciamo per compatibilità
  /// così non devi toccare altri file.
  final VoidCallback onClose;
  const CalculatorPanel({super.key, required this.onClose});

  @override
  State<CalculatorPanel> createState() => _CalculatorPanelState();
}

class _CalculatorPanelState extends State<CalculatorPanel> {
  final _controller = TextEditingController(text: '0');
  String _expr = '';
  String _last = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(String v) => setState(() => _controller.text = v);

  void _append(String s) {
    setState(() {
      if (_controller.text == '0' && RegExp(r'^[0-9]$').hasMatch(s)) {
        _controller.text = s;
      } else {
        _controller.text += s;
      }
    });
  }

  void _clear() => _set('0');

  void _backspace() {
    setState(() {
      final t = _controller.text;
      if (t.length <= 1) {
        _controller.text = '0';
      } else {
        _controller.text = t.substring(0, t.length - 1);
      }
    });
  }

  double? _tryParse(String s) => double.tryParse(s.replaceAll(',', '.'));

  // eval minimale: + - * / senza parentesi, left-to-right con precedenza * /
  String _eval(String input) {
    final sanitized = input.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = <String>[];
    final buf = StringBuffer();

    for (int i = 0; i < sanitized.length; i++) {
      final c = sanitized[i];
      if ('+-*/'.contains(c)) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }
        tokens.add(c);
      } else if (c != ' ') {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty) tokens.add(buf.toString());
    if (tokens.isEmpty) return '0';

    // first pass: * /
    final pass1 = <String>[];
    int i = 0;
    while (i < tokens.length) {
      final t = tokens[i];
      if (t == '*' || t == '/') {
        final a = _tryParse(pass1.removeLast());
        final b = (i + 1 < tokens.length) ? _tryParse(tokens[i + 1]) : null;
        if (a == null || b == null) return 'Err';
        final r = (t == '*') ? (a * b) : (a / b);
        pass1.add(r.toString());
        i += 2;
      } else {
        pass1.add(t);
        i++;
      }
    }

    // second pass: + -
    double acc = _tryParse(pass1[0]) ?? double.nan;
    if (acc.isNaN) return 'Err';

    i = 1;
    while (i < pass1.length) {
      final op = pass1[i];
      final b = (i + 1 < pass1.length) ? _tryParse(pass1[i + 1]) : null;
      if (b == null) return 'Err';
      if (op == '+') acc += b;
      if (op == '-') acc -= b;
      i += 2;
    }

    if (acc.isInfinite || acc.isNaN) return 'Err';
    final asInt = acc.truncateToDouble() == acc;
    return asInt ? acc.toInt().toString() : acc.toString();
  }

  void _press(String k) {
    final t = _controller.text;

    switch (k) {
      case 'C':
        _clear();
        return;
      case '⌫':
        _backspace();
        return;
      case '=':
        _expr = t;
        _last = _eval(t);
        _set(_last);
        return;
      case '+':
      case '-':
      case '×':
      case '÷':
        if (t.isNotEmpty && '+-×÷'.contains(t[t.length - 1])) return;
        _append(k);
        return;
      case '.':
        final parts = t.split(RegExp(r'[+\-×÷]'));
        if (parts.isNotEmpty && parts.last.contains('.')) return;
        _append('.');
        return;
      default:
        _append(k);
        return;
    }
  }

  Widget _btn(String label, {bool wide = false}) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(4), // più compatto
        child: ElevatedButton(
          onPressed: () => _press(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12), // più compatto
            backgroundColor: const Color(0xFF111827),
            foregroundColor: const Color(0xFFE5E7EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFF334155), width: 1.5),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scroll per evitare overflow in pannelli bassi
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10), // più compatto
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expr.isNotEmpty)
                  Text(_expr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  _controller.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(children: [_btn('C'), _btn('⌫'), _btn('÷'), _btn('×')]),
          Row(children: [_btn('7'), _btn('8'), _btn('9'), _btn('-')]),
          Row(children: [_btn('4'), _btn('5'), _btn('6'), _btn('+')]),
          Row(children: [_btn('1'), _btn('2'), _btn('3'), _btn('=')]),
          Row(children: [_btn('0', wide: true), _btn('.'), _btn('=')]),
        ],
      ),
    );
  }
}

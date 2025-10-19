import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/dynamic_models.dart';

typedef FieldRenderer = Widget Function(FieldSchema field, dynamic value);

class DynamicRenderer {
  final Map<String, FieldRenderer> _typeRenderers = {};
  final FieldRenderer _fallback;

  DynamicRenderer({FieldRenderer? fallback})
      : _fallback = fallback ?? ((f, v) => _defaultFallback(f, v)) {
    registerRenderer('int', (f, v) => Text(v?.toString() ?? '-'));
    registerRenderer('string', (f, v) => Text(v?.toString() ?? '-'));
    registerRenderer('bool', (f, v) => Text((v == true) ? 'Bəli' : 'Xeyr'));
    registerRenderer('enum', (f, v) => Text(v?.toString() ?? '-'));
    registerRenderer('list', (f, v) => _renderList(f, v));
    registerRenderer('object', (f, v) => _renderObject(f, v));
    registerRenderer('datetime', (f, v) => Text(_formatDate(v)));
    registerRenderer('geo', (f, v) => Text(_formatGeo(v)));
  }

  static Widget _defaultFallback(FieldSchema f, dynamic v) {
    final pretty = v == null ? '-' : const JsonEncoder.withIndent('  ').convert(v);
    return _CollapsibleJson(label: f.label, jsonText: pretty, extras: f.extras);
  }

  void registerRenderer(String typeOrKey, FieldRenderer renderer) {
    _typeRenderers[typeOrKey] = renderer;
  }

  Widget render(FieldSchema field, dynamic value) {
    final key = field.widgetHint ?? field.type;
    final renderer = _typeRenderers[key];
    if (renderer != null) return renderer(field, value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Unknown field type: ${field.type}',
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
        const SizedBox(height: 6),
        _fallback(field, value),
      ],
    );
  }

  static Widget _renderList(FieldSchema f, dynamic v) {
    if (v == null) return const Text('-');
    if (v is List) {
      if (f.itemType == 'string' || f.itemType == 'int' || f.itemType == null) {
        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: v.map<Widget>((e) => Chip(label: Text(e.toString()))).toList(),
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: v.map<Widget>((e) {
            if (e is Map) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: e.entries.map((en) => Text('${en.key}: ${en.value}')).toList()),
                ),
              );
            } else {
              return Text(e.toString());
            }
          }).toList(),
        );
      }
    }
    return Text(v.toString());
  }

  static Widget _renderObject(FieldSchema f, dynamic v) {
    if (v == null) return const Text('-');
    if (v is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: v.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
      );
    }
    return Text(v.toString());
  }

  static String _formatDate(dynamic v) {
    if (v == null) return '-';
    try {
      final dt = DateTime.parse(v.toString()).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm';
    } catch (_) {
      return v.toString();
    }
  }

  static String _formatGeo(dynamic v) {
    if (v is Map && v.containsKey('lat') && v.containsKey('lng')) {
      return 'lat: ${v['lat']}, lng: ${v['lng']}';
    }
    return v?.toString() ?? '-';
  }
}

class _CollapsibleJson extends StatefulWidget {
  final String label;
  final String jsonText;
  final Map<String, dynamic> extras;
  const _CollapsibleJson({required this.label, required this.jsonText, required this.extras, super.key});

  @override
  State<_CollapsibleJson> createState() => _CollapsibleJsonState();
}

class _CollapsibleJsonState extends State<_CollapsibleJson> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
              const SizedBox(width: 6),
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (expanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(widget.jsonText, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
        if (widget.extras.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Schema extras: ${widget.extras.keys.join(', ')}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
      ],
    );
  }
}
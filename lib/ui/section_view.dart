import 'package:flutter/material.dart';
import '../models/dynamic_models.dart';
import 'dynamic_renderer.dart';
import '../widgets/responsive_chip.dart';
import '../repositories/dynamic_repository.dart';

class SectionView extends StatefulWidget {
  final List<DynamicSection> sections;
  final String? selectedSectionId;
  final void Function(String?) onSelectSection;
  final DynamicRepository repository;

  const SectionView({
    Key? key,
    required this.sections,
    required this.selectedSectionId,
    required this.onSelectSection,
    required this.repository,
  }) : super(key: key);

  @override
  State<SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<SectionView> {
  late final DynamicRenderer renderer;
  Map<String, Map<dynamic, String>> lookupCache = {};

  @override
  void initState() {
    super.initState();
    renderer = DynamicRenderer();
    renderer.registerRenderer('rating', (f, v) {
      final int count = (v is int) ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (_) => const Icon(Icons.star, size: 16)),
      );
    });
  }

  Future<void> _ensureLookup(String entity) async {
    if (lookupCache.containsKey(entity)) return;
    final list = await widget.repository.fetchLookup(entity);
    final map = <dynamic, String>{};
    for (final e in list) {
      map[e['id']] = e['name']?.toString() ?? e['id'].toString();
    }
    lookupCache[entity] = map;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    if (sections.isEmpty) {
      return const Center(child: Text('Bu istifadəçi üçün heç bir bölmə yoxdur'));
    }

    final selectedId = widget.selectedSectionId ?? sections.first.id;
    final section = sections.firstWhere((s) => s.id == selectedId, orElse: () => sections.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedId,
          items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
          onChanged: widget.onSelectSection,
        ),
        const SizedBox(height: 8),
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              final item = section.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(_primaryLabel(section, item)),
                  subtitle: _buildSubtitle(section, item),
                  onTap: () => _showItemDetails(context, section, item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _primaryLabel(DynamicSection section, Map<String, dynamic> item) {
    if (item.containsKey('name')) return item['name'].toString();
    if (item.containsKey('title')) return item['title'].toString();
    if (item.containsKey('brand')) return item['brand'].toString();
    if (item.containsKey('value')) return item['value'].toString();
    return 'ID: ${item['id'] ?? '-'}';
  }

  Widget? _buildSubtitle(DynamicSection section, Map<String, dynamic> item) {
    final keys = section.schema.map((s) => s.key).where((k) => k != 'id').toList();
    final show = keys.take(2).toList();
    if (show.isEmpty) return null;
    final parts = show.map((k) {
      final v = item[k];
      if (v is List) {
        return ResponsiveChip.wrapFromList(v);
      } else {
        return Text('$k: ${v?.toString() ?? '-'}');
      }
    }).toList();

    if (parts.isNotEmpty && parts.first is! Text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((w) => w).toList(),
      );
    } else {
      return Text(show.map((k) => '$k: ${item[k] ?? '-'}').join('  •  '));
    }
  }

  void _showItemDetails(BuildContext context, DynamicSection section, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  ...section.schema.map((field) {
                    final val = item[field.key];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(field.label)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _renderField(field, val, section, item),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _renderField(FieldSchema field, dynamic value, DynamicSection section, Map<String, dynamic> item) {
    if (field.type == 'relation' && field.relationEntity != null) {
      _ensureLookup(field.relationEntity!);
      final map = lookupCache[field.relationEntity!] ?? {};
      final name = map[value] ?? value?.toString() ?? '-';
      return Text(name);
    }

    if (field.type == 'list' && field.itemType == 'string' && value is List) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: value.map<Widget>((e) => Chip(label: Text(e.toString()))).toList(),
      );
    }

    return renderer.render(field, value);
  }
}
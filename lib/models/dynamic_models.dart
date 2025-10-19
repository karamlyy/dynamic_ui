class FieldSchema {
  final String key;
  final String label;
  final String type;
  final List<dynamic>? options;
  final String? relationEntity;
  final String? itemType;
  final String? widgetHint;
  final bool required;
  final Map<String, dynamic> extras;

  FieldSchema({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.relationEntity,
    this.itemType,
    this.widgetHint,
    this.required = false,
    this.extras = const {},
  });

  factory FieldSchema.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final knownKeys = {
      'key', 'label', 'type', 'options', 'relationEntity', 'itemType', 'widgetHint', 'required'
    };
    final extras = <String, dynamic>{};
    for (final k in map.keys) {
      if (!knownKeys.contains(k)) extras[k] = map[k];
    }

    return FieldSchema(
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? map['key']?.toString() ?? '',
      type: map['type']?.toString() ?? 'string',
      options: (map['options'] as List<dynamic>?)?.toList(),
      relationEntity: map['relationEntity']?.toString(),
      itemType: map['itemType']?.toString(),
      widgetHint: map['widgetHint']?.toString(),
      required: map['required'] as bool? ?? false,
      extras: extras,
    );
  }
}

class DynamicSection {
  final String id;
  final String title;
  final List<FieldSchema> schema;
  final List<Map<String, dynamic>> items;

  DynamicSection({
    required this.id,
    required this.title,
    required this.schema,
    required this.items,
  });

  factory DynamicSection.fromJson(Map<String, dynamic> json) {
    final schemaJson = (json['schema'] as List<dynamic>?) ?? [];
    final itemsJson = (json['items'] as List<dynamic>?) ?? [];

    return DynamicSection(
      id: json['id']?.toString() ?? 'unknown',
      title: json['title']?.toString() ?? json['id']?.toString() ?? 'unknown',
      schema: schemaJson
          .map((s) => FieldSchema.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
      items: itemsJson
          .map((i) => Map<String, dynamic>.from(i))
          .toList(),
    );
  }
}
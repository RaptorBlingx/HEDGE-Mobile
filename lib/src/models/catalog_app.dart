class CatalogApp {
  const CatalogApp({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.inputDatasets,
    required this.outputDatasets,
    required this.sarefType,
    required this.version,
    required this.publisher,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<String> inputDatasets;
  final List<String> outputDatasets;
  final String sarefType;
  final String version;
  final String publisher;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get summary {
    final compact = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 140) {
      return compact;
    }
    return '${compact.substring(0, 137)}...';
  }

  factory CatalogApp.fromJson(Map<String, dynamic> json) {
    return CatalogApp(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled app',
      description: json['description']?.toString() ?? '',
      tags: _asStringList(json['tags']),
      inputDatasets: _asStringList(json['input_datasets']),
      outputDatasets: _asStringList(json['output_datasets']),
      sarefType: json['saref_type']?.toString() ?? 'General',
      version: json['version']?.toString() ?? '1.0.0',
      publisher: json['publisher']?.toString() ?? 'Unknown publisher',
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  static List<String> _asStringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return value.map((Object? item) => item?.toString() ?? '').where((String item) => item.isNotEmpty).toList();
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

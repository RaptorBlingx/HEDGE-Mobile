import 'catalog_app.dart';

class RecommendedApp {
  const RecommendedApp({
    required this.app,
    required this.score,
    this.explanation,
    this.vectorScore,
    this.keywordScore,
    this.sarefBoost,
  });

  final CatalogApp app;
  final double score;
  final String? explanation;
  final double? vectorScore;
  final double? keywordScore;
  final double? sarefBoost;

  factory RecommendedApp.fromJson(Map<String, dynamic> json) {
    return RecommendedApp(
      app: CatalogApp.fromJson(_asMap(json['app'])),
      score: _asDouble(json['score']),
      explanation: json['explanation']?.toString(),
      vectorScore: _asNullableDouble(json['vector_score']),
      keywordScore: _asNullableDouble(json['keyword_score']),
      sarefBoost: _asNullableDouble(json['saref_boost']),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((Object? key, Object? val) => MapEntry(key.toString(), val));
    }
    return const <String, dynamic>{};
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double? _asNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    return _asDouble(value);
  }
}

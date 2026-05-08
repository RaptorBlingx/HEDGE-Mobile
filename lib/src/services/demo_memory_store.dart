class DemoMemoryStore {
  Set<String> _savedIds = <String>{};
  String? _baseUrl;

  Future<Set<String>> loadSavedIds() async {
    return Set<String>.from(_savedIds);
  }

  Future<void> persistSavedIds(Set<String> ids) async {
    _savedIds = Set<String>.from(ids);
  }

  Future<String?> loadBaseUrl() async {
    return _baseUrl;
  }

  Future<void> persistBaseUrl(String value) async {
    _baseUrl = value;
  }
}

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/catalog_app.dart';
import '../models/chat_models.dart';
import '../services/demo_memory_store.dart';
import '../services/hedge_api_client.dart';

class AppController extends ChangeNotifier {
  AppController({HedgeApiClient? apiClient, DemoMemoryStore? memoryStore})
      : _memoryStore = memoryStore ?? DemoMemoryStore(),
        _apiClient = apiClient ?? HedgeApiClient(baseUrl: AppConfig.defaultBaseUrl),
        _conversation = <ConversationMessage>[
          ConversationMessage.assistant(AppConfig.welcomeMessage),
        ] {
    apiBaseUrl = _apiClient.baseUrl;
  }

  final DemoMemoryStore _memoryStore;
  final HedgeApiClient _apiClient;
  final List<ConversationMessage> _conversation;

  bool isBootstrapping = false;
  bool isCatalogLoading = false;
  bool isChatLoading = false;
  String? catalogError;
  String? chatError;
  String? sessionId;
  DateTime? _activeRequestStartedAt;
  String apiBaseUrl = AppConfig.defaultBaseUrl;
  String browseQuery = '';
  String selectedCategory = AppConfig.allCategoryLabel;
  List<CatalogApp> _catalog = <CatalogApp>[];
  Set<String> _savedIds = <String>{};

  List<ConversationMessage> get conversation => List<ConversationMessage>.unmodifiable(_conversation);

  DateTime? get activeRequestStartedAt => _activeRequestStartedAt;

  List<CatalogApp> get catalog => List<CatalogApp>.unmodifiable(_catalog);

  List<String> get categories {
    final values = _catalog.map((CatalogApp app) => app.sarefType).where((String value) => value.isNotEmpty).toSet().toList()..sort();
    return <String>[AppConfig.allCategoryLabel, ...values];
  }

  List<CatalogApp> get filteredCatalog {
    final query = browseQuery.trim().toLowerCase();
    return _catalog.where((CatalogApp app) {
      final matchesCategory = selectedCategory == AppConfig.allCategoryLabel || app.sarefType == selectedCategory;
      if (!matchesCategory) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = <String>[
        app.id,
        app.title,
        app.description,
        app.publisher,
        app.sarefType,
        ...app.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<CatalogApp> get savedApps {
    final byId = <String, CatalogApp>{for (final app in _catalog) app.id: app};
    return _savedIds.map((String id) => byId[id]).whereType<CatalogApp>().toList();
  }

  bool isSaved(String appId) => _savedIds.contains(appId);

  Future<void> bootstrap() async {
    isBootstrapping = true;
    notifyListeners();

    _savedIds = await _memoryStore.loadSavedIds();
    final storedBaseUrl = await _memoryStore.loadBaseUrl();
    if (storedBaseUrl != null && storedBaseUrl.isNotEmpty) {
      apiBaseUrl = storedBaseUrl;
      _apiClient.baseUrl = storedBaseUrl;
    }

    await loadCatalog();
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> loadCatalog() async {
    isCatalogLoading = true;
    catalogError = null;
    notifyListeners();
    try {
      _catalog = await _apiClient.fetchCatalog();
    } catch (error) {
      catalogError = error.toString();
    } finally {
      isCatalogLoading = false;
      notifyListeners();
    }
  }

  void setBrowseQuery(String value) {
    browseQuery = value;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return;
    }
    apiBaseUrl = normalized;
    _apiClient.baseUrl = normalized;
    sessionId = null;
    await _memoryStore.persistBaseUrl(normalized);
    await loadCatalog();
  }

  Future<void> toggleSaved(CatalogApp app) async {
    if (_savedIds.contains(app.id)) {
      _savedIds.remove(app.id);
    } else {
      _savedIds.add(app.id);
    }
    await _memoryStore.persistSavedIds(_savedIds);
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || isChatLoading) {
      return;
    }

    chatError = null;
    _conversation.add(ConversationMessage.user(trimmed));
    final requestStartedAt = DateTime.now();
    _activeRequestStartedAt = requestStartedAt;
    isChatLoading = true;
    notifyListeners();

    try {
      final reply = await _apiClient.sendChat(trimmed, sessionId: sessionId);
      final responseTime = DateTime.now().difference(requestStartedAt);
      sessionId = reply.sessionId.isEmpty ? sessionId : reply.sessionId;
      _conversation.add(
        ConversationMessage.assistant(
          reply.message,
          apps: reply.apps,
          responseTime: responseTime,
        ),
      );
    } catch (error) {
      chatError = error.toString();
      _conversation.add(
        ConversationMessage.assistant(
          'I could not reach HEDGE-ExpertAI. Check the gateway URL in Settings and try again.',
          isError: true,
        ),
      );
    } finally {
      _activeRequestStartedAt = null;
      isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> askAboutApp(CatalogApp app) async {
    await sendMessage('Tell me about ${app.id}');
  }

  Future<void> submitFeedback(String appId, String action) async {
    final currentSessionId = sessionId;
    if (currentSessionId == null || currentSessionId.isEmpty) {
      return;
    }
    try {
      await _apiClient.submitFeedback(
        sessionId: currentSessionId,
        appId: appId,
        action: action,
      );
    } catch (_) {
      return;
    }
  }

  void clearConversation() {
    sessionId = null;
    chatError = null;
    _activeRequestStartedAt = null;
    _conversation
      ..clear()
      ..add(ConversationMessage.assistant(AppConfig.welcomeMessage));
    notifyListeners();
  }
}

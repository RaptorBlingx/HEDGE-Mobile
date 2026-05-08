import 'dart:convert';
import 'dart:io';

import '../models/catalog_app.dart';
import '../models/chat_models.dart';

class HedgeApiException implements Exception {
  const HedgeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HedgeApiClient {
  HedgeApiClient({required String baseUrl}) : _baseUrl = _normalizeBaseUrl(baseUrl);

  String _baseUrl;

  String get baseUrl => _baseUrl;

  set baseUrl(String value) {
    _baseUrl = _normalizeBaseUrl(value);
  }

  Future<List<CatalogApp>> fetchCatalog() async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/api/v1/catalog/apps?page=1&page_size=100',
    );
    final map = _asMap(payload);
    final rawApps = map['apps'];
    if (rawApps is! List) {
      return const <CatalogApp>[];
    }
    return rawApps
        .map((Object? item) => item is Map<String, dynamic>
            ? item
            : item is Map
                ? item.map((Object? key, Object? value) => MapEntry(key.toString(), value))
                : const <String, dynamic>{})
        .map(CatalogApp.fromJson)
        .toList();
  }

  Future<ChatReply> sendChat(String message, {String? sessionId}) async {
    final payload = await _requestJson(
      method: 'POST',
      path: '/api/v1/chat',
      body: <String, Object?>{
        'message': message,
        'session_id': sessionId,
      },
    );
    return ChatReply.fromJson(_asMap(payload));
  }

  Future<void> submitFeedback({
    required String sessionId,
    required String appId,
    required String action,
  }) async {
    await _requestJson(
      method: 'POST',
      path: '/api/v1/feedback',
      body: <String, Object?>{
        'session_id': sessionId,
        'app_id': appId,
        'action': action,
      },
    );
  }

  Future<Object?> _requestJson({
    required String method,
    required String path,
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, Uri.parse('$_baseUrl$path'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 400) {
        throw HedgeApiException(_extractMessage(text, response.statusCode));
      }
      if (text.isEmpty) {
        return null;
      }
      return jsonDecode(text);
    } on SocketException catch (error) {
      throw HedgeApiException(
        'Could not reach the HEDGE gateway at $_baseUrl (${error.message}).',
      );
    } on HttpException catch (error) {
      throw HedgeApiException(error.message);
    } on FormatException catch (error) {
      throw HedgeApiException('The HEDGE gateway returned invalid JSON: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, dynamic> _asMap(Object? payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return payload.map((Object? key, Object? value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  static String _extractMessage(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      final map = _asMap(decoded);
      final detail = map['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
    } catch (_) {
      if (body.isNotEmpty) {
        return 'Gateway returned HTTP $statusCode: $body';
      }
    }
    return 'Gateway returned HTTP $statusCode.';
  }
}

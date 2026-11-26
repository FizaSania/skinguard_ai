import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
typedef HeaderMap = Map<String, String>;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Shared HTTP client for SkinGuard AI FastAPI backend.
class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://127.0.0.1:8000',
                ))
            .replaceAll(RegExp(r'/+$'), ''),
        _http = httpClient ?? http.Client();

  static const _tokenKey = 'skinguard_jwt_token';

  final String baseUrl;
  final http.Client _http;
  String? _cachedToken;

  /// Caches full POST /scans or GET /scans/{id} payloads by scan_id
  /// so RecommendationService can read Fatima's live recommendations cleanly.
  final Map<String, Map<String, dynamic>> scanCache = {};

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    scanCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Resolves relative backend URLs like "/static/products/product_5.jpg".
  String? resolveUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalized';
  }

  Future<HeaderMap> _headers({
    required bool auth,
    bool jsonContent = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (jsonContent) 'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> getJson(String path, {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, jsonContent: false);
    try {
      final res = await _http.get(uri, headers: headers);
      return _decodeResponse(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Cannot reach the SkinGuard server at $baseUrl. Make sure FastAPI is running.',
      );
    }
  }

  Future<dynamic> postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth, jsonContent: true);
    try {
      final res = await _http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _decodeResponse(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Cannot reach the SkinGuard server at $baseUrl. Make sure FastAPI is running.',
      );
    }
  }

  Future<dynamic> postMultipart(
    String path, {
    required List<int> fileBytes,
    required String filename,
    String fileField = 'image',
    Map<String, String> fields = const {},
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _headers(auth: auth, jsonContent: false));
    req.fields.addAll(fields);
    req.files.add(
      http.MultipartFile.fromBytes(fileField, fileBytes, filename: filename),
    );

    try {
      final streamed = await _http.send(req);
      final res = await http.Response.fromStream(streamed);
      return _decodeResponse(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Upload failed. Make sure FastAPI is running at $baseUrl.',
      );
    }
  }

  dynamic _decodeResponse(http.Response res) {
    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = res.body;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      _extractErrorMessage(decoded, res.statusCode),
      statusCode: res.statusCode,
    );
  }

  String _extractErrorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    if (statusCode == 401) {
      return 'Invalid email or password, or your session has expired.';
    }
    return 'Request failed (HTTP $statusCode).';
  }
}
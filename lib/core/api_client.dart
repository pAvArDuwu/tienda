import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_constants.dart';

class ApiClient {
  static final String _base = AppConstants.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('$_base$path');
    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$path');
    final response = await http.post(uri, headers: _headers, body: jsonEncode(body));
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$path');
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body));
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  static Future<void> delete(String path) async {
    final uri = Uri.parse('$_base$path');
    final response = await http.delete(uri, headers: _headers);
    _checkStatus(response);
  }

  static void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      dynamic body = {};
      try { body = jsonDecode(response.body); } catch (_) {}
      final msg = body['error'] ?? 'Error ${response.statusCode}';
      throw ApiException(msg.toString(), response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

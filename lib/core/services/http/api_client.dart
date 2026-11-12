import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
  }

  Uri _buildUri(String endpoint) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'), '');
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$path');
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> get(String endpoint) {
    return _client.get(_buildUri(endpoint), headers: _headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) {
    return _client.post(
      _buildUri(endpoint),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) {
    return _client.put(
      _buildUri(endpoint),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) {
    return _client.patch(
      _buildUri(endpoint),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) {
    return _client.delete(_buildUri(endpoint), headers: _headers);
  }

  void dispose() {
    _client.close();
  }
}

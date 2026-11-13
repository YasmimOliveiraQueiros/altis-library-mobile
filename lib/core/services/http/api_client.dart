import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/app_role.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;
  AppRole? _role;
  final ValueNotifier<int> _sessionChanges = ValueNotifier(0);

  bool get hasToken => _token != null && _token!.isNotEmpty;
  bool get hasAdminSession => hasToken && _role == AppRole.admin;
  bool get hasUserSession => hasToken && _role == AppRole.user;
  AppRole? get role => hasToken ? _role : null;
  int get sessionRevision => _sessionChanges.value;
  ValueListenable<int> get sessionChanges => _sessionChanges;

  void setToken(String? token) {
    _token = token;
    _role = null;
    _notifySessionChanged();
  }

  void setSession({required String token, required AppRole role}) {
    _token = token;
    _role = role;
    _notifySessionChanged();
  }

  void clearSession() {
    _token = null;
    _role = null;
    _notifySessionChanged();
  }

  void _notifySessionChanged() {
    _sessionChanges.value++;
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
    _sessionChanges.dispose();
    _client.close();
  }
}

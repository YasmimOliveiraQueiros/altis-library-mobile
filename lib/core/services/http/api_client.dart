import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/app_role.dart';
import 'api_errors.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient({http.Client? client, this._timeout = const Duration(seconds: 30)})
    : _client = client ?? http.Client(),
      _hasInjectedClient = client != null;

  final http.Client _client;
  final bool _hasInjectedClient;
  final Duration _timeout;
  String? _token;
  AppRole? _role;
  final ValueNotifier<int> _sessionChanges = ValueNotifier(0);
  final ValueNotifier<int> _sessionExpirations = ValueNotifier(0);

  bool get hasToken => _token != null && _token!.isNotEmpty;
  bool get hasAdminSession => hasToken && _role == AppRole.admin;
  bool get hasUserSession => hasToken && _role == AppRole.user;
  AppRole? get role => hasToken ? _role : null;
  int get sessionRevision => _sessionChanges.value;
  ValueListenable<int> get sessionChanges => _sessionChanges;
  ValueListenable<int> get sessionExpirations => _sessionExpirations;

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
    if (!ApiConfig.isConfigured && !_hasInjectedClient) {
      throw StateError(ApiConfig.configurationError);
    }
    final configuredBaseUrl = ApiConfig.isConfigured
        ? ApiConfig.baseUrl
        : 'http://mock.local';
    final baseUrl = configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$path');
  }

  Map<String, String> _headers({bool includeToken = true}) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (includeToken && hasToken) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool authenticated = true,
  }) async {
    final requestToken = authenticated && hasToken ? _token : null;
    final requestSessionRevision = _sessionChanges.value;
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode == 401 &&
          requestToken != null &&
          _token == requestToken &&
          _sessionChanges.value == requestSessionRevision) {
        clearSession();
        _sessionExpirations.value++;
      }
      return response;
    } on TimeoutException {
      throw const ApiTransportException(ApiTransportFailure.timeout);
    } on http.ClientException {
      throw const ApiTransportException(ApiTransportFailure.connection);
    }
  }

  Future<http.Response> get(String endpoint) {
    return _send(() => _client.get(_buildUri(endpoint), headers: _headers()));
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) {
    return _send(
      () => _client.post(
        _buildUri(endpoint),
        headers: _headers(),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<http.Response> postPublic(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return _send(
      () => _client.post(
        _buildUri(endpoint),
        headers: _headers(includeToken: false),
        body: jsonEncode(body ?? {}),
      ),
      authenticated: false,
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) {
    return _send(
      () => _client.put(
        _buildUri(endpoint),
        headers: _headers(),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) {
    return _send(
      () => _client.patch(
        _buildUri(endpoint),
        headers: _headers(),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<http.Response> delete(String endpoint) {
    return _send(
      () => _client.delete(_buildUri(endpoint), headers: _headers()),
    );
  }

  void dispose() {
    _sessionChanges.dispose();
    _sessionExpirations.dispose();
    _client.close();
  }
}

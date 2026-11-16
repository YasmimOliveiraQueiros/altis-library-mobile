import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/models/app_role.dart';
import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AppRole> login({
    required String email,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await _apiClient.postPublic(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
    } on ApiTransportException catch (error) {
      throw AuthException(
        error.failure == ApiTransportFailure.timeout
            ? AuthFailure.timeout
            : AuthFailure.connection,
      );
    }

    if (response.statusCode == 401) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    if (response.statusCode == 403) {
      throw AuthException(
        AuthFailure.forbidden,
        message: ApiErrorResponse.fromResponse(response)?.message,
      );
    }
    if (response.statusCode != 200) {
      throw AuthException(
        AuthFailure.requestFailed,
        message: ApiErrorResponse.fromResponse(response)?.displayMessage,
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AuthException(AuthFailure.invalidResponse);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AuthException(AuthFailure.invalidResponse);
    }

    final role = AppRole.fromApiValue(decoded['role']);
    final token = decoded['token'];
    if (role == null || token is! String || token.trim().isEmpty) {
      throw const AuthException(AuthFailure.invalidResponse);
    }

    _apiClient.setSession(token: token, role: role);
    return role;
  }
}

enum AuthFailure {
  invalidCredentials,
  forbidden,
  invalidResponse,
  connection,
  timeout,
  requestFailed,
}

class AuthException implements Exception {
  const AuthException(this.failure, {this.message});

  final AuthFailure failure;
  final String? message;
}

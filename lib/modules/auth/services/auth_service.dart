import 'dart:convert';

import '../../../core/models/app_role.dart';
import '../../../core/services/http/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<String> login({
    required String email,
    required String password,
    AppRole expectedRole = AppRole.admin,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no login: HTTP ${response.statusCode}');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AuthException('Resposta de autenticação inválida.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AuthException('Resposta de autenticação inválida.');
    }

    final role = AppRole.fromApiValue(decoded['role']);
    if (role == null) {
      throw const AuthException('O backend retornou um papel inesperado.');
    }
    if (role != expectedRole) {
      throw AuthException(
        'Esta área exige uma conta ${expectedRole.apiValue}.',
      );
    }

    final token = decoded['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const AuthException('O backend não retornou um token válido.');
    }

    return token;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

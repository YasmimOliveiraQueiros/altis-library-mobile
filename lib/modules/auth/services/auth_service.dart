import 'dart:convert';

import '../../../core/services/http/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no login: HTTP ${response.statusCode}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (data['role'] != 'ADMIN') {
      throw Exception('Esta área exige uma conta de administrador.');
    }

    return data['token'] as String;
  }
}

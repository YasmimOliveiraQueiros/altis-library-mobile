import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';

class PasswordRecoveryService {
  PasswordRecoveryService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> verify({required String email, required String cpf}) async {
    final http.Response response;
    try {
      response = await _apiClient.post(
        '/auth/password-recovery/verify',
        body: {'email': email, 'cpf': cpf},
      );
    } on http.ClientException {
      throw const PasswordRecoveryException(PasswordRecoveryFailure.connection);
    }

    if (response.statusCode != 200) {
      throw const PasswordRecoveryException(
        PasswordRecoveryFailure.requestFailed,
      );
    }
    if (response.bodyBytes.isNotEmpty) {
      throw const PasswordRecoveryException(
        PasswordRecoveryFailure.invalidResponse,
      );
    }
  }
}

enum PasswordRecoveryFailure { connection, invalidResponse, requestFailed }

class PasswordRecoveryException implements Exception {
  const PasswordRecoveryException(this.failure);

  final PasswordRecoveryFailure failure;
}

import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';

class PasswordRecoveryService {
  PasswordRecoveryService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> verify({required String email, required String cpf}) {
    return _post(
      '/auth/password-recovery/verify',
      body: {'email': email, 'cpf': cpf},
    );
  }

  Future<void> reset({
    required String email,
    required String cpf,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _post(
      '/auth/password-recovery/reset',
      body: {
        'email': email,
        'cpf': cpf,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> _post(
    String endpoint, {
    required Map<String, String> body,
  }) async {
    final http.Response response;
    try {
      response = await _apiClient.postPublic(endpoint, body: body);
    } on ApiTransportException catch (error) {
      throw PasswordRecoveryException(
        error.failure == ApiTransportFailure.timeout
            ? PasswordRecoveryFailure.timeout
            : PasswordRecoveryFailure.connection,
      );
    }

    if (response.statusCode == 204) {
      if (response.bodyBytes.isEmpty) return;
      throw const PasswordRecoveryException(
        PasswordRecoveryFailure.invalidResponse,
      );
    }

    final error = ApiErrorResponse.fromResponse(response);
    final message = error?.message;
    if (message?.contains(
          'Não é permitido alterar a senha do administrador por este fluxo',
        ) ??
        false) {
      throw const PasswordRecoveryException(
        PasswordRecoveryFailure.adminBlocked,
      );
    }
    throw PasswordRecoveryException(
      PasswordRecoveryFailure.requestFailed,
      message: error?.message,
      fieldErrors: error?.fieldErrors ?? const {},
    );
  }
}

enum PasswordRecoveryFailure {
  connection,
  timeout,
  invalidResponse,
  requestFailed,
  adminBlocked,
}

class PasswordRecoveryException implements Exception {
  const PasswordRecoveryException(
    this.failure, {
    this.message,
    this.fieldErrors = const {},
  });

  final PasswordRecoveryFailure failure;
  final String? message;
  final Map<String, String> fieldErrors;

  String? get displayMessage {
    final details = <String>[?message, ...fieldErrors.values];
    return details.isEmpty ? null : details.toSet().join('\n');
  }
}

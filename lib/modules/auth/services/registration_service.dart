import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';

class RegistrationService {
  RegistrationService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String cpf,
    required String birthDate,
    required String address,
  }) async {
    final http.Response response;
    try {
      response = await _apiClient.postPublic(
        '/users',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'cpf': cpf,
          'birthDate': birthDate,
          'address': address,
        },
      );
    } on ApiTransportException catch (error) {
      throw RegistrationException(
        error.failure == ApiTransportFailure.timeout
            ? RegistrationFailure.timeout
            : RegistrationFailure.connection,
      );
    }

    if (response.statusCode == 201) return;

    final error = ApiErrorResponse.fromResponse(response);
    if (response.statusCode == 400) {
      throw RegistrationException(
        RegistrationFailure.validation,
        message: error?.message,
        fieldErrors: error?.fieldErrors ?? const {},
      );
    }
    if (response.statusCode == 409) {
      final duplicateType = _duplicateType(error);
      throw RegistrationException(
        duplicateType,
        message: error?.message,
        fieldErrors: error?.fieldErrors ?? const {},
      );
    }
    throw RegistrationException(
      RegistrationFailure.requestFailed,
      message: error?.message,
      fieldErrors: error?.fieldErrors ?? const {},
    );
  }

  RegistrationFailure _duplicateType(ApiErrorResponse? error) {
    final cpfError = error?.fieldErrors.containsKey('cpf') ?? false;
    final emailError =
        error?.fieldErrors.containsKey('email') == true ||
        error?.fieldErrors.containsKey('e-mail') == true;
    if (cpfError && !emailError) return RegistrationFailure.cpfConflict;
    if (emailError && !cpfError) return RegistrationFailure.emailConflict;

    final message = error?.message?.toLowerCase() ?? '';
    if (message.contains('cpf')) return RegistrationFailure.cpfConflict;
    if (message.contains('e-mail') || message.contains('email')) {
      return RegistrationFailure.emailConflict;
    }
    return RegistrationFailure.conflict;
  }
}

enum RegistrationFailure {
  connection,
  timeout,
  validation,
  emailConflict,
  cpfConflict,
  conflict,
  requestFailed,
}

class RegistrationException implements Exception {
  const RegistrationException(
    this.failure, {
    this.message,
    this.fieldErrors = const {},
  });

  final RegistrationFailure failure;
  final String? message;
  final Map<String, String> fieldErrors;
}

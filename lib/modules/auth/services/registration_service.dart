import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';

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
    } on http.ClientException {
      throw const RegistrationException(RegistrationFailure.connection);
    } on SocketException {
      throw const RegistrationException(RegistrationFailure.connection);
    }

    if (response.statusCode == 201) return;

    final error = _readError(response);
    if (response.statusCode == 400) {
      throw RegistrationException(
        RegistrationFailure.validation,
        message: error.message,
        fieldErrors: error.fieldErrors,
      );
    }
    if (response.statusCode == 409) {
      final duplicateType = _duplicateType(error);
      throw RegistrationException(
        duplicateType,
        message: error.message,
        fieldErrors: error.fieldErrors,
      );
    }
    throw const RegistrationException(RegistrationFailure.requestFailed);
  }

  _RegistrationError _readError(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return const _RegistrationError();

      final message = decoded['message'];
      final fieldErrors = <String, String>{};
      final rawFieldErrors = decoded['fieldErrors'];
      if (rawFieldErrors is List) {
        for (final entry in rawFieldErrors) {
          if (entry is! Map<String, dynamic>) continue;
          final field = entry['field'];
          final fieldMessage = entry['message'];
          if (field is String &&
              fieldMessage is String &&
              field.isNotEmpty &&
              fieldMessage.isNotEmpty) {
            fieldErrors[field] = fieldMessage;
          }
        }
      }

      return _RegistrationError(
        message: message is String && message.trim().isNotEmpty
            ? message.trim()
            : null,
        fieldErrors: fieldErrors,
      );
    } on FormatException {
      return const _RegistrationError();
    }
  }

  RegistrationFailure _duplicateType(_RegistrationError error) {
    final cpfError = error.fieldErrors.containsKey('cpf');
    final emailError =
        error.fieldErrors.containsKey('email') ||
        error.fieldErrors.containsKey('e-mail');
    if (cpfError && !emailError) return RegistrationFailure.cpfConflict;
    if (emailError && !cpfError) return RegistrationFailure.emailConflict;

    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('cpf')) return RegistrationFailure.cpfConflict;
    if (message.contains('e-mail') || message.contains('email')) {
      return RegistrationFailure.emailConflict;
    }
    return RegistrationFailure.conflict;
  }
}

enum RegistrationFailure {
  connection,
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

class _RegistrationError {
  const _RegistrationError({this.message, this.fieldErrors = const {}});

  final String? message;
  final Map<String, String> fieldErrors;
}

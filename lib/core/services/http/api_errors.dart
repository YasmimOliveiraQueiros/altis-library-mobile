import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../l10n/app_localizations.dart';

enum ApiTransportFailure { connection, timeout }

class ApiTransportException implements Exception {
  const ApiTransportException(this.failure);

  final ApiTransportFailure failure;
}

class ApiErrorResponse {
  const ApiErrorResponse({this.message, this.fieldErrors = const {}});

  final String? message;
  final Map<String, String> fieldErrors;

  String? get displayMessage {
    final details = <String>[?message, ...fieldErrors.values];
    return details.isEmpty ? null : details.toSet().join('\n');
  }

  static ApiErrorResponse? fromResponse(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;

    final rawMessage = decoded['message'];
    final message = rawMessage is String && rawMessage.trim().isNotEmpty
        ? rawMessage.trim()
        : null;
    final fieldErrors = <String, String>{};
    final rawFieldErrors = decoded['fieldErrors'];

    if (rawFieldErrors is List) {
      for (final entry in rawFieldErrors) {
        if (entry is! Map) continue;
        final field = entry['field'];
        final error = entry['message'];
        if (field is String &&
            field.isNotEmpty &&
            error is String &&
            error.trim().isNotEmpty) {
          fieldErrors[field] = error.trim();
        }
      }
    } else if (rawFieldErrors is Map) {
      for (final entry in rawFieldErrors.entries) {
        if (entry.key is String &&
            entry.value is String &&
            (entry.value as String).trim().isNotEmpty) {
          fieldErrors[entry.key as String] = (entry.value as String).trim();
        }
      }
    }

    return ApiErrorResponse(message: message, fieldErrors: fieldErrors);
  }
}

class ApiHttpException implements Exception {
  ApiHttpException(http.Response response)
    : statusCode = response.statusCode,
      errorResponse = ApiErrorResponse.fromResponse(response);

  final int statusCode;
  final ApiErrorResponse? errorResponse;
}

String apiTransportErrorMessage(
  AppLocalizations localizations,
  ApiTransportException error,
) {
  return switch (error.failure) {
    ApiTransportFailure.connection => localizations.apiConnectionFailed,
    ApiTransportFailure.timeout => localizations.apiTimeout,
  };
}

String apiHttpErrorMessage(
  ApiHttpException error,
  String fallback, {
  String? forbiddenFallback,
}) {
  if (error.statusCode == 403) {
    return error.errorResponse?.message ?? forbiddenFallback ?? fallback;
  }
  return error.errorResponse?.displayMessage ?? fallback;
}

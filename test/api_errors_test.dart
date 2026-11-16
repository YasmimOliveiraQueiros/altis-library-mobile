import 'dart:async';
import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/http/api_errors.dart';
import 'package:altis_library_mobile/modules/publishers/models/publisher.dart';
import 'package:altis_library_mobile/modules/publishers/services/publisher_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('HTTP failures preserve status, message, and field errors', () async {
    for (final statusCode in [400, 403, 404, 409, 500]) {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'timestamp': '2026-11-16T12:00:00',
                'status': statusCode,
                'error': 'Request failed',
                'message': 'Erro específico $statusCode.',
                'path': '/publishers',
                'fieldErrors': [
                  {'field': 'email', 'message': 'E-mail inválido.'},
                ],
              }),
            ),
            statusCode,
          ),
        ),
      );
      addTearDown(client.dispose);

      await expectLater(
        PublisherService(client).createPublisher(
          const PublisherData(
            name: 'Editora',
            email: 'editora@example.test',
            cnpj: '123',
            city: 'Cidade',
            state: 'ST',
          ),
        ),
        throwsA(
          isA<ApiHttpException>()
              .having((error) => error.statusCode, 'statusCode', statusCode)
              .having(
                (error) => error.errorResponse?.message,
                'message',
                'Erro específico $statusCode.',
              )
              .having(
                (error) => error.errorResponse?.fieldErrors,
                'fieldErrors',
                {'email': 'E-mail inválido.'},
              ),
        ),
      );
    }
  });

  test('error response parser accepts map-shaped field errors', () {
    final error = ApiErrorResponse.fromResponse(
      http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'message': 'Validação inválida.',
            'fieldErrors': {'name': 'Nome obrigatório.'},
          }),
        ),
        400,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    expect(error?.displayMessage, 'Validação inválida.\nNome obrigatório.');
  });

  test('empty responses are not decoded as JSON', () {
    expect(ApiErrorResponse.fromResponse(http.Response('', 204)), isNull);
  });

  test('ApiClient distinguishes timeout from connection failure', () async {
    final timeoutClient = ApiClient(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 10),
    );
    addTearDown(timeoutClient.dispose);

    await expectLater(
      timeoutClient.get('/test'),
      throwsA(
        isA<ApiTransportException>().having(
          (error) => error.failure,
          'failure',
          ApiTransportFailure.timeout,
        ),
      ),
    );

    final connectionClient = ApiClient(
      client: MockClient((_) async {
        throw http.ClientException('private connection detail');
      }),
    );
    addTearDown(connectionClient.dispose);

    await expectLater(
      connectionClient.get('/test'),
      throwsA(
        isA<ApiTransportException>().having(
          (error) => error.failure,
          'failure',
          ApiTransportFailure.connection,
        ),
      ),
    );
  });
}

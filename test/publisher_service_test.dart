import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/publishers/models/publisher.dart';
import 'package:altis_library_mobile/modules/publishers/services/publisher_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'publisher CRUD uses the documented authenticated API contracts',
    () async {
      final requests = <http.Request>[];
      final publisherJson = {
        'id': 42,
        'name': 'Altis Editora',
        'email': 'contato@altis.example',
        'cnpj': '12345678000199',
        'city': 'São Paulo',
        'state': 'SP',
        'bookCount': 3,
        'status': 'ACTIVE',
      };
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'content': [publisherJson],
                  'totalElements': 1,
                  'totalPages': 1,
                  'number': 0,
                  'size': 10,
                  'first': true,
                  'last': true,
                  'empty': false,
                }),
              ),
              200,
            );
          }
          if (request.method == 'DELETE') {
            return http.Response('', 200);
          }
          if (request.method == 'POST') {
            return http.Response('', 200);
          }
          return http.Response.bytes(
            utf8.encode(jsonEncode(publisherJson)),
            200,
          );
        }),
      );
      client.setToken('test-token');
      final service = PublisherService(client);
      const data = PublisherData(
        name: 'Altis Editora',
        email: 'contato@altis.example',
        cnpj: '12345678000199',
        city: 'São Paulo',
        state: 'SP',
      );

      try {
        final page = await service.getPublishers(
          search: ' Altis ',
          page: 1,
          size: 20,
        );
        await service.createPublisher(data);
        await service.updatePublisher(42, data);
        await service.deletePublisher(42);

        expect(page.content.single.status, PublisherStatus.active);
        expect(page.content.single.bookCount, 3);
        expect(page.totalElements, 1);
        expect(requests.map((request) => request.method), [
          'GET',
          'POST',
          'PUT',
          'DELETE',
        ]);
        expect(requests[0].url.path, '/publishers');
        expect(requests[0].url.queryParameters, {
          'page': '1',
          'size': '20',
          'search': 'Altis',
        });
        expect(requests[1].url.path, '/publishers');
        expect(jsonDecode(requests[1].body), data.toJson());
        expect(requests[2].url.path, '/publishers/42');
        expect(jsonDecode(requests[2].body), data.toJson());
        expect(requests[3].url.path, '/publishers/42');
        for (final request in requests) {
          expect(request.headers['authorization'], 'Bearer test-token');
        }
      } finally {
        client.dispose();
      }
    },
  );

  test(
    'create and update accept 201 and 204 without decoding response bodies',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', request.method == 'POST' ? 201 : 204);
        }),
      );
      final service = PublisherService(client);
      const data = PublisherData(
        name: 'Altis Editora',
        email: 'contato@altis.example',
        cnpj: '12345678000199',
        city: 'São Paulo',
        state: 'SP',
      );

      try {
        await service.createPublisher(data);
        await service.updatePublisher(42, data);

        expect(requests.map((request) => request.method), ['POST', 'PUT']);
        expect(requests.map((request) => request.url.path), [
          '/publishers',
          '/publishers/42',
        ]);
      } finally {
        client.dispose();
      }
    },
  );

  test(
    'save failures retain the HTTP status without exposing the response body',
    () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('private backend detail', 409),
        ),
      );
      final service = PublisherService(client);
      const data = PublisherData(
        name: 'Altis Editora',
        email: 'contato@altis.example',
        cnpj: '12345678000199',
        city: 'São Paulo',
        state: 'SP',
      );

      try {
        await expectLater(
          service.createPublisher(data),
          throwsA(
            isA<PublisherSaveException>().having(
              (error) => error.statusCode,
              'statusCode',
              409,
            ),
          ),
        );
      } finally {
        client.dispose();
      }
    },
  );

  test('publisher data serializes only the documented request fields', () {
    const publisher = PublisherData(
      name: 'Altis Editora',
      email: 'contato@altis.example',
      cnpj: '12345678000199',
      city: 'São Paulo',
      state: 'SP',
    );

    expect(publisher.toJson(), {
      'name': 'Altis Editora',
      'email': 'contato@altis.example',
      'cnpj': '12345678000199',
      'city': 'São Paulo',
      'state': 'SP',
    });
  });
}

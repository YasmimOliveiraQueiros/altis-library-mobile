import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/users/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'search pagination and status use the authenticated API client',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'content': [
                  {
                    'id': 42,
                    'name': 'Maria Silva',
                    'email': 'maria@example.com',
                    'phone': '123',
                    'cpf': '456',
                    'birthDate': '2000-01-01',
                    'address': 'Rua A',
                    'isAdmin': false,
                    'active': true,
                    'createdAt': '2026-01-01',
                    'updatedAt': '2026-01-02',
                  },
                ],
                'totalElements': 21,
                'totalPages': 3,
                'number': 2,
                'size': 10,
                'first': false,
                'last': true,
                'empty': false,
              }),
              200,
            );
          }
          return http.Response('', 204);
        }),
      );
      client.setToken('test-token');
      final service = UserService(client);

      try {
        final response = await service.getUsers(
          search: ' Maria & Silva ',
          page: 2,
          size: 10,
        );
        await service.setUserActive(42, active: false);

        expect(response.content.single.name, 'Maria Silva');
        expect(response.totalElements, 21);
        expect(requests[0].method, 'GET');
        expect(requests[0].url.path, '/users');
        expect(requests[0].url.queryParameters, {
          'page': '2',
          'size': '10',
          'search': 'Maria & Silva',
        });
        expect(requests[0].headers['authorization'], 'Bearer test-token');
        expect(requests[1].method, 'PATCH');
        expect(requests[1].url.path, '/users/42/status');
        expect(requests[1].url.queryParameters['active'], 'false');
        expect(requests[1].headers['authorization'], 'Bearer test-token');
      } finally {
        client.dispose();
      }
    },
  );
}

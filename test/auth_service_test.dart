import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('ADMIN login sends credentials and creates an ADMIN session', () async {
    http.Request? request;
    final client = ApiClient(
      client: MockClient((value) async {
        request = value;
        return http.Response(
          jsonEncode({'token': 'admin-jwt', 'role': 'ADMIN'}),
          200,
        );
      }),
    );
    addTearDown(client.dispose);

    final role = await AuthService(client)
        .login(email: 'admin@example.test', password: 'secret');

    expect(role, AppRole.admin);
    expect(client.hasAdminSession, isTrue);
    expect(client.hasUserSession, isFalse);
    expect(request?.method, 'POST');
    expect(request?.url.path, '/auth/login');
    expect(jsonDecode(request!.body), {
      'email': 'admin@example.test',
      'password': 'secret',
    });
  });

  test('USER login creates a USER session from the backend role', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'token': 'user-jwt', 'role': 'USER'}),
          200,
        ),
      ),
    );
    addTearDown(client.dispose);

    final role = await AuthService(client)
        .login(email: 'user@example.test', password: 'secret');

    expect(role, AppRole.user);
    expect(client.hasUserSession, isTrue);
    expect(client.hasAdminSession, isFalse);
  });

  test('401 and 403 are reported as invalid credentials', () async {
    for (final status in [401, 403]) {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('', status)),
      );
      addTearDown(client.dispose);

      await expectLater(
        AuthService(client)
            .login(email: 'user@example.test', password: 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.failure,
            'failure',
            AuthFailure.invalidCredentials,
          ),
        ),
      );
      expect(client.hasToken, isFalse);
    }
  });

  test(
    'login rejects malformed responses without creating a session',
    () async {
      final responses = [
        http.Response('not-json', 200),
        http.Response(jsonEncode({'token': 'jwt', 'role': 'SUPERVISOR'}), 200),
        http.Response(jsonEncode({'token': '', 'role': 'ADMIN'}), 200),
        http.Response(jsonEncode({'role': 'ADMIN'}), 200),
      ];

      for (final response in responses) {
        final client = ApiClient(client: MockClient((_) async => response));
        addTearDown(client.dispose);

        await expectLater(
          AuthService(client)
              .login(email: 'admin@example.test', password: 'secret'),
          throwsA(
            isA<AuthException>().having(
              (error) => error.failure,
              'failure',
              AuthFailure.invalidResponse,
            ),
          ),
        );
        expect(client.hasToken, isFalse);
        expect(client.role, isNull);
      }
    },
  );

  test(
    'connection failure is reported without exposing request details',
    () async {
      final client = ApiClient(
        client: MockClient((_) async {
          throw http.ClientException('network unavailable');
        }),
      );
      addTearDown(client.dispose);

      await expectLater(
        AuthService(client)
            .login(email: 'user@example.test', password: 'secret'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.failure,
            'failure',
            AuthFailure.connection,
          ),
        ),
      );
      expect(client.hasToken, isFalse);
    },
  );
}

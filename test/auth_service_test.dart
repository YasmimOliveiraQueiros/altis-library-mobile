import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login defaults to ADMIN and rejects an unexpected USER role', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'token': 'user-jwt', 'role': 'USER'}),
          200,
        ),
      ),
    );
    addTearDown(client.dispose);

    await expectLater(
      AuthService(client)
          .login(email: 'user@example.test', password: 'password'),
      throwsA(isA<AuthException>()),
    );
    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
  });

  test('login rejects an unknown role and malformed permissions', () async {
    final responses = [
      http.Response(jsonEncode({'token': 'jwt', 'role': 'SUPERVISOR'}), 200),
      http.Response(jsonEncode({'token': '', 'role': 'ADMIN'}), 200),
      http.Response('', 403),
    ];

    for (final response in responses) {
      final client = ApiClient(client: MockClient((_) async => response));
      addTearDown(client.dispose);

      await expectLater(
        AuthService(client)
            .login(email: 'admin@example.test', password: 'password'),
        throwsA(isA<Exception>()),
      );
      expect(client.hasToken, isFalse);
      expect(client.role, isNull);
    }
  });

  test('USER login requires an explicit expected role', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'token': 'user-jwt', 'role': 'USER'}),
          200,
        ),
      ),
    );
    addTearDown(client.dispose);

    final token = await AuthService(client).login(
      email: 'user@example.test',
      password: 'password',
      expectedRole: AppRole.user,
    );
    client.setSession(token: token, role: AppRole.user);

    expect(client.hasUserSession, isTrue);
    expect(client.hasAdminSession, isFalse);
  });
}

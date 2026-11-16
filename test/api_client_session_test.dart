import 'dart:async';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('clearing a temporary session removes both token and role', () {
    final client = ApiClient();
    addTearDown(client.dispose);

    client.setSession(token: 'user-jwt', role: AppRole.user);
    expect(client.hasUserSession, isTrue);
    expect(client.role, AppRole.user);

    client.clearSession();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(client.hasAdminSession, isFalse);
    expect(client.hasUserSession, isFalse);
  });

  test('a bare token cannot grant an administrative or tenant role', () {
    final client = ApiClient();
    addTearDown(client.dispose);

    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    client.setToken('unclassified-jwt');

    expect(client.hasToken, isTrue);
    expect(client.role, isNull);
    expect(client.hasAdminSession, isFalse);
    expect(client.hasUserSession, isFalse);
  });

  test(
    'authenticated requests attach JWT and 401 expires the session',
    () async {
      http.Request? request;
      final client = ApiClient(
        client: MockClient((value) async {
          request = value;
          return http.Response('', 401);
        }),
      );
      addTearDown(client.dispose);
      client.setSession(token: 'user-jwt', role: AppRole.user);

      final response = await client.get('/protected');

      expect(response.statusCode, 401);
      expect(request?.headers['authorization'], 'Bearer user-jwt');
      expect(client.hasToken, isFalse);
      expect(client.role, isNull);
      expect(client.sessionExpirations.value, 1);
    },
  );

  test('403 preserves a valid session', () async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 403)),
    );
    addTearDown(client.dispose);
    client.setSession(token: 'admin-jwt', role: AppRole.admin);

    await client.get('/protected');

    expect(client.hasAdminSession, isTrue);
    expect(client.sessionExpirations.value, 0);
  });

  test(
    'public requests send no JWT and do not expire a session on 401',
    () async {
      http.Request? request;
      final client = ApiClient(
        client: MockClient((value) async {
          request = value;
          return http.Response('', 401);
        }),
      );
      addTearDown(client.dispose);
      client.setSession(token: 'user-jwt', role: AppRole.user);

      await client.postPublic('/public', body: {'value': 'test'});

      expect(request?.headers.containsKey('authorization'), isFalse);
      expect(client.hasUserSession, isTrue);
      expect(client.sessionExpirations.value, 0);
    },
  );

  test('simultaneous 401 responses expire one session only once', () async {
    final responses = [Completer<http.Response>(), Completer<http.Response>()];
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((_) => responses[requestCount++].future),
    );
    addTearDown(client.dispose);
    client.setSession(token: 'admin-jwt', role: AppRole.admin);

    final firstRequest = client.get('/protected/one');
    final secondRequest = client.get('/protected/two');
    responses[0].complete(http.Response('', 401));
    responses[1].complete(http.Response('', 401));

    await Future.wait([firstRequest, secondRequest]);

    expect(requestCount, 2);
    expect(client.hasToken, isFalse);
    expect(client.sessionExpirations.value, 1);
  });
}
